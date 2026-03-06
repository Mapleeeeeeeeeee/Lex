# Lex

<p align="center">
  <img src="Assets/icon.png" width="128" height="128" alt="Lex Icon">
</p>

<p align="center">
  <strong>連按兩下 Command 鍵，即時翻譯選取文字</strong>
</p>

<p align="center">
  macOS 原生翻譯工具 · 輕量無干擾 · 支援自訂翻譯來源
</p>

繁體中文 | [English](README.en.md)

---

## ✨ 功能特色

- **雙擊 Command 觸發** — 選取文字後連按兩下 ⌘ 即可翻譯，不需切換視窗
- **浮動翻譯面板** — 毛玻璃效果，出現在游標旁邊，點擊外部自動消失
- **朗讀原文** — 內建語音朗讀功能
- **一鍵複製** — 快速複製翻譯結果到剪貼簿
- **收藏詞彙** — 書籤按鈕收藏常用翻譯，Menu Bar 隨時瀏覽
- **翻譯來源可擴充** — Provider 架構，輕鬆接入 DeepL、OpenAI 等

## 📦 安裝

### 一般使用者（推薦）

1. 前往 **[Releases](../../releases)** 頁面，下載最新的 `Lex.dmg` 或 `Lex.app.zip`
2. 將 `Lex.app` 拖曳到 **「應用程式 (Applications)」** 資料夾
3. **⚠️ 「檔案已損壞」解決方法：** 由於未經 Apple 開發者帳號簽名，macOS 可能會顯示「Lex.app 已損壞，無法打開」。請打開 **終端機 (Terminal)** 並輸入以下指令來解除安全限制：
   ```bash
   xattr -cr /Applications/Lex.app
   ```
   執行後即可正常開啟。
4. **⚠️ 舊版升級限制：** 如果您安裝的是早期版本，且內建更新出現 installer 或 download 錯誤，請先手動安裝一次最新官方 release。完成這次手動重裝後，後續版本才會恢復自動更新。

### 開發者（從原始碼編譯）

需求：macOS 13.0+、Swift 5.9+

```bash
git clone https://github.com/Mapleeeeeeeeeee/Lex.git
cd Lex
make build
make run
```

從原始碼自行編譯的 build 不在官方自動更新支援範圍內。Sparkle 更新流程只保證從 GitHub Releases 下載的官方 `Lex.dmg` / `Lex.app.zip`。

### 必須的系統權限

啟動後需要授予 **輔助使用權限**：

1. 系統會自動彈出提示
2. 前往「系統設定 → 隱私與安全性 → 輔助使用」
3. 找到 Lex（或 Terminal）並打勾啟用

## 🚀 使用方式

1. 選取任意英文文字
2. 快速連按兩下 **Command (⌘)** 鍵
3. 翻譯面板會出現在游標旁邊

### 面板功能

| 按鈕 | 功能 |
|------|------|
| 🔊 | 朗讀原文 |
| 📋 | 複製翻譯結果 |
| 🔖 | 收藏 / 取消收藏 |

### Menu Bar

點擊 Menu Bar 的圖示可以：
- 查看目前使用的翻譯來源
- 瀏覽收藏詞彙（⌘L）
- 結束應用程式

## 🔌 自訂翻譯來源

Lex 使用 Provider 架構，可以輕鬆新增翻譯來源：

```swift
class DeepLProvider: TranslationProvider {
    var name: String { "DeepL" }
    var identifier: String { "deepl" }
    
    func translate(text: String, from: String, to: String, completion: @escaping (String?, String?) -> Void) {
        // ... API 呼叫 ...
        completion("Bonjour", "[bɔ̃ʒuʁ]")
    }
}

// 切換使用
TranslationService.shared.setProvider(DeepLProvider())
```

詳見 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 🧪 測試

```bash
make test
```

測試使用 BDD 命名風格與參數化測試，涵蓋：
- 資料模型（TranslationItem）
- 詞彙管理（VocabularyManager）
- 翻譯服務整合（TranslationService）
- Provider 協議與切換

## 📁 專案結構

```
Sources/
├── LexLib/          # 核心邏輯（可測試）
│   ├── Controllers/
│   │   ├── TranslationProvider.swift    # Provider 協議
│   │   ├── GoogleTranslateProvider.swift
│   │   ├── TranslationService.swift     # Provider 管理器
│   │   ├── AppController.swift          # 事件監聽
│   │   ├── ClipboardManager.swift
│   │   └── VocabularyManager.swift
│   ├── Models/
│   │   └── TranslationItem.swift
│   ├── ViewModels/
│   │   └── TranslationViewModel.swift
│   └── Views/
│       ├── FloatingPanelView.swift
│       └── VocabularyListView.swift
├── LexApp/
│   └── main.swift                       # App 進入點
Tests/
├── TestFramework.swift                  # 自製 BDD 測試框架
├── AllTests.swift                       # 所有測試案例
└── TestRunner.swift
```

## 📚 資料來源

注音資料來源：[教育部《國語辭典簡編本》](https://dict.concised.moe.edu.tw/)  
授權條款：[CC BY-ND 3.0 TW](https://creativecommons.org/licenses/by-nd/3.0/tw/)  
著作權人：中華民國教育部

### 🔠 多音字處理策略 (Disambiguation)
Lex 採用「最長比對優先 (Longest Match)」加上「首選讀音啟發法 (Primary Reading Heuristic)」：
- **詞條優先**：如「龜裂」在詞典中有獨立詞條，則精確顯示 `ㄐㄩㄣ ㄌㄧㄝˋ`。
- **長句自動簡化**：在長句子中，若單個字有多個讀音（如「中」有 ㄓㄨㄥ/ㄓㄨㄥˋ），系統會根據教育部《一字多音審定表》自動選取第一順位讀音，避免斜線干擾閱讀。
- **單字顯示全部**：若僅查詢單個字，則會列出所有可能的讀音。

## 📄 授權

本專案採用 [Apache License 2.0](LICENSE) 授權。
