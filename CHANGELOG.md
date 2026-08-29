# Changelog

All notable changes to this project are documented in this file.

## 1.0.1 — 2026-08-29

- Replaced the unreliable CoreGraphics preflight gate with a real ScreenCaptureKit capture attempt, so an already-authorized app can begin sampling immediately.
- Added clear checking, retry, and System Settings paths for unavailable Screen Recording access.
- Added a stable ad-hoc designated requirement so a Screen Recording grant remains valid across future ColorPicker updates.
- Kept area zoom at its specified default of 1× and added a regression test for it.
- Reworked the window into a compact layout: the format menu spans the color swatch/readout column, values sit beside the swatch, and both sliders share one horizontal row.

## 1.0.0 — 2026-08-28

- Initial native macOS ColorPicker release.
- Added ScreenCaptureKit-based cursor sampling, a pixelated magnifier, and square aperture sizes from 1 to 32 pixels.
- Added area zoom, six color output formats, click-to-copy, and global coordinate-lock and save shortcuts.
- Added English and Korean documentation, build/package/install scripts, SHA-256 release packaging, and a GitHub Actions build workflow.
- Licensed the project under GNU GPL v3.0.
