import AppKit
import Combine
import CoreGraphics
import ScreenCaptureKit
import SwiftUI
import ColorPickerCore

@MainActor
final class ScreenSampler: ObservableObject {
    static let apertureSizes = [1, 2, 4, 8, 16, 32]
    static let areaZooms: [CGFloat] = [0.5, 1, 2, 4, 8]

    enum Status: Equatable {
        case ready
        case needsScreenRecordingPermission
        case failed(String)
    }

    @Published private(set) var sampledColor: LinearRGB = .white
    @Published private(set) var previewImage: NSImage?
    @Published private(set) var apertureRect: PixelRect?
    @Published private(set) var previewPixelSize = CGSize.zero
    @Published private(set) var status: Status = .needsScreenRecordingPermission
    @Published private(set) var isPositionLocked = false
    @Published private(set) var copiedText: String?

    @Published var colorFormat: ColorFormat = .rgbNormalized
    @Published var apertureIndex = 0
    @Published var areaZoomIndex = 1

    private let captureProvider = ScreenCaptureProvider()
    private var timer: Timer?
    private var isCapturing = false
    private var copyAfterCapture = false
    private var lockedPoint: CGPoint?

    var apertureSize: Int {
        Self.apertureSizes[apertureIndex.clamped(to: 0...(Self.apertureSizes.count - 1))]
    }

    var areaZoom: CGFloat {
        Self.areaZooms[areaZoomIndex.clamped(to: 0...(Self.areaZooms.count - 1))]
    }

    var currentPresentation: ColorValuePresentation {
        ColorFormatter.presentation(for: sampledColor, format: colorFormat)
    }

    func start() {
        guard timer == nil else { return }
        refreshPermissionState(promptIfNeeded: true)
        let timer = Timer(timeInterval: 1.0 / 20.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.captureIfPossible()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func requestScreenRecordingPermission() {
        refreshPermissionState(promptIfNeeded: true)
    }

    func toggleCoordinateLock() {
        if isPositionLocked {
            isPositionLocked = false
            lockedPoint = nil
        } else if let currentPoint = currentMouseLocation() {
            lockedPoint = currentPoint
            isPositionLocked = true
        }
        captureIfPossible()
    }

    func refreshForControlChange() {
        captureIfPossible()
    }

    /// Captures a fresh frame before copying whenever possible, so the shortcut
    /// reflects the pointer position at the time it was pressed.
    func saveCurrentColor() {
        guard status == .ready else { return }
        if isCapturing {
            copyAfterCapture = true
        } else {
            copyAfterCapture = true
            captureIfPossible()
        }
    }

    func copyCurrentColor() {
        let text = currentPresentation.clipboardText
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        copiedText = text
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1.2))
            self?.copiedText = nil
        }
    }

    private func refreshPermissionState(promptIfNeeded: Bool) {
        if CGPreflightScreenCaptureAccess() {
            status = .ready
            captureIfPossible()
            return
        }

        if promptIfNeeded, CGRequestScreenCaptureAccess() {
            status = .ready
            captureIfPossible()
        } else {
            status = .needsScreenRecordingPermission
        }
    }

    private func captureIfPossible() {
        guard status == .ready, !isCapturing else { return }
        guard let point = lockedPoint ?? currentMouseLocation() else {
            status = .failed("The current mouse location could not be read.")
            return
        }

        isCapturing = true
        let aperture = apertureSize
        let sourcePixelSide = previewSourcePixelSide(for: aperture, zoom: areaZoom)
        Task { [weak self] in
            guard let self else { return }
            defer { self.isCapturing = false }
            do {
                let frame = try await self.captureProvider.capture(at: point, pixelSide: sourcePixelSide)
                let result = try PixelAverager.sample(
                    image: frame.image,
                    point: frame.pointInImage,
                    aperture: aperture
                )
                self.sampledColor = result.color
                self.previewImage = NSImage(
                    cgImage: frame.image,
                    size: NSSize(width: frame.image.width, height: frame.image.height)
                )
                self.apertureRect = result.apertureRect
                self.previewPixelSize = CGSize(width: frame.image.width, height: frame.image.height)
                self.status = .ready
                if self.copyAfterCapture {
                    self.copyAfterCapture = false
                    self.copyCurrentColor()
                }
            } catch {
                self.status = .failed(error.localizedDescription)
            }
        }
    }

    private func previewSourcePixelSide(for aperture: Int, zoom: CGFloat) -> Int {
        let baseSide = Int((24 / zoom).rounded(.up))
        return max(baseSide, aperture + 2)
    }

    private func currentMouseLocation() -> CGPoint? {
        CGEvent(source: nil)?.location
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

@MainActor
private final class ScreenCaptureProvider {
    private var shareableContent: SCShareableContent?

    struct CapturedFrame {
        let image: CGImage
        let pointInImage: CGPoint
    }

    func capture(at point: CGPoint, pixelSide: Int) async throws -> CapturedFrame {
        var content = try await availableContent()
        let display: SCDisplay
        if let matchingDisplay = content.displays.first(where: { $0.frame.contains(point) }) {
            display = matchingDisplay
        } else {
            shareableContent = nil
            content = try await availableContent()
            guard let refreshedDisplay = content.displays.first(where: { $0.frame.contains(point) }) else {
                throw SamplingError.noDisplayAtPointer
            }
            display = refreshedDisplay
        }

        let filter = SCContentFilter(display: display, excludingWindows: [])
        let contentInfo = SCShareableContent.info(for: filter)
        let pointPixelScale = max(CGFloat(contentInfo.pointPixelScale), 1)
        let requestedSide = CGFloat(pixelSide) / pointPixelScale
        let availableWidth = CGFloat(display.width)
        let availableHeight = CGFloat(display.height)
        let side = max(1, min(requestedSide, availableWidth, availableHeight))
        let localPoint = CGPoint(
            x: point.x - display.frame.minX,
            y: point.y - display.frame.minY
        )
        let sourceRect = CGRect(
            x: (localPoint.x - side / 2).clamped(to: 0...max(0, availableWidth - side)),
            y: (localPoint.y - side / 2).clamped(to: 0...max(0, availableHeight - side)),
            width: side,
            height: side
        )

        let configuration = SCStreamConfiguration()
        configuration.sourceRect = sourceRect
        configuration.width = max(1, Int((side * pointPixelScale).rounded()))
        configuration.height = max(1, Int((side * pointPixelScale).rounded()))
        configuration.showsCursor = false

        let image = try await SCScreenshotManager.captureImage(
            contentFilter: filter,
            configuration: configuration
        )
        let pointInImage = CGPoint(
            x: (localPoint.x - sourceRect.minX) / sourceRect.width * CGFloat(image.width),
            y: (localPoint.y - sourceRect.minY) / sourceRect.height * CGFloat(image.height)
        )
        return CapturedFrame(image: image, pointInImage: pointInImage)
    }

    private func availableContent() async throws -> SCShareableContent {
        if let shareableContent {
            return shareableContent
        }
        let content = try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )
        shareableContent = content
        return content
    }
}

private enum SamplingError: LocalizedError {
    case noDisplayAtPointer
    case pixelConversionFailed
    case noPixelsInAperture

    var errorDescription: String? {
        switch self {
        case .noDisplayAtPointer:
            "No display was found at the current pointer location."
        case .pixelConversionFailed:
            "The captured screen image could not be converted for sampling."
        case .noPixelsInAperture:
            "No pixels were available inside the selected aperture."
        }
    }
}

private enum PixelAverager {
    private static let linearSRGB = CGColorSpace(name: CGColorSpace.linearSRGB)!

    struct Result {
        let color: LinearRGB
        let apertureRect: PixelRect
    }

    static func sample(image: CGImage, point: CGPoint, aperture: Int) throws -> Result {
        let width = image.width
        let height = image.height
        guard let apertureRect = ApertureGeometry.centeredSquare(
            at: point,
            aperture: aperture,
            imageWidth: width,
            imageHeight: height
        ) else {
            throw SamplingError.noPixelsInAperture
        }

        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: linearSRGB,
            bitmapInfo: bitmapInfo
        ) else {
            throw SamplingError.pixelConversionFailed
        }
        context.interpolationQuality = .none
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        var colors: [LinearRGB] = []
        colors.reserveCapacity(apertureRect.width * apertureRect.height)
        for y in apertureRect.y..<(apertureRect.y + apertureRect.height) {
            for x in apertureRect.x..<(apertureRect.x + apertureRect.width) {
                let offset = y * bytesPerRow + x * 4
                let alpha = CGFloat(pixels[offset + 3]) / 255
                guard alpha > 0 else { continue }
                colors.append(
                    LinearRGB(
                        red: CGFloat(pixels[offset]) / 255 / alpha,
                        green: CGFloat(pixels[offset + 1]) / 255 / alpha,
                        blue: CGFloat(pixels[offset + 2]) / 255 / alpha
                    )
                )
            }
        }
        guard let color = LinearColorAverage.of(colors) else {
            throw SamplingError.noPixelsInAperture
        }
        return Result(
            color: color,
            apertureRect: apertureRect
        )
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
