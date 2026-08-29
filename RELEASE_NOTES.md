# ColorPicker 1.0.4

This patch corrects ColorPicker's window-close lifecycle.

- Closing the last ColorPicker window now terminates the application process.
- ColorPicker consequently disappears from the Command-Tab app switcher instead of remaining active without a window.
- Process-scoped resources such as the sampling timer and global shortcut handlers are released with application termination.

The ZIP is ad-hoc signed for Apple Silicon macOS 14+. After replacing an older ad-hoc build, Screen Recording permission may need to be granted again as described in the README.

---

# ColorPicker 1.0.4 (한국어)

이번 패치에서는 ColorPicker 창 닫기 동작과 앱 생명주기를 수정했습니다.

- 마지막 ColorPicker 창을 닫으면 앱 프로세스도 종료됩니다.
- 창이 없는 상태로 Command-Tab 앱 전환기에 남아 있지 않습니다.
- 앱 종료와 함께 샘플링 타이머와 전역 단축키 핸들러 등 프로세스 단위 리소스도 해제됩니다.

ZIP은 Apple Silicon용 macOS 14 이상에서 동작하도록 ad-hoc 서명되어 있습니다. 이전 ad-hoc 빌드를 교체한 뒤에는 README 안내에 따라 화면 기록 권한을 다시 부여해야 할 수 있습니다.
