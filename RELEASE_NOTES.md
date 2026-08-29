# ColorPicker 1.0.3

This patch restores pixel-sharp magnifier output on Retina displays.

- Retina scale now comes from the display mode's backing pixel dimensions. On a MacBook configured as `1440 × 900`, ColorPicker correctly uses the `2880 × 1800` backing surface and a scale of `2.0`.
- Capture rectangles are aligned to physical pixel boundaries, including when the pointer reports fractional screen coordinates.
- ScreenCaptureKit no longer downsamples twice as many Retina pixels into the requested output size before the magnifier renders them.
- Regression tests cover Retina scaling, fractional pointer alignment, negative-origin displays, aperture geometry, color averaging, and clipboard formatting.

The ZIP is ad-hoc signed for Apple Silicon macOS 14+. After replacing an older ad-hoc build, Screen Recording permission may need to be granted again as described in the README.

---

# ColorPicker 1.0.3 (한국어)

이번 패치에서는 Retina 화면의 확대 미리보기가 원본 픽셀처럼 선명하게 보이도록 수정했습니다.

- Retina 배율을 디스플레이 모드의 실제 backing 픽셀 크기로 계산합니다. `1440 × 900`으로 설정된 MacBook 화면에서는 `2880 × 1800` backing surface와 `2.0` 배율을 사용합니다.
- 포인터 좌표에 소수점이 포함되어도 캡처 영역을 실제 픽셀 경계에 맞춥니다.
- ScreenCaptureKit이 요청한 출력 크기를 만들기 전에 두 배 많은 Retina 픽셀을 축소하던 문제를 제거했습니다.
- Retina 배율, 소수점 포인터 정렬, 음수 원점 모니터, 조리개, 색상 평균 및 클립보드 형식에 대한 회귀 테스트를 추가했습니다.

ZIP은 Apple Silicon용 macOS 14 이상에서 동작하도록 ad-hoc 서명되어 있습니다. 이전 ad-hoc 빌드를 교체한 뒤에는 README 안내에 따라 화면 기록 권한을 다시 부여해야 할 수 있습니다.
