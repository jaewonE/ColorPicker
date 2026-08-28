import AppKit
import CoreGraphics
import Foundation

/// A color represented as linear-light sRGB components.
///
/// Aperture pixels are converted into this space before they are averaged, so a
/// multi-pixel sample represents light energy rather than a gamma-biased mean.
public struct LinearRGB: Equatable, Sendable {
    public var red: CGFloat
    public var green: CGFloat
    public var blue: CGFloat

    public init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public static let white = LinearRGB(red: 1, green: 1, blue: 1)

    public var clamped: LinearRGB {
        LinearRGB(
            red: red.clamped(to: 0...1),
            green: green.clamped(to: 0...1),
            blue: blue.clamped(to: 0...1)
        )
    }
}

public enum ColorFormat: String, CaseIterable, Identifiable, Sendable {
    case rgb = "RGB"
    case rgbNormalized = "RGB (normalized)"
    case sRGB = "sRGB"
    case sRGBNormalized = "sRGB (normalized)"
    case p3 = "P3"
    case hex = "Hex"

    public var id: String { rawValue }
}

public struct ColorValuePresentation: Equatable, Sendable {
    public let labels: [String]
    public let values: [String]
    public let clipboardText: String

    public init(labels: [String], values: [String], clipboardText: String) {
        self.labels = labels
        self.values = values
        self.clipboardText = clipboardText
    }

    public var isSingleValue: Bool { values.count == 1 }
}

public enum ColorFormatter {
    private static let linearSRGB = CGColorSpace(name: CGColorSpace.linearSRGB)!

    /// Converts the sampled linear-light color to the selected display format.
    public static func presentation(for color: LinearRGB, format: ColorFormat) -> ColorValuePresentation {
        switch format {
        case .rgb:
            return componentPresentation(color, colorSpace: .genericRGB, normalized: false)
        case .rgbNormalized:
            return componentPresentation(color, colorSpace: .genericRGB, normalized: true)
        case .sRGB:
            return componentPresentation(color, colorSpace: .sRGB, normalized: false)
        case .sRGBNormalized:
            return componentPresentation(color, colorSpace: .sRGB, normalized: true)
        case .p3:
            return componentPresentation(color, colorSpace: .displayP3, normalized: false)
        case .hex:
            let components = convertedComponents(color, colorSpace: .sRGB)
            let hex = String(
                format: "#%02X%02X%02X",
                locale: Locale(identifier: "en_US_POSIX"),
                integerComponent(components.red),
                integerComponent(components.green),
                integerComponent(components.blue)
            )
            return ColorValuePresentation(labels: ["Hex"], values: [hex], clipboardText: hex)
        }
    }

    public static func swatchColor(for color: LinearRGB) -> NSColor {
        let clamped = color.clamped
        let cgColor = CGColor(
            colorSpace: linearSRGB,
            components: [clamped.red, clamped.green, clamped.blue, 1]
        )
        return cgColor.flatMap(NSColor.init(cgColor:)) ?? .white
    }

    private static func componentPresentation(
        _ color: LinearRGB,
        colorSpace: NSColorSpace,
        normalized: Bool
    ) -> ColorValuePresentation {
        let components = convertedComponents(color, colorSpace: colorSpace)
        let values: [String]
        if normalized {
            values = [
                decimalComponent(components.red),
                decimalComponent(components.green),
                decimalComponent(components.blue)
            ]
        } else {
            values = [
                String(integerComponent(components.red)),
                String(integerComponent(components.green)),
                String(integerComponent(components.blue))
            ]
        }
        return ColorValuePresentation(
            labels: ["R", "G", "B"],
            values: values,
            clipboardText: values.joined(separator: ", ")
        )
    }

    private static func convertedComponents(_ color: LinearRGB, colorSpace: NSColorSpace) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        let source = swatchColor(for: color)
        let converted = source.usingColorSpace(colorSpace) ?? source.usingColorSpace(.sRGB) ?? .white
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        converted.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red.clamped(to: 0...1), green.clamped(to: 0...1), blue.clamped(to: 0...1))
    }

    private static func integerComponent(_ value: CGFloat) -> Int {
        Int((value.clamped(to: 0...1) * 255).rounded())
    }

    private static func decimalComponent(_ value: CGFloat) -> String {
        String(
            format: "%.3f",
            locale: Locale(identifier: "en_US_POSIX"),
            Double(value.clamped(to: 0...1))
        )
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
