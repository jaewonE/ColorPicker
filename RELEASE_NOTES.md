# ColorPicker 1.0.2

This update fixes Screen Recording access for the installed build and corrects the prior release's ad-hoc signing assumption.

- The app now includes the required Screen Recording usage description in English and Korean.
- On macOS 26, ColorPicker captures the rectangular pointer region directly and maps display points to physical pixels for Retina and multi-display layouts.
- Capture failures now record the ScreenCaptureKit error domain and code for diagnosis.
- The ineffective custom ad-hoc designated requirement has been removed. If an older permission record is bound to a previous binary hash, reset ColorPicker's Screen Recording record and grant it to the installed build again.
- The installed app was verified with a fresh permission grant and live cursor sampling on macOS 26.6.2.

The ZIP is ad-hoc signed for Apple Silicon macOS 14+. After replacing an older ad-hoc build, permission may need to be reset with `tccutil reset ScreenCapture com.jaewone.colorpicker`, granted again, and followed by one app relaunch.

---

# ColorPicker 1.0.2 (한국어)

이번 업데이트에서는 설치된 앱의 화면 기록 접근 문제를 수정하고, 이전 릴리스의 ad-hoc 서명 가정을 바로잡았습니다.

- 화면 기록 권한 요청에 필요한 용도 설명을 영어와 한국어로 추가했습니다.
- macOS 26에서는 포인터 주변 사각형을 직접 캡처하며, Retina 및 음수 원점 모니터 배치에서도 화면 좌표와 실제 픽셀을 올바르게 변환합니다.
- 캡처 실패 시 ScreenCaptureKit 오류 도메인과 코드를 기록하도록 진단 정보를 추가했습니다.
- 효과가 없었던 사용자 지정 ad-hoc 지정 요구사항을 제거했습니다. 이전 권한 레코드가 과거 바이너리 해시에 묶여 있다면 ColorPicker의 화면 기록 레코드를 초기화하고 현재 설치본에 다시 권한을 부여해야 합니다.
- macOS 26.6.2에서 새 권한을 부여한 설치본의 실시간 커서 샘플링을 확인했습니다.

ZIP은 Apple Silicon용 macOS 14 이상에서 동작하도록 ad-hoc 서명되어 있습니다. 이전 빌드를 교체한 뒤 권한 문제가 생기면 `tccutil reset ScreenCapture com.jaewone.colorpicker`로 ColorPicker 권한만 초기화하고 다시 허용한 다음 앱을 한 번 재실행하십시오.
