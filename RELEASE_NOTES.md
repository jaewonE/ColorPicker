# ColorPicker 1.0.1

This update fixes Screen Recording detection and substantially compacts the sampling window.

- ColorPicker now tries a real ScreenCaptureKit frame instead of treating a CoreGraphics preflight result as authoritative. An already-authorized app can start sampling without being trapped in the permission message.
- The magnifier now provides checking, retry, and System Settings actions when capture access is genuinely unavailable.
- The ad-hoc signature now has a stable designated requirement, preserving Screen Recording authorization through future app updates. If an earlier build was allowed, toggle ColorPicker off and on once in Screen Recording for this migration.
- Area zoom still starts at 1×.
- The format menu now fills the color-readout column, values are beside the swatch, and both sampling sliders sit in one compact horizontal row.

The ZIP is ad-hoc signed for Apple Silicon macOS 14+. On first use, grant Screen Recording permission so macOS can provide on-screen pixel data.

---

# ColorPicker 1.0.1 (한국어)

이번 업데이트에서는 화면 기록 권한 판정과 샘플링 창 배치를 개선했습니다.

- CoreGraphics 사전 검사만으로 권한을 판정하지 않고 실제 ScreenCaptureKit 캡처를 시도합니다. 이미 권한이 허용된 앱이 권한 안내 화면에 갇히지 않고 즉시 샘플링을 시작합니다.
- 권한을 실제로 사용할 수 없을 때에는 확인 중, 다시 확인, 시스템 설정 열기 동작을 제공합니다.
- ad-hoc 서명에 안정적인 지정 요구사항을 적용해 이후 앱 업데이트에도 화면 기록 권한이 유지됩니다. 이전 빌드를 이미 허용했다면 이 전환에서만 화면 기록 설정의 ColorPicker를 한 번 껐다 켜십시오.
- 영역 확대 기본값은 1×를 유지합니다.
- 형식 선택 메뉴는 색상 읽기 영역 너비를 채우고, 값은 색상 박스 오른쪽에 놓이며, 두 슬라이더는 한 줄에 나란히 배치됩니다.

ZIP은 Apple Silicon용 macOS 14 이상에서 동작하도록 ad-hoc 서명되어 있습니다. 최초 사용 시 화면 픽셀 데이터를 읽을 수 있도록 화면 기록 권한을 허용해야 합니다.
