import Foundation

func runZhuyinTests() {
    let converter = ZhuyinConverter.shared
    
    describe("ZhuyinConverter (MOE 簡編本)") {
        
        // =====================================================================
        // MARK: - Basic Characters
        // =====================================================================
        
        it("given simple characters, when translated, then returns correct Bopomofo") {
            try assertEqual(converter.getZhuyin("我"), "ㄨㄛˇ")
            try assertEqual(converter.getZhuyin("你"), "ㄋㄧˇ")
            try assertEqual(converter.getZhuyin("他"), "ㄊㄚ")
        }
        
        // =====================================================================
        // MARK: - Polyphones: 行 (ㄏㄤˊ bank vs ㄒㄧㄥˊ walk)
        // =====================================================================
        
        it("given 行 in different word contexts, then reads correctly") {
            // 銀行 → ㄏㄤˊ (bank)
            let bank = converter.annotate("銀行")
            try assertEqual(bank[1].zhuyin, "ㄏㄤˊ")
            
            // 行人 → ㄒㄧㄥˊ (walk)
            let pedestrian = converter.annotate("行人")
            try assertEqual(pedestrian[0].zhuyin, "ㄒㄧㄥˊ")
            
            // 行為 → ㄒㄧㄥˊ (behavior)
            let behavior = converter.annotate("行為")
            try assertEqual(behavior[0].zhuyin, "ㄒㄧㄥˊ")
        }
        
        // =====================================================================
        // MARK: - Polyphones: 重 (ㄓㄨㄥˋ heavy vs ㄔㄨㄥˊ again)
        // =====================================================================
        
        it("given 重 in different word contexts, then reads correctly") {
            // 重要 → ㄓㄨㄥˋ (important)
            let important = converter.annotate("重要")
            try assertEqual(important[0].zhuyin, "ㄓㄨㄥˋ")
            
            // 重新 → ㄔㄨㄥˊ (again)
            let again = converter.annotate("重新")
            try assertEqual(again[0].zhuyin, "ㄔㄨㄥˊ")
        }
        
        // =====================================================================
        // MARK: - Polyphones: 樂 (ㄩㄝˋ music vs ㄌㄜˋ happy)
        // =====================================================================
        
        it("given 樂 in different word contexts, then reads correctly") {
            // 音樂 → ㄩㄝˋ (music)
            let music = converter.annotate("音樂")
            try assertEqual(music[1].zhuyin, "ㄩㄝˋ")
            
            // 快樂 → ㄌㄜˋ (happy)
            let happy = converter.annotate("快樂")
            try assertEqual(happy[1].zhuyin, "ㄌㄜˋ")
            
            // 樂器 → ㄩㄝˋ (instrument)
            let instrument = converter.annotate("樂器")
            try assertEqual(instrument[0].zhuyin, "ㄩㄝˋ")
        }
        
        // =====================================================================
        // MARK: - Polyphones: 說 (ㄕㄨㄛ speak vs ㄕㄨㄟˋ persuade)
        // =====================================================================
        
        it("given 說 in different word contexts, then reads correctly") {
            // 說話 → ㄕㄨㄛ (speak)
            let speak = converter.annotate("說話")
            try assertEqual(speak[0].zhuyin, "ㄕㄨㄛ")
            
            // 遊說 → ㄕㄨㄟˋ (persuade/lobby)
            let lobby = converter.annotate("遊說")
            try assertEqual(lobby[1].zhuyin, "ㄕㄨㄟˋ")
            
            // 說明 → ㄕㄨㄛ (explain)
            let explain = converter.annotate("說明")
            try assertEqual(explain[0].zhuyin, "ㄕㄨㄛ")
        }
        
        // =====================================================================
        // MARK: - Polyphones: 長 (ㄔㄤˊ long vs ㄓㄤˇ elder/grow)
        // =====================================================================
        
        it("given 長 in different word contexts, then reads correctly") {
            // 長短 → ㄔㄤˊ (long)
            let length = converter.annotate("長短")
            try assertEqual(length[0].zhuyin, "ㄔㄤˊ")
            
            // 校長 → ㄓㄤˇ (principal)
            let principal = converter.annotate("校長")
            try assertEqual(principal[1].zhuyin, "ㄓㄤˇ")
            
            // 成長 → ㄓㄤˇ (grow)
            let grow = converter.annotate("成長")
            try assertEqual(grow[1].zhuyin, "ㄓㄤˇ")
            
            // 長輩 → ㄓㄤˇ (elder)
            let elder = converter.annotate("長輩")
            try assertEqual(elder[0].zhuyin, "ㄓㄤˇ")
        }
        
        // =====================================================================
        // MARK: - Polyphones: 為 (ㄨㄟˊ be/as vs ㄨㄟˋ for/because)
        // =====================================================================
        
        it("given 為 in different word contexts, then reads correctly") {
            // 認為 → ㄨㄟˊ (think/believe)
            let think = converter.annotate("認為")
            try assertEqual(think[1].zhuyin, "ㄨㄟˊ")
            
            // 因為 → ㄨㄟˋ (because)
            let because = converter.annotate("因為")
            try assertEqual(because[1].zhuyin, "ㄨㄟˋ")
            
            // 行為 → ㄨㄟˊ (behavior)
            let behavior = converter.annotate("行為")
            try assertEqual(behavior[1].zhuyin, "ㄨㄟˊ")
        }
        
        // =====================================================================
        // MARK: - Polyphones: 便 (ㄅㄧㄢˋ convenient vs ㄆㄧㄢˊ cheap)
        // =====================================================================
        
        it("given 便 in different word contexts, then reads correctly") {
            // 便宜 → ㄅㄧㄢˋ (cheap)
            let cheap = converter.annotate("便宜")
            try assertEqual(cheap[0].zhuyin, "ㄅㄧㄢˋ")
            
            // 方便 → ㄅㄧㄢˋ (convenient)
            let convenient = converter.annotate("方便")
            try assertEqual(convenient[1].zhuyin, "ㄅㄧㄢˋ")
        }
        
        // =====================================================================
        // MARK: - Polyphones: 著 (ㄓㄨˋ write vs ㄓㄨㄛˊ land)
        // =====================================================================
        
        it("given 著 in different word contexts, then reads correctly") {
            // 著作 → ㄓㄨˋ (writing/to write)
            let writing = converter.annotate("著作")
            try assertEqual(writing[0].zhuyin, "ㄓㄨˋ")
            
            // 著陸 → ㄓㄨㄛˊ (to land)
            let landing = converter.annotate("著陸")
            try assertEqual(landing[0].zhuyin, "ㄓㄨㄛˊ")
        }
        
        // =====================================================================
        // MARK: - Polyphones: 數 (ㄕㄨˋ number vs ㄕㄨˇ to count)
        // =====================================================================
        
        it("given 數 in different word contexts, then reads correctly") {
            // 數學 → ㄕㄨˋ (mathematics)
            let math = converter.annotate("數學")
            try assertEqual(math[0].zhuyin, "ㄕㄨˋ")
            
            // 數字 → ㄕㄨˋ (digit/number)
            let digit = converter.annotate("數字")
            try assertEqual(digit[0].zhuyin, "ㄕㄨˋ")
        }
        
        // =====================================================================
        // MARK: - Single-character defaults (no word context)
        // =====================================================================
        
        it("given single polyphone characters alone, then returns MOE default reading") {
            // 單獨查一個字，只能回傳字典裡的預設音
            // 這是已知限制：沒有上下文時無法判斷正確讀音
            let xing = converter.annotate("行")
            try assertEqual(xing.count, 1)
            try assertNotNil(xing[0].zhuyin, "行 should have a default reading")
            
            let le = converter.annotate("樂")
            try assertEqual(le.count, 1)
            try assertNotNil(le[0].zhuyin, "樂 should have a default reading")
        }
        
        // =====================================================================
        // MARK: - Edge cases
        // =====================================================================
        
        it("given unknown characters, then returns nil (no fallback)") {
            let result = converter.annotate("😀")
            try assertEqual(result.count, 1)
            try assertNil(result[0].zhuyin)
        }
        
        it("given non-chinese strings, then returns nil for each char") {
            let result = converter.annotate("Hello")
            for item in result {
                try assertNil(item.zhuyin)
            }
        }
        
        it("given mixed text, then only Chinese chars get zhuyin") {
            let result = converter.annotate("A蘋果B")
            try assertEqual(result.count, 4)
            try assertNil(result[0].zhuyin)    // A
            try assertNotNil(result[1].zhuyin) // 蘋
            try assertNotNil(result[2].zhuyin) // 果
            try assertNil(result[3].zhuyin)    // B
        }
    }
}
