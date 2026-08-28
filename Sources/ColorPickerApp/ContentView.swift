import AppKit
import SwiftUI
import ColorPickerCore

struct ContentView: View {
    @ObservedObject var sampler: ScreenSampler

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer(minLength: 0)
                Picker("Color format", selection: $sampler.colorFormat) {
                    ForEach(ColorFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 222)
                .accessibilityLabel("고유 값으로 표시")
            }

            HStack(alignment: .top, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    MagnifierPreview(
                        image: sampler.previewImage,
                        apertureRect: sampler.apertureRect,
                        imagePixelSize: sampler.previewPixelSize,
                        isLocked: sampler.isPositionLocked,
                        status: sampler.status,
                        requestPermission: sampler.requestScreenRecordingPermission
                    )

                    SamplingSlider(
                        title: "조리개 크기",
                        valueText: "\(sampler.apertureSize)px × \(sampler.apertureSize)px",
                        value: Binding(
                            get: { Double(sampler.apertureIndex) },
                            set: { sampler.apertureIndex = Int($0.rounded()) }
                        ),
                        range: 0...Double(ScreenSampler.apertureSizes.count - 1)
                    )
                    .onChange(of: sampler.apertureIndex) { _, _ in
                        sampler.refreshForControlChange()
                    }

                    SamplingSlider(
                        title: "영역 확대",
                        valueText: "\(zoomText(sampler.areaZoom))×",
                        value: Binding(
                            get: { Double(sampler.areaZoomIndex) },
                            set: { sampler.areaZoomIndex = Int($0.rounded()) }
                        ),
                        range: 0...Double(ScreenSampler.areaZooms.count - 1)
                    )
                    .onChange(of: sampler.areaZoomIndex) { _, _ in
                        sampler.refreshForControlChange()
                    }
                }
                .frame(width: 156)

                ColorReadout(
                    color: ColorFormatter.swatchColor(for: sampler.sampledColor),
                    presentation: sampler.currentPresentation,
                    copiedText: sampler.copiedText,
                    copy: sampler.copyCurrentColor
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .frame(width: 424, height: 336)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func zoomText(_ value: CGFloat) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", Double(value))
    }
}

private struct SamplingSlider: View {
    let title: String
    let valueText: String
    let value: Binding<Double>
    let range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Slider(value: value, in: range, step: 1)
                .controlSize(.small)
            HStack(spacing: 3) {
                Text(title)
                Spacer(minLength: 2)
                Text(valueText)
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 10.5))
        }
    }
}

private struct MagnifierPreview: View {
    let image: NSImage?
    let apertureRect: PixelRect?
    let imagePixelSize: CGSize
    let isLocked: Bool
    let status: ScreenSampler.Status
    let requestPermission: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(nsColor: .controlBackgroundColor))

            if let image {
                GeometryReader { proxy in
                    ZStack {
                        Image(nsImage: image)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()

                        if let apertureRect,
                           imagePixelSize.width > 0,
                           imagePixelSize.height > 0 {
                            Rectangle()
                                .stroke(Color.black.opacity(0.85), lineWidth: 1)
                                .frame(
                                    width: max(2, CGFloat(apertureRect.width) / imagePixelSize.width * proxy.size.width),
                                    height: max(2, CGFloat(apertureRect.height) / imagePixelSize.height * proxy.size.height)
                                )
                                .position(
                                    x: (CGFloat(apertureRect.x) + CGFloat(apertureRect.width) / 2) / imagePixelSize.width * proxy.size.width,
                                    y: (CGFloat(apertureRect.y) + CGFloat(apertureRect.height) / 2) / imagePixelSize.height * proxy.size.height
                                )
                        }
                    }
                }
            } else if case .needsScreenRecordingPermission = status {
                VStack(spacing: 7) {
                    Text("화면 기록 권한이 필요합니다")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 11, weight: .medium))
                    Button("권한 요청") {
                        requestPermission()
                    }
                    .controlSize(.small)
                }
                .padding(8)
            } else if case let .failed(message) = status {
                Text(message)
                    .font(.system(size: 10.5))
                    .multilineTextAlignment(.center)
                    .padding(8)
            }

            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .padding(5)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.7), radius: 1)
                    .accessibilityLabel("좌표 고정됨")
            }
        }
        .frame(width: 156, height: 156)
        .overlay(Rectangle().stroke(Color.black.opacity(0.12), lineWidth: 1))
        .clipped()
    }
}

private struct ColorReadout: View {
    let color: NSColor
    let presentation: ColorValuePresentation
    let copiedText: String?
    let copy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(nsColor: color))
                .overlay(Rectangle().stroke(Color.black.opacity(0.16), lineWidth: 1))
                .frame(width: 72, height: 72)
                .accessibilityLabel("Current sampled color")

            Button(action: copy) {
                VStack(alignment: .leading, spacing: 5) {
                    if presentation.isSingleValue {
                        Text(presentation.values[0])
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.primary)
                    } else {
                        ForEach(Array(zip(presentation.labels, presentation.values)), id: \.0) { label, value in
                            HStack(spacing: 8) {
                                Text("\(label):")
                                    .frame(width: 18, alignment: .trailing)
                                Text(value)
                            }
                        }
                    }
                }
                .font(.system(size: 13, design: .monospaced))
                .frame(minWidth: 132, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Click to copy \(presentation.clipboardText)")
            .accessibilityLabel("Copy color value")

            if copiedText != nil {
                Label("클립보드에 복사됨", systemImage: "checkmark")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(.secondary)
            } else {
                Text("클릭하여 복사")
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 2)
    }
}
