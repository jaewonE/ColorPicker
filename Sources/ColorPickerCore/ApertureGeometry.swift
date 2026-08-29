import CoreGraphics
import Foundation

public enum SamplingOptions {
    public static let apertureSizes = [1, 2, 4, 8, 16, 32]
    public static let areaZooms: [CGFloat] = [0.5, 1, 2, 4, 8]
    public static let defaultAreaZoomIndex = 1
}

public struct PixelRect: Equatable, Sendable {
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int

    public init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

public enum ApertureGeometry {
    /// Returns an in-bounds square aperture. At a display edge, the aperture is
    /// shifted just enough to retain its requested pixel dimensions.
    public static func centeredSquare(
        at point: CGPoint,
        aperture: Int,
        imageWidth: Int,
        imageHeight: Int
    ) -> PixelRect? {
        guard aperture > 0, imageWidth > 0, imageHeight > 0 else { return nil }

        let side = min(aperture, imageWidth, imageHeight)
        let pointX = Int(point.x.rounded())
        let pointY = Int(point.y.rounded())
        let x = min(max(0, pointX - side / 2), imageWidth - side)
        let y = min(max(0, pointY - side / 2), imageHeight - side)
        return PixelRect(x: x, y: y, width: side, height: side)
    }
}

public enum LinearColorAverage {
    /// Computes an arithmetic mean in linear-light sRGB.
    public static func of(_ colors: [LinearRGB]) -> LinearRGB? {
        guard !colors.isEmpty else { return nil }
        let total = colors.reduce(LinearRGB(red: 0, green: 0, blue: 0)) { partial, color in
            LinearRGB(
                red: partial.red + color.red,
                green: partial.green + color.green,
                blue: partial.blue + color.blue
            )
        }
        let count = CGFloat(colors.count)
        return LinearRGB(
            red: total.red / count,
            green: total.green / count,
            blue: total.blue / count
        )
    }
}
