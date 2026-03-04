from pypinyin import pinyin, Style

text = "這是一個測試，銀行裡有很多錢，我走路去銀行。"
print(text)
print(pinyin(text, style=Style.BOPOMOFO))
