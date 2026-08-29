import CoreGraphics
import Testing
@testable import ColorPickerCore

struct ColorModelsTests {
    @Test func hexUsesUppercaseSixDigitSRGB() {
        let value = ColorFormatter.presentation(
            for: LinearRGB(red: 1, green: 0, blue: 0),
            format: .hex
        )
        #expect(value.values == ["#FF0000"])
        #expect(value.clipboardText == "#FF0000")
    }

    @Test func componentFormatsJoinClipboardValuesWithCommaAndSpace() {
        let value = ColorFormatter.presentation(
            for: .white,
            format: .sRGB
        )
        #expect(value.labels == ["R", "G", "B"])
        #expect(value.values == ["255", "255", "255"])
        #expect(value.clipboardText == "255, 255, 255")
    }

    @Test func normalizedValuesKeepThreeDecimalPlaces() {
        let value = ColorFormatter.presentation(for: .white, format: .rgbNormalized)
        #expect(value.values == ["1.000", "1.000", "1.000"])
        #expect(value.clipboardText == "1.000, 1.000, 1.000")
    }

    @Test func apertureMovesInBoundsAtAnImageEdge() {
        let rect = ApertureGeometry.centeredSquare(
            at: CGPoint(x: 0, y: 0),
            aperture: 4,
            imageWidth: 10,
            imageHeight: 10
        )
        #expect(rect == PixelRect(x: 0, y: 0, width: 4, height: 4))
    }

    @Test func apertureCentersWhenThereIsEnoughSpace() {
        let rect = ApertureGeometry.centeredSquare(
            at: CGPoint(x: 5, y: 5),
            aperture: 4,
            imageWidth: 12,
            imageHeight: 12
        )
        #expect(rect == PixelRect(x: 3, y: 3, width: 4, height: 4))
    }

    @Test func representativeColorIsTheLinearArithmeticMean() {
        let average = LinearColorAverage.of([
            LinearRGB(red: 0, green: 0, blue: 0),
            LinearRGB(red: 1, green: 1, blue: 1)
        ])
        #expect(average == LinearRGB(red: 0.5, green: 0.5, blue: 0.5))
    }

    @Test func areaZoomDefaultsToOneTimes() {
        #expect(SamplingOptions.areaZooms[SamplingOptions.defaultAreaZoomIndex] == 1)
    }

    @Test func captureRectConvertsPhysicalPixelsToDisplayPoints() {
        let rect = ScreenCaptureGeometry.captureRect(
            at: CGPoint(x: 100, y: 80),
            pixelSide: 24,
            displayBounds: CGRect(x: 0, y: 0, width: 500, height: 300),
            pixelScale: 2
        )
        #expect(rect == CGRect(x: 94, y: 74, width: 12, height: 12))
    }

    @Test func backingScaleUsesPhysicalModePixelsOnRetina() {
        let scale = ScreenCaptureGeometry.backingScale(
            displayBounds: CGRect(x: -672, y: 1440, width: 1440, height: 900),
            backingPixelWidth: 2880,
            backingPixelHeight: 1800
        )
        #expect(scale == 2)
    }

    @Test func captureRectSnapsFractionalPointerToBackingPixelGrid() {
        let rect = ScreenCaptureGeometry.captureRect(
            at: CGPoint(x: 100.37, y: 80.62),
            pixelSide: 24,
            displayBounds: CGRect(x: 0, y: 0, width: 500, height: 300),
            pixelScale: 2
        )
        #expect(rect == CGRect(x: 94, y: 74.5, width: 12, height: 12))
    }

    @Test func captureRectStaysInsideNegativeOriginDisplay() {
        let rect = ScreenCaptureGeometry.captureRect(
            at: CGPoint(x: -500, y: 0),
            pixelSide: 32,
            displayBounds: CGRect(x: -500, y: 0, width: 500, height: 300),
            pixelScale: 2
        )
        #expect(rect == CGRect(x: -500, y: 0, width: 16, height: 16))
    }

    @Test func imagePointMapsThePointerIntoCapturedPixels() {
        let point = ScreenCaptureGeometry.imagePoint(
            for: CGPoint(x: 100, y: 80),
            captureRect: CGRect(x: 94, y: 74, width: 12, height: 12),
            imageWidth: 24,
            imageHeight: 24
        )
        #expect(point == CGPoint(x: 12, y: 12))
    }

    @Test func imagePointSelectsThePixelContainingAFractionalPointer() {
        let point = ScreenCaptureGeometry.imagePoint(
            for: CGPoint(x: 100.49, y: 80.49),
            captureRect: CGRect(x: 94, y: 74, width: 12, height: 12),
            imageWidth: 24,
            imageHeight: 24
        )
        #expect(point == CGPoint(x: 12, y: 12))
    }
}
