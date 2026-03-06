# Changelog

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
