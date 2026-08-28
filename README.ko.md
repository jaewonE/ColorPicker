# ColorPicker

ColorPicker는 현재 마우스 위치의 색상을 읽는 작은 macOS 네이티브 앱입니다. 모니터 이름을 표시하지 않는 형태로, macOS 디지털 컬러 측정기의 간결한 흐름과 유사한 화면 구성을 사용합니다.

English documentation: [README.md](README.md)

## 기능

- Apple ScreenCaptureKit으로 현재 커서 주변을 캡처합니다.
- 좌측에 픽셀 단위로 확대된 미리보기와 실제 샘플 조리개 테두리를 표시합니다.
- `1 × 1`, `2 × 2`, `4 × 4`, `8 × 8`, `16 × 16`, `32 × 32` 실제 화면 픽셀 조리개를 지원합니다.
- `0.5×`, `1×`, `2×`, `4×`, `8×` 영역 확대를 지원합니다. 이는 좌측 미리보기만 바꾸며 색상 측정 조리개에는 영향을 주지 않습니다.
- `RGB`, `RGB (normalized)`, `sRGB`, `sRGB (normalized)`, `P3`, `Hex` 형식으로 표시합니다.
- 색상 값 영역을 클릭하면 현재 값이 클립보드에 복사됩니다.
- 전역 단축키로 좌표를 고정하고 최신 샘플을 복사합니다.

## 대표 색상 선정 방식

조리개가 1픽셀보다 큰 경우 ColorPicker는 캡처된 모든 픽셀을 선형 sRGB로 변환한 뒤 R, G, B 성분을 산술 평균합니다. 이후 선택한 색상 공간으로 변환해 표시합니다. 이 방식은 빛의 양을 기준으로 한 평균이며, macOS 디지털 컬러 측정기에서 다중 픽셀 조리개에 사용하는 평균 방식과도 일치합니다.

**영역 확대**는 조리개와 독립적으로 작동합니다.

| 값 | 미리보기 동작 |
| --- | --- |
| 0.5× | 더 넓은 실제 영역을 보여 줍니다. |
| 1× | 기본 영역입니다. |
| 2× / 4× / 8× | 더 작은 실제 영역을 크게 보여 줍니다. |

포인터가 화면 가장자리에 있을 때도 가능한 한 요청한 정사각형 조리개 크기를 유지하도록 안쪽으로 이동합니다.

## 색상 형식과 복사 값

| 형식 | 표시 범위 | 복사 예시 |
| --- | --- | --- |
| RGB | Generic calibrated RGB, 0–255 | `210, 210, 210` |
| RGB (normalized) | Generic calibrated RGB, 0.000–1.000 | `0.823, 0.823, 0.823` |
| sRGB | IEC sRGB, 0–255 | `210, 210, 210` |
| sRGB (normalized) | IEC sRGB, 0.000–1.000 | `0.823, 0.823, 0.823` |
| P3 | Display P3, 0–255 | `210, 210, 210` |
| Hex | 대문자 6자리 sRGB | `#D2D2D2` |

여러 색상 성분은 `, `로 연결해 복사하며, Hex는 단일 값만 복사합니다.

## 단축키

| 단축키 | 동작 |
| --- | --- |
| Command-Shift-F | 좌표 고정을 전환합니다. 고정되면 조리개는 고정한 순간의 커서 위치에 남습니다. |
| Command-Shift-S | 현재 위치 또는 고정된 위치를 다시 캡처하고 선택한 형식으로 클립보드에 복사합니다. |

단축키는 다른 앱이 활성화된 상태에서도 동작하도록 전역 등록됩니다. ColorPicker 메뉴에서도 같은 동작을 사용할 수 있습니다.

## 설치

[Releases](https://github.com/jaewonE/ColorPicker/releases)에서 최신 `ColorPicker-*-macOS-arm64.zip`와 `.sha256` 파일을 받은 뒤 다음을 실행합니다.

```zsh
cd ~/Downloads
shasum -a 256 -c ColorPicker-*-macOS-arm64.zip.sha256
unzip ColorPicker-*-macOS-arm64.zip
mv ColorPicker.app /Applications/
open /Applications/ColorPicker.app
```

최초 실행 시 macOS 화면 픽셀 보호 정책 때문에 **화면 기록** 권한이 필요합니다. 앱의 **권한 요청** 버튼을 누르고, macOS가 열어 주는 시스템 설정에서 ColorPicker를 허용한 뒤 앱을 다시 여십시오. 릴리스는 notarization이 아닌 ad-hoc 서명 상태이므로, 다운로드한 앱을 Gatekeeper가 막으면 한 번 Control-클릭 후 **열기**를 선택하면 됩니다.

## 소스에서 빌드

필요 사항: macOS 14 이상, Xcode 16 이상, Apple Silicon.

```zsh
swift test
./Scripts/build_app.sh
./Scripts/package_release.sh
./Scripts/install_app.sh
```

`build_app.sh`는 `dist/ColorPicker.app`을 만들고, `package_release.sh`는 ZIP과 SHA-256 체크섬을 만들며, `install_app.sh`는 앱을 `/Applications/ColorPicker.app`에 설치합니다.

## 개인정보 및 제한 사항

ColorPicker에는 설정 화면, 네트워크 통신, 분석 수집, 영구 색상 기록이 없습니다. 라이브 미리보기와 색상 값을 위해 필요한 작은 화면 영역만 캡처합니다. SDR 출력 기준으로 샘플링하므로, 확장 다이내믹 레인지 콘텐츠는 앱의 SDR 경로로 변환되며 원본 HDR 장면 값이 보존되지 않을 수 있습니다.

## 라이선스

[GNU GPL v3.0](LICENSE)
