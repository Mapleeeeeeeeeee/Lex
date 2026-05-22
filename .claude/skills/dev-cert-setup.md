# dev-cert-setup — macOS 開發用自簽憑證管理

設定自簽 code signing 憑證，讓 `make dev` 每次重編不需要重新授權輔助使用權限。
觸發：`/dev-cert-setup`、「設定開發憑證」、「重建開發憑證」、新機器初次設定。

---

## 背景

macOS 輔助使用權限綁定 code signing identity。Ad-hoc 簽名（`-`）每次編譯產生不同 hash，
macOS 視為不同 app，權限失效。自簽憑證讓 identity 跨 build 保持一致。

限制：自簽憑證只解決本地開發。正式發佈仍需 Apple Developer ID ($99/年) 才能通過 Gatekeeper 和 Notarization。

---

## 流程

### Step 1：檢查現有憑證

```bash
security find-identity -v -p codesigning 2>/dev/null | grep "Lex Dev"
```

如果找到 → 跳到 Step 4 驗證。
如果沒找到 → 繼續 Step 2。

### Step 2：建立自簽憑證

```bash
# 產生憑證設定
cat > /tmp/lex-dev-cert.cfg << 'EOF'
[ req ]
default_bits       = 2048
distinguished_name = req_dn
prompt             = no
[ req_dn ]
CN = Lex Dev
[ v3_codesign ]
keyUsage = critical, digitalSignature
extendedKeyUsage = codeSigning
EOF

# 產生 key + cert（有效期 10 年）
openssl req -x509 -newkey rsa:2048 \
  -keyout /tmp/lex-dev.key -out /tmp/lex-dev.crt \
  -days 3650 -nodes \
  -config /tmp/lex-dev-cert.cfg -extensions v3_codesign

# 轉成 p12 匯入格式
openssl pkcs12 -export -out /tmp/lex-dev.p12 \
  -inkey /tmp/lex-dev.key -in /tmp/lex-dev.crt \
  -passout pass:lex123 -legacy
```

### Step 3：匯入 Keychain 並信任

```bash
# 匯入
security import /tmp/lex-dev.p12 \
  -k ~/Library/Keychains/login.keychain-db \
  -T /usr/bin/codesign -P "lex123"

# 設定 codesign 權限
security set-key-partition-list -S apple-tool:,apple:,codesign: \
  -s -k "" ~/Library/Keychains/login.keychain-db

# 信任為 code signing
security add-trusted-cert -d -r trustRoot -p codeSign \
  -k ~/Library/Keychains/login.keychain-db /tmp/lex-dev.crt

# 清理暫存
rm -f /tmp/lex-dev.key /tmp/lex-dev.crt /tmp/lex-dev.p12 /tmp/lex-dev-cert.cfg
```

### Step 4：驗證

```bash
# 應該看到 "Lex Dev" 和一個 SHA-1 hash
security find-identity -v -p codesigning | grep "Lex Dev"

# 測試簽名
make dev
codesign -dvv Lex-Dev.app 2>&1 | grep "Authority"
# 預期輸出：Authority=Lex Dev
```

### Step 5：授權輔助使用（只需一次）

1. `open Lex-Dev.app`
2. 跳出權限對話框 → 前往設定 → 授權
3. 之後每次 `make dev` 重編都不需要再授權

---

## Makefile 整合

`make dev` 自動從 Keychain 找到 `Lex Dev` 憑證的 hash：

```makefile
DEV_SIGN_IDENTITY := $(shell security find-identity -v -p codesigning 2>/dev/null | grep "Lex Dev" | head -1 | awk '{print $$2}')

dev:
	@$(MAKE) build APP_NAME=Lex-Dev SKIP_SPARKLE=1 SIGN_IDENTITY="$(DEV_SIGN_IDENTITY)"
```

如果 `DEV_SIGN_IDENTITY` 為空（新機器沒設定），build 會 fallback 到 ad-hoc 簽名，功能正常但每次要重新授權。

---

## 故障排除

| 問題 | 原因 | 解法 |
|------|------|------|
| `0 valid identities found` | 憑證未匯入或未信任 | 重跑 Step 2-3 |
| `Authority=(unavailable)` | codesign 用名稱找不到，要用 SHA-1 hash | Makefile 已自動用 hash |
| 重編後還是要重新授權 | `DEV_SIGN_IDENTITY` 為空，fallback 到 ad-hoc | 跑 `security find-identity -v -p codesigning` 確認憑證存在 |
| 憑證過期 | 超過 10 年有效期 | 重跑 Step 2-3 建新憑證 |
