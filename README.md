# DoubleCmdTranslator

<p align="center">
  <strong>連按兩下 Command 鍵，即時翻譯選取文字</strong>
</p>

<p align="center">
  macOS 原生翻譯工具 · 輕量無干擾 · 支援自訂翻譯來源
</p>

---

## ✨ 功能特色

- **雙擊 Command 觸發** — 選取文字後連按兩下 ⌘ 即可翻譯，不需切換視窗
- **浮動翻譯面板** — 毛玻璃效果，出現在游標旁邊，點擊外部自動消失
- **朗讀原文** — 內建語音朗讀功能
- **一鍵複製** — 快速複製翻譯結果到剪貼簿
- **收藏詞彙** — 書籤按鈕收藏常用翻譯，Menu Bar 隨時瀏覽
- **翻譯來源可擴充** — Provider 架構，輕鬆接入 DeepL、OpenAI 等

## 📦 安裝

### 從原始碼編譯

需求：macOS 13.0+、Swift 5.9+

```bash
git clone https://github.com/Mapleeeeeeeeeee/DoubleCmdTranslator.git
cd DoubleCmdTranslator
make build
make run
```

### 首次使用

啟動後需要授予 **輔助使用權限**：

1. 系統會自動彈出提示
2. 前往「系統設定 → 隱私與安全性 → 輔助使用」
3. 找到 Terminal（或 DoubleCmdTranslator）並啟用

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

DoubleCmdTranslator 使用 Provider 架構，可以輕鬆新增翻譯來源：

```swift
class DeepLProvider: TranslationProvider {
    var name: String { "DeepL" }
    var identifier: String { "deepl" }
    
    func translate(text: String, from: String, to: String, 
                   completion: @escaping (String?) -> Void) {
        // 你的翻譯邏輯
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
├── DoubleCmdTranslatorLib/          # 核心邏輯（可測試）
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
├── DoubleCmdTranslatorApp/
│   └── main.swift                       # App 進入點
Tests/
├── TestFramework.swift                  # 自製 BDD 測試框架
├── AllTests.swift                       # 所有測試案例
└── TestRunner.swift
```

## 📄 授權

本專案採用 [Apache License 2.0](LICENSE) 授權。
