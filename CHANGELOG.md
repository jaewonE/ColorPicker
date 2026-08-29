# Changelog

All notable changes to this project are documented in this file.

## 1.0.3 — 2026-08-29

- Fixed Retina capture scale detection by using the display mode's backing pixel dimensions instead of its logical desktop dimensions.
- Aligned rectangular captures to the physical backing-pixel grid and selected the pixel containing fractional pointer coordinates.
- Prevented ScreenCaptureKit from downsampling a 2× Retina source before the magnifier enlarges it.
- Added regression coverage for the MacBook `1440 × 900` logical / `2880 × 1800` backing configuration and fractional pointer positions.

## 1.0.2 — 2026-08-29

- Added the required Screen Recording usage description, localized in English and Korean.
- Added a macOS 26 rectangular screenshot path that captures only the pointer region, plus initial display-point conversion and negative-origin display support.
- Added capture-stage diagnostics and geometry regression tests.
- Removed the ineffective custom ad-hoc designated requirement. Screen Recording records for ad-hoc builds can be bound to an obsolete code hash, so recovery now resets and re-grants permission for the installed build.
- Verified the installed app against a fresh ColorPicker-only Screen Recording grant and confirmed live sampling on macOS 26.6.2.

## 1.0.1 — 2026-08-29

- Replaced the unreliable CoreGraphics preflight gate with a real ScreenCaptureKit capture attempt, so an already-authorized app can begin sampling immediately.
- Added clear checking, retry, and System Settings paths for unavailable Screen Recording access.
- Attempted to stabilize ad-hoc identity across updates; 1.0.2 removes this because macOS can still bind Screen Recording access to the binary's code hash.
- Kept area zoom at its specified default of 1× and added a regression test for it.
- Reworked the window into a compact layout: the format menu spans the color swatch/readout column, values sit beside the swatch, and both sliders share one horizontal row.

## 1.0.0 — 2026-08-28

- Initial native macOS ColorPicker release.
- Added ScreenCaptureKit-based cursor sampling, a pixelated magnifier, and square aperture sizes from 1 to 32 pixels.
- Added area zoom, six color output formats, click-to-copy, and global coordinate-lock and save shortcuts.
- Added English and Korean documentation, build/package/install scripts, SHA-256 release packaging, and a GitHub Actions build workflow.
- Licensed the project under GNU GPL v3.0.
