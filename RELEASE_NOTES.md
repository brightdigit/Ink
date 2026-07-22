# Release Notes

This is a BrightDigit fork of [Ink](https://github.com/JohnSundell/Ink) by John Sundell,
maintained for the BrightDigit site toolchain. Original work © 2019 John Sundell; modifications
© 2026 BrightDigit. Distributed under the original MIT License — see `LICENSE` and `NOTICE`.

## Unreleased

- Adopted the BrightDigit Swift 6.4 toolchain and standalone CI template
  (`.github/workflows/Ink.yml`), pinning the nightly-6.4.x toolchain via `.swift-version`,
  `.devcontainer`, `.mise.toml`, and `.spi.yml`.
- Migrated the `Ink` and `InkCLI` sources and the `InkTests` suite to Swift 6 with strict
  concurrency, updating `Package.swift`/`Package.resolved` accordingly.
- Added BrightDigit tooling: SwiftLint/swift-format configuration, `Scripts/lint.sh` and
  `Scripts/header.sh`, Periphery config, and Claude Code review/automation workflows.
