import Foundation

func runZhuyinTests() {
    let converter = ZhuyinConverter.shared
    
    describe("ZhuyinConverter (MOE 簡編本)") {
        
        it("given simple characters, when translated, then returns correct Bopomofo") {
            try assertEqual(converter.getZhuyin("我"), "ㄨㄛˇ")
            try assertEqual(converter.getZhuyin("你"), "ㄋㄧˇ")
            try assertEqual(converter.getZhuyin("他"), "ㄊㄚ")
        }
        
        it("given polyphones in word context, when translated, then returns correct reading based on word") {
            // 銀行 - 行 should be ㄏㄤˊ (bank), not ㄒㄧㄥˊ (walk)
            let bank = converter.annotate("銀行")
            try assertEqual(bank.count, 2)
            try assertEqual(bank[0].zhuyin, "ㄧㄣˊ")
            try assertEqual(bank[1].zhuyin, "ㄏㄤˊ")
            
            // 行人 - 行 should be ㄒㄧㄥˊ (walk)
            let pedestrian = converter.annotate("行人")
            try assertEqual(pedestrian.count, 2)
            try assertEqual(pedestrian[0].zhuyin, "ㄒㄧㄥˊ")
            
            // 重要 - 重 should be ㄓㄨㄥˋ (important)
            let important = converter.annotate("重要")
            try assertEqual(important.count, 2)
            try assertEqual(important[0].zhuyin, "ㄓㄨㄥˋ")
            
            // 重新 - 重 should be ㄔㄨㄥˊ (again)
            let again = converter.annotate("重新")
            try assertEqual(again.count, 2)
            try assertEqual(again[0].zhuyin, "ㄔㄨㄥˊ")
        }
        
        it("given unknown characters, when translated, then returns nil (no fallback)") {
            // Emoji or rare chars not in MOE dictionary should return nil, not a wrong guess
            let result = converter.annotate("😀")
            try assertEqual(result.count, 1)
            try assertNil(result[0].zhuyin)
        }
        
        it("given non-chinese strings, when translated, then returns nil for each char") {
            let result = converter.annotate("Hello")
            try assertEqual(result.count, 5)
            for item in result {
                try assertNil(item.zhuyin)
            }
        }
        
        it("given mixed text, when translated, then only Chinese chars get zhuyin") {
            let result = converter.annotate("A蘋果B")
            try assertEqual(result.count, 4)
            try assertNil(result[0].zhuyin)    // A
            try assertNotNil(result[1].zhuyin) // 蘋
            try assertNotNil(result[2].zhuyin) // 果
            try assertNil(result[3].zhuyin)    // B
        }
        
        it("given convenience vs cheap, when translated, then 便 reads differently") {
            // 便宜 -> ㄅㄧㄢˋ ㄧˊ (cheap)
            let cheap = converter.annotate("便宜")
            try assertEqual(cheap.count, 2)
            try assertEqual(cheap[0].zhuyin, "ㄅㄧㄢˋ")
            
            // 方便 -> ㄈㄤ ㄅㄧㄢˋ (convenient)
            let convenient = converter.annotate("方便")
            try assertEqual(convenient.count, 2)
            try assertEqual(convenient[1].zhuyin, "ㄅㄧㄢˋ")
        }
    }
}
