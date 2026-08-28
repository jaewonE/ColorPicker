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
}
