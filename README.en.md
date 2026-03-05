# Lex

<p align="center">
  <img src="Assets/icon.png" width="128" height="128" alt="Lex Icon">
</p>

<p align="center">
  <strong>Double-press the Command key for instant text translation</strong>
</p>

<p align="center">
  Native macOS translation tool · Lightweight and unobtrusive · Supports custom translation providers
</p>

[繁體中文](README.md) | English

---

## ✨ Features

- **Double-Press Command Trigger** — Select text and double-press ⌘ to translate instantly without switching windows.
- **Floating Translation Panel** — Glassmorphism effect, appears right next to the cursor, automatically dismisses when clicking elsewhere.
- **Read Aloud** — Built-in text-to-speech for the original text.
- **One-Click Copy** — Quickly copy the translation result to the clipboard.
- **Vocabulary Bookmarks** — Save frequently translated vocabulary and browse them anytime via the Menu Bar.
- **Extensible Providers** — Built with a Provider architecture to easily integrate DeepL, OpenAI, and more.
- **Precise Bopomofo (Zhuyin) Support** — Powered by the official Taiwan MOE Concise Dictionary (44k+ entries) with correct polyphone identification based on word context.

## 📦 Installation

### General Users (Recommended)

1. Go to the **[Releases](../../releases)** page and download the latest `Lex.dmg` or `Lex.app.zip`.
2. Extract the file or open the DMG, and drag `Lex.app` to your **Applications** folder.
3. **⚠️ Gatekeeper Workaround (App is damaged):** Because the app is not signed by an Apple Developer account, macOS may say "Lex.app is damaged and can't be opened." To fix this, open Terminal and run:
   ```bash
   xattr -cr /Applications/Lex.app
   ```
   After running this command, you can open the app normally.

### Developers (Build from Source)

Requirements: macOS 13.0+, Swift 5.9+

```bash
git clone https://github.com/Mapleeeeeeeeeee/Lex.git
cd Lex
make build
make run
```

### Required System Permissions

Upon first launch, Lex requires **Accessibility Permissions** to read selected text:

1. The system will automatically prompt you.
2. Go to "System Settings → Privacy & Security → Accessibility".
3. Find Lex (or Terminal if building from source) and toggle it on.

## 🚀 Usage

1. Select any text.
2. Quickly double-press the **Command (⌘)** key.
3. The translation panel will appear next to your cursor.

### Panel Features

| Button | Function |
|------|------|
| 🔊 | Read original text aloud |
| 📋 | Copy translation result |
| 🔖 | Bookmark / Remove bookmark |

### Menu Bar

Click the Lex icon in the Menu Bar to:
- View the currently active translation provider.
- Browse bookmarked vocabulary (⌘L).
- Quit the application.

## 🔌 Custom Translation Providers

Lex uses a Provider architecture, making it easy to add new translation sources:

```swift
class DeepLProvider: TranslationProvider {
    var name: String { "DeepL" }
    var identifier: String { "deepl" }
    
    func translate(text: String, from: String, to: String, completion: @escaping (String?, String?) -> Void) {
        // ... API call ...
        completion("Bonjour", "[bɔ̃ʒuʁ]")
    }
}

// Switch provider
TranslationService.shared.setProvider(DeepLProvider())
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## 🧪 Testing

```bash
make test
```

Tests follow a BDD naming style and parameterized testing, covering:
- Data models (TranslationItem)
- Vocabulary management (VocabularyManager)
- Service integration (TranslationService)
- Provider protocols
- MOE Concise Dictionary Bopomofo translation accuracy and polyphone handling

## 📚 Data Source

Bopomofo (Zhuyin) data source: [Ministry of Education "Concise Mandarin Chinese Dictionary"](https://dict.concised.moe.edu.tw/)  
License: [CC BY-ND 3.0 TW](https://creativecommons.org/licenses/by-nd/3.0/tw/)  
Copyright Holder: Ministry of Education, R.O.C.

### 🔠 Bopomofo Disambiguation Strategy (Polyphones)
Lex uses a **"Longest Match"** + **"Primary Reading Heuristic"** to handle characters with multiple readings:
- **Dictionary Word Priority**: Words like "龜裂" (fissure) are matched as complete entries from the dictionary, ensuring precise readings (e.g., `ㄐㄩㄣ ㄌㄧㄝˋ`) even if individual characters have multiple pronunciations.
- **Contextual Simplification**: In a multi-character phrase (e.g., "開發中"), if a character (like "中") has multiple dictionary readings (ㄓㄨㄥ/ㄓㄨㄥˋ), the system automatically picks the first (most common) reading as defined in the MOE Official List of Lexical Readings. This reduces visual clutter from slashes ( / ).
- **Single Character Full View**: When querying a single character alone, all possible readings are displayed for exploration.

## 📄 License

This project is licensed under the [Apache License 2.0](LICENSE).
