# Changelog

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
