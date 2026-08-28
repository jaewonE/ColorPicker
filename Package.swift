// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ColorPicker",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "ColorPickerCore", targets: ["ColorPickerCore"]),
        .executable(name: "ColorPicker", targets: ["ColorPickerApp"])
    ],
    targets: [
        .target(name: "ColorPickerCore"),
        .executableTarget(
            name: "ColorPickerApp",
            dependencies: ["ColorPickerCore"],
            linkerSettings: [
                .linkedFramework("ScreenCaptureKit"),
                .linkedFramework("Carbon")
            ]
        ),
        .testTarget(
            name: "ColorPickerCoreTests",
            dependencies: ["ColorPickerCore"]
        )
    ]
)
