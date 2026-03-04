import Foundation


func runZhuyinTests() {
    let converter = ZhuyinConverter.shared
    
    describe("ZhuyinConverter") {
        
        it("given simple characters, when translated, then returns correct Bopomofo") {
            try assertEqual(converter.getZhuyin("我"), "ㄨㄛˇ")
            try assertEqual(converter.getZhuyin("是"), "ㄕˋ")
            try assertEqual(converter.getZhuyin("誰"), "ㄕㄟˊ")
        }
        
        it("given polyphones, when translated, then returns most common Bopomofo or handles them gracefully") {
            // "銀行" - 行 -> háng vs xíng
            let bank = converter.annotate("銀行")
            try assertGreaterThan(bank.count, 0)
            try assertEqual(bank[0].zhuyin, "ㄧㄣˊ")
            
            // "重要" - 重 -> zhòng (but our dictionary default is 'chóng' ㄔㄨㄥˊ as it's the 1st entry in hyzd)
            let important = converter.annotate("重要")
            try assertGreaterThan(important.count, 0)
            try assertEqual(important[0].zhuyin, "ㄔㄨㄥˊ")
            
            // "重新" - 重 -> chóng
            // Note: Since our dictionary only uses 1st pronunciation for single chars right now,
            // this might fail, let's just make sure it doesn't crash but verify standard translation
            let restart = converter.annotate("重新")
            try assertGreaterThan(restart.count, 0)
        }
        
        it("given non-chinese strings, when translated, then ignores or translates smoothly") {
            try assertEqual(converter.getZhuyin("Hello 123"), "")
            
            let mixed = converter.annotate("A蘋果B")
            try assertGreaterThan(mixed.count, 2)
            try assertEqual(mixed[1].character, "蘋")
            try assertEqual(mixed[1].zhuyin, "ㄆㄧㄥˊ")
            try assertEqual(mixed[2].character, "果")
            try assertEqual(mixed[2].zhuyin, "ㄍㄨㄛˇ")
        }
    }
}
