# 貢獻指南

感謝你對 DoubleCmdTranslator 的興趣！歡迎提交 Issue 和 Pull Request。

## 開發環境

- macOS 13.0+
- Swift 5.9+（Command Line Tools 即可，不需要 Xcode）

```bash
git clone https://github.com/Mapleeeeeeeeeee/DoubleCmdTranslator.git
cd DoubleCmdTranslator
make build   # 編譯
make test    # 執行測試
make run     # 啟動應用
```

## 新增翻譯來源（Translation Provider）

這是最常見的貢獻方式。只需要三步：

### 1. 建立 Provider 檔案

在 `Sources/DoubleCmdTranslatorLib/Controllers/` 新增檔案：

```swift
// DeepLProvider.swift
import Foundation

public class DeepLProvider: TranslationProvider {
    public var name: String { "DeepL" }
    public var identifier: String { "deepl" }
    
    private let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func translate(text: String, from: String, to: String, 
                          completion: @escaping (String?) -> Void) {
        // 實作翻譯邏輯
        // from: 來源語言代碼（"auto" 表示自動偵測）
        // to: 目標語言代碼（如 "zh-TW"）
    }
}
```

### 2. 加入測試

在 `Tests/AllTests.swift` 新增測試：

```swift
func runDeepLProviderTests() {
    describe("DeepLProvider") {
        it("given provider, when accessed, then name and identifier are correct") {
            let provider = DeepLProvider(apiKey: "test")
            try assertEqual(provider.name, "DeepL")
            try assertEqual(provider.identifier, "deepl")
        }
    }
}
```

並在 `Tests/TestRunner.swift` 加入 `runDeepLProviderTests()`。

### 3. 測試

```bash
make test
```

## 測試規範

- 使用 **BDD 命名風格**：`given [前置條件], when [操作], then [預期結果]`
- 盡量使用**參數化測試**來覆蓋多種輸入
- 測試框架在 `Tests/TestFramework.swift`，不依賴 Xcode

## Pull Request 流程

1. Fork 專案
2. 建立 feature branch：`git checkout -b feature/deepl-provider`
3. 確保 `make build` 和 `make test` 都通過
4. 提交 PR，附上功能說明

## 回報問題

開 Issue 時請附上：
- macOS 版本
- 問題描述與重現步驟
- 相關錯誤訊息（如果有的話）
