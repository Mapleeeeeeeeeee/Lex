import Foundation

let pinyinTonesText = """
a:ā,á,ǎ,à,a
e:ē,é,ě,è,e
i:ī,í,ǐ,ì,i
o:ō,ó,ǒ,ò,o
u:ū,ú,ǔ,ù,u
v:ǖ,ǘ,ǚ,ǜ,ü
"""
// Convert Numbered Pinyin to Bopomofo map:
let bopomofoMap: [String: String] = [
    "b": "ㄅ", "p": "ㄆ", "m": "ㄇ", "f": "ㄈ", "d": "ㄉ", "t": "ㄊ", "n": "ㄋ", "l": "ㄌ",
    "g": "ㄍ", "k": "ㄎ", "h": "ㄏ", "j": "ㄐ", "q": "ㄑ", "x": "ㄒ",
    "zh": "ㄓ", "ch": "ㄔ", "sh": "ㄕ", "r": "ㄖ", "z": "ㄗ", "c": "ㄘ", "s": "ㄙ",
    "i": "ㄧ", "u": "ㄨ", "v": "ㄩ",
    "a": "ㄚ", "o": "ㄛ", "e": "ㄜ", "e^": "ㄝ", "ai": "ㄞ", "ei": "ㄟ", "ao": "ㄠ", "ou": "ㄡ",
    "an": "ㄢ", "en": "ㄣ", "ang": "ㄤ", "eng": "ㄥ", "er": "ㄦ",
    "ia": "ㄧㄚ", "io": "ㄧㄛ", "ie": "ㄧㄝ", "iai": "ㄧㄞ", "iao": "ㄧㄠ", "iu": "ㄧㄡ",
    "ian": "ㄧㄢ", "in": "ㄧㄣ", "iang": "ㄧㄤ", "ing": "ㄧㄥ",
    "ua": "ㄨㄚ", "uo": "ㄨㄛ", "uai": "ㄨㄞ", "ui": "ㄨㄟ", "uan": "ㄨㄢ", "un": "ㄨㄣ", "uang": "ㄨㄤ",
    "ong": "ㄨㄥ", "ve": "ㄩㄝ", "van": "ㄩㄢ", "vn": "ㄩㄣ", "iong": "ㄩㄥ"
]

// To properly convert pinyin to bopomofo, there are some aliases:
// yi=i, wu=u, yu=v, ye=ie, yue=ve, yuang=uang? no yuan=van
// This mapping is complex. Let's instead use CFStringTokenizer first if we can,
// but the problem is CFStringTokenizer handles polyphones poorly.
