import AppKit
import SwiftUI
import ColorPickerCore

struct ContentView: View {
    @ObservedObject var sampler: ScreenSampler

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                MagnifierPreview(
                    image: sampler.previewImage,
                    apertureRect: sampler.apertureRect,
                    imagePixelSize: sampler.previewPixelSize,
                    isLocked: sampler.isPositionLocked,
                    status: sampler.status,
                    requestPermission: sampler.requestScreenRecordingPermission,
                    openSettings: sampler.openScreenRecordingSettings
                )

                VStack(alignment: .leading, spacing: 8) {
                    Picker("Color format", selection: $sampler.colorFormat) {
                        ForEach(ColorFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .controlSize(.small)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("고유 값으로 표시")

                    ColorReadout(
                        color: ColorFormatter.swatchColor(for: sampler.sampledColor),
                        presentation: sampler.currentPresentation,
                        copiedText: sampler.copiedText,
                        copy: sampler.copyCurrentColor
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, minHeight: 112, alignment: .top)
            }

            HStack(spacing: 10) {
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

                Divider()
                    .frame(height: 26)

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
        }
        .padding(10)
        .frame(width: 368, height: 188)
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
                    .monospacedDigit()
            }
            .font(.system(size: 10))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MagnifierPreview: View {
    let image: NSImage?
    let apertureRect: PixelRect?
    let imagePixelSize: CGSize
    let isLocked: Bool
    let status: ScreenSampler.Status
    let requestPermission: () -> Void
    let openSettings: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
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
            } else {
                statusView
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
        .frame(width: 112, height: 112)
        .overlay(Rectangle().stroke(Color.black.opacity(0.12), lineWidth: 1))
        .clipped()
    }

    @ViewBuilder
    private var statusView: some View {
        switch status {
        case .checking:
            VStack(spacing: 6) {
                ProgressView()
                    .controlSize(.small)
                Text("화면 캡처 권한 확인 중…")
                    .font(.system(size: 10.5, weight: .medium))
                    .multilineTextAlignment(.center)
            }
            .padding(8)
        case .needsScreenRecordingPermission:
            VStack(spacing: 5) {
                Text("화면 기록 권한이 필요합니다")
                    .font(.system(size: 10.5, weight: .medium))
                    .multilineTextAlignment(.center)
                Text("허용 상태인데도 실패하면 기존 항목을 제거한 뒤 다시 요청하세요")
                    .font(.system(size: 9.5))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("권한 다시 확인", action: requestPermission)
                    .controlSize(.mini)
                Button("시스템 설정 열기", action: openSettings)
                    .controlSize(.mini)
            }
            .padding(6)
        case let .failed(message):
            VStack(spacing: 5) {
                Text("화면 캡처를 시작할 수 없습니다")
                    .font(.system(size: 10.5, weight: .medium))
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.system(size: 9.5))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                Button("다시 시도", action: requestPermission)
                    .controlSize(.mini)
            }
            .padding(6)
        case .ready:
            EmptyView()
        }
    }
}

private struct ColorReadout: View {
    let color: NSColor
    let presentation: ColorValuePresentation
    let copiedText: String?
    let copy: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Rectangle()
                .fill(Color(nsColor: color))
                .overlay(Rectangle().stroke(Color.black.opacity(0.16), lineWidth: 1))
                .frame(width: 64, height: 64)
                .accessibilityLabel("Current sampled color")

            VStack(alignment: .leading, spacing: 5) {
                Button(action: copy) {
                    VStack(alignment: .leading, spacing: 4) {
                        if presentation.isSingleValue {
                            Text(presentation.values[0])
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(.primary)
                        } else {
                            ForEach(Array(zip(presentation.labels, presentation.values)), id: \.0) { label, value in
                                HStack(spacing: 7) {
                                    Text("\(label):")
                                        .frame(width: 18, alignment: .trailing)
                                    Text(value)
                                }
                            }
                        }
                    }
                    .font(.system(size: 12, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("색상 값을 클립보드에 복사")
                .accessibilityLabel("Copy color value")

                if copiedText != nil {
                    Label("클립보드에 복사됨", systemImage: "checkmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                } else {
                    Text("클릭하여 복사")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
