# Changelog

## [1.2.12](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.11...v1.2.12) (2026-08-30)


### Bug Fixes

* restore Google translation metadata ([9d4684e](https://github.com/Mapleeeeeeeeeee/Lex/commit/9d4684e76f0f90091d594b7aaa32e12f0401dc1f))
* switch Google translation to clients5 endpoint ([8c529bb](https://github.com/Mapleeeeeeeeeee/Lex/commit/8c529bbc6de2c5dace5c763fba03a81441a358af))

## [1.2.11](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.10...v1.2.11) (2026-05-27)


### Bug Fixes

* prevent zip/dmg from re-triggering build with ad-hoc signing ([730eab6](https://github.com/Mapleeeeeeeeeee/Lex/commit/730eab6c496717c2423a95f349fb2f2fcfdfc5bd))

## [1.2.10](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.9...v1.2.10) (2026-05-27)


### Bug Fixes

* increase line limits for long text translation display ([1d6f5ce](https://github.com/Mapleeeeeeeeeee/Lex/commit/1d6f5ce23327e0a3d2aeb9a0bb0613f20d052fd8))

## [1.2.9](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.8...v1.2.9) (2026-05-25)


### Bug Fixes

* commit appcast before pull --rebase to avoid unstaged changes error ([6eb3176](https://github.com/Mapleeeeeeeeeee/Lex/commit/6eb3176e494582c02085b4fc7951c12fb8852752))

## [1.2.8](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.7...v1.2.8) (2026-05-23)


### Bug Fixes

* resolve CI signing identity with regex and fix appcast push conflict ([1f9d11d](https://github.com/Mapleeeeeeeeeee/Lex/commit/1f9d11d36a9a0bd05feb1d04c01ad5ce44c0be81))

## [1.2.7](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.6...v1.2.7) (2026-05-23)


### Bug Fixes

* use find-identity without -v flag to include untrusted certs ([aacb16a](https://github.com/Mapleeeeeeeeeee/Lex/commit/aacb16a5c89d0060b5a0b209232f5647d5cb878c))

## [1.2.6](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.5...v1.2.6) (2026-05-23)


### Bug Fixes

* use find-identity without trust requirement in CI signing ([0d511d7](https://github.com/Mapleeeeeeeeeee/Lex/commit/0d511d70ee7fdbec3dcf19726e20c8552cf9d346))

## [1.2.5](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.4...v1.2.5) (2026-05-23)


### Bug Fixes

* trust self-signed certificate in CI for codesign identity lookup ([37d2eda](https://github.com/Mapleeeeeeeeeee/Lex/commit/37d2eda469c52d93d09defee1a89d296231772ce))

## [1.2.4](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.3...v1.2.4) (2026-05-23)


### Bug Fixes

* add build.keychain to keychain search list for CI signing ([0edeec2](https://github.com/Mapleeeeeeeeeee/Lex/commit/0edeec2af57c43cc75080117890eeacfba48961a))
* trigger release for CI signing pipeline test ([71a1dc8](https://github.com/Mapleeeeeeeeeee/Lex/commit/71a1dc8b8cf08429e3c42d6d55af1d4dfc1de458))

## [1.2.3](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.2...v1.2.3) (2026-05-23)


### Bug Fixes

* sign release builds with self-signed certificate for stable identity ([d8e75a6](https://github.com/Mapleeeeeeeeeee/Lex/commit/d8e75a66b4744ca11d14cd982fc15bedbe0daf57))
* use proper macOS squircle icon format (824x824 with 100px gutter) ([63d3506](https://github.com/Mapleeeeeeeeeee/Lex/commit/63d3506c0dc059df4e94639e89dae641427ef250))

## [1.2.2](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.1...v1.2.2) (2026-05-23)


### Bug Fixes

* update app icon with rounded corners and add menu bar hide option ([2336503](https://github.com/Mapleeeeeeeeeee/Lex/commit/2336503455ed8f5f03ef4a15d3f5d93284857235))

## [1.2.1](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.2.0...v1.2.1) (2026-05-22)


### Bug Fixes

* auto-terminate conflicting Lex instance on launch ([b2fb7c6](https://github.com/Mapleeeeeeeeeee/Lex/commit/b2fb7c69ddd95f7bafded573f98c48c13697ec5a))

## [1.2.0](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.1.16...v1.2.0) (2026-05-22)


### Features

* add dictionary-style POS display and dev build separation ([4be0b2a](https://github.com/Mapleeeeeeeeeee/Lex/commit/4be0b2acef01afdf0bf52bce41f0ce59ee918a16))


### Bug Fixes

* add icon to launch-at-login menu item ([47c0efc](https://github.com/Mapleeeeeeeeeee/Lex/commit/47c0efc8b2c807cfa6fffe831d215c26cf1e70a7))
* remove duplicate release workflow that conflicts with release-please ([ac1673f](https://github.com/Mapleeeeeeeeeee/Lex/commit/ac1673f2b330be87f11b5550e1f685706083d44e))

## [1.1.16] - 2026-03-06

### Fixed

* 統一 README 預覽圖與 App / About 使用同一套 AppIcon 圖示來源

## [1.1.15] - 2026-03-06

### Fixed

* 發佈後續測試版本，用於驗證 `1.1.14` 到 `1.1.15` 的 Sparkle 自動更新流程

## [1.1.14] - 2026-03-06

### Fixed

* 修正 Sparkle nested helper 的簽章與驗證流程，避免自動更新卡在 installer 啟動階段
* 明確定義官方 release 的自動更新支援路徑，並補充舊版需手動重裝一次的升級說明

## [1.1.13](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.1.12...v1.1.13) (2026-03-06)


### Bug Fixes

* explicit empty trigger for debug release ([b3291b9](https://github.com/Mapleeeeeeeeeee/Lex/commit/b3291b9d25d210db382eab91236a22d9819f95bc))

## [1.1.12](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.1.11...v1.1.12) (2026-03-06)


### Bug Fixes

* un-ignore and track Sparkle Updater.app previously blocked by .gitignore ([5a06f3f](https://github.com/Mapleeeeeeeeeee/Lex/commit/5a06f3fde60db4db7ec62038f8fd8019cf76f2ed))

## [1.1.11](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.1.10...v1.1.11) (2026-03-06)


### Bug Fixes

* preserve sparkle framework symlinks with cp -a and add zh_TW.lproj to bundle to fix english ui ([736b028](https://github.com/Mapleeeeeeeeeee/Lex/commit/736b0282eed91373e4b6a4e3b2a608e8d653969e))

## [1.1.10](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.1.9...v1.1.10) (2026-03-06)


### Bug Fixes

* orchestrate macos build and appcast generation natively inside release-please workflow ([23e8713](https://github.com/Mapleeeeeeeeeee/Lex/commit/23e8713a10d194c2497d56601b3c5cc244fe36b9))

## [1.1.9](https://github.com/Mapleeeeeeeeeee/Lex/compare/v1.1.8...v1.1.9) (2026-03-06)


### Bug Fixes

* resolve sparkle update size mismatch by fully automating release pipeline ([6760dfc](https://github.com/Mapleeeeeeeeeee/Lex/commit/6760dfce59c2b53b23741e41c275af642d30be36))

## [1.1.8] - 2026-03-06
### Fixed
- 🌐 **Traditional Chinese Localization**: Configured `Info.plist` to correctly identify Lex as a Traditional Chinese app, enabling Sparkle's auto-update interface to display correctly in Chinese.
- 🔗 **Update Download URL**: Fixed an issue where Sparkle couldn't download the update because the feed URL incorrectly pointed to GitHub Pages rather than the actual GitHub Releases repository limit.

## [1.1.7] - 2026-03-06
### Fixed
- 🛠️ **Accessibility Permission Workflow**: Improved the startup dialog and added a "Check Accessibility Permission..." menu item, allowing users to troubleshoot translation hotkey issues without restarting Lex.

## [1.1.6] - 2026-03-06
### Added
- 🔄 **Sparkle Auto-Update Integration**: Lex now automatically checks for updates and handles seamless, secure downloads via GitHub Releases without needing manual `.dmg` re-installation!

## [1.1.5] - 2026-03-06
### Added
- 🔊 **English Phonetic Symbols (IPA)**: Display standard pronunciation brackets underneath the original text when querying English words.

## [1.1.4] - 2026-03-06
### Added
- 🔠 **Zhuyin Disambiguation**: Implemented "Primary Reading Heuristic" to pick the most common reading for polyphones (e.g., "開發中" now shows `ㄓㄨㄥ`).
- 🎨 **Enhanced UI/UX**: Replaced plain Zhuyin text with stylized **Bopomofo Badges** in the translation panel.
- 🔊 **Better Pronunciation**: 
    - Prioritized **Taiwanese-accented** voices (`zh-TW`, `Meijia`) for Chinese text.
    - Native English voice support for English text (Samantha/Alex).
- ⚖️ **License Info**: Added Apache 2.0 license info to the "About" window.
- 🛠️ **Dev Improvements**: Better versioning scripts and build automation.

## [1.1.3] - 2025-03-05
### Added
- 🚀 **Accessibility Check**: Auto-prompt for Accessibility permissions on startup.
- 🎨 **About Window**: New high-resolution icon and custom SwiftUI About view.

## [1.1.2] - 2025-03-04
- Added README.en.md and basic translation logic.
