import Foundation

/// Converts Chinese characters to Zhuyin (Bopomofo) phonetic annotations.
/// Uses macOS native CFStringTokenizer — no external dependencies needed.
public class ZhuyinConverter {
    
    public static let shared = ZhuyinConverter()
    
    public init() {}
    
    /// Convert a Chinese string to Zhuyin annotation.
    /// Returns an array of (character, zhuyin) tuples.
    /// Non-Chinese characters have nil zhuyin.
    public func annotate(_ text: String) -> [(character: String, zhuyin: String?)] {
        var result: [(character: String, zhuyin: String?)] = []
        
        let cfText = text as CFString
        let range = CFRangeMake(0, CFStringGetLength(cfText))
        let tokenizer = CFStringTokenizerCreate(
            kCFAllocatorDefault,
            cfText,
            range,
            kCFStringTokenizerUnitWord,
            CFLocaleCopyCurrent()
        )
        
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        var lastEnd = 0
        
        while tokenType != [] {
            let tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let start = tokenRange.location
            let length = tokenRange.length
            
            // Handle any gap before this token (non-tokenized characters)
            if start > lastEnd {
                let gapStart = text.index(text.startIndex, offsetBy: lastEnd)
                let gapEnd = text.index(text.startIndex, offsetBy: start)
                for ch in text[gapStart..<gapEnd] {
                    result.append((String(ch), nil))
                }
            }
            
            // Extract Zhuyin for this token
            let tokenStart = text.index(text.startIndex, offsetBy: start)
            let tokenEnd = text.index(text.startIndex, offsetBy: start + length)
            let tokenText = String(text[tokenStart..<tokenEnd])
            
            if let latinRef = CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) {
                let latin = latinRef as! CFString as String
                let zhuyin = latinToZhuyin(latin)
                
                // If multi-character token, try to split per character
                if tokenText.count > 1 {
                    let zhuyinParts = splitZhuyinPerCharacter(text: tokenText, fullZhuyin: zhuyin)
                    result.append(contentsOf: zhuyinParts)
                } else {
                    result.append((tokenText, zhuyin))
                }
            } else {
                for ch in tokenText {
                    result.append((String(ch), nil))
                }
            }
            
            lastEnd = start + length
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        
        // Handle remaining characters after last token
        if lastEnd < text.count {
            let remaining = text.index(text.startIndex, offsetBy: lastEnd)
            for ch in text[remaining...] {
                result.append((String(ch), nil))
            }
        }
        
        return result
    }
    
    /// Get a simple Zhuyin string for display (space-separated)
    public func getZhuyin(_ text: String) -> String {
        let annotations = annotate(text)
        return annotations.compactMap { $0.zhuyin }.joined(separator: " ")
    }
    
    /// Check if text contains Chinese characters
    public func containsChinese(_ text: String) -> Bool {
        for scalar in text.unicodeScalars {
            if isCJK(scalar) { return true }
        }
        return false
    }
    
    // MARK: - Private
    
    private func isCJK(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        return (v >= 0x4E00 && v <= 0x9FFF) ||   // CJK Unified
               (v >= 0x3400 && v <= 0x4DBF) ||    // CJK Extension A
               (v >= 0xF900 && v <= 0xFAFF)       // CJK Compatibility
    }
    
    /// Convert Pinyin latin transcription to Zhuyin (Bopomofo)
    private func latinToZhuyin(_ latin: String) -> String {
        let cfStr = latin as CFString
        let mutableStr = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, cfStr)!
        CFStringTransform(mutableStr, nil, "Latin-Bopomofo" as CFString, false)
        return mutableStr as String
    }
    
    /// Try to split a multi-character Zhuyin annotation per character
    private func splitZhuyinPerCharacter(text: String, fullZhuyin: String) -> [(character: String, zhuyin: String?)] {
        // Use per-character tokenization for splitting
        var perChar: [(character: String, zhuyin: String?)] = []
        
        for ch in text {
            let charStr = String(ch)
            if isCJK(ch.unicodeScalars.first!) {
                let cfChar = charStr as CFString
                let charRange = CFRangeMake(0, CFStringGetLength(cfChar))
                let charTokenizer = CFStringTokenizerCreate(
                    kCFAllocatorDefault, cfChar, charRange,
                    kCFStringTokenizerUnitWord, CFLocaleCopyCurrent()
                )
                
                let _ = CFStringTokenizerAdvanceToNextToken(charTokenizer)
                if let latinRef = CFStringTokenizerCopyCurrentTokenAttribute(charTokenizer, kCFStringTokenizerAttributeLatinTranscription) {
                    let latin = latinRef as! CFString as String
                    perChar.append((charStr, latinToZhuyin(latin)))
                } else {
                    perChar.append((charStr, nil))
                }
            } else {
                perChar.append((charStr, nil))
            }
        }
        
        return perChar
    }
}
