import Foundation

func runPolyphoneTests() {
    let converter = ZhuyinConverter.shared
    
    describe("Zhuyin Polyphone Disambiguation") {
        
        it("given a multi-character phrase with a polyphone, when single-match occurs, then picks primary reading") {
            // "中" has multiple readings ㄓㄨㄥ / ㄓㄨㄥˋ
            // In "開發中", it's not a dictionary word, so it hits single-char lookup.
            // Heuristic should pick ㄓㄨㄥ because text.count > 1.
            let result = converter.getZhuyin("開發中")
            try assertEqual(result, "ㄎㄞ ㄈㄚ ㄓㄨㄥ")
        }
        
        it("given a single-character polyphone alone, then shows all readings with slashes") {
            // "中" alone should still show both for dictionary exploration.
            let result = converter.getZhuyin("中")
            try assertEqual(result, "ㄓㄨㄥ / ㄓㄨㄥˋ")
        }
        
        it("given an explicit dictionary word with multi-readings for a character, then preserves word-level accuracy") {
            // "龜裂" is in moe_zhuyin.json as "ㄐㄩㄣ　ㄌㄧㄝˋ"
            // Even though "龜" alone might have multiple readings, 
            // the dictionary match for the whole word should be prioritized.
            let result = converter.getZhuyin("龜裂")
            try assertEqual(result, "ㄐㄩㄣ ㄌㄧㄝˋ")
        }
        
        it("given other common polyphones in phrases, then disambiguates to primary reading") {
            // 行 in phrases (if not in dictionary as a word)
            // Note: "行人" is probably in dictionary, but let's test a made-up phrase
            // if it hits single-char lookup.
            let result = converter.getZhuyin("我去行") // "行" alone in a sentence
            try assertEqual(result, "ㄨㄛˇ ㄑㄩˋ ㄏㄤˊ") // ㄏㄤˊ is the first reading in dict
        }
    }
}
