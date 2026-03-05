const XLSX = require('xlsx');
const fs = require('fs');

console.log("Loading MOE 簡編本 XLSX...");
const workbook = XLSX.readFile('dict_concised/dict_concised_2014_20251229.xlsx');
const sheet = workbook.Sheets[workbook.SheetNames[0]];
const rows = XLSX.utils.sheet_to_json(sheet);

// Build word dictionary (word -> first zhuyin) - same as before
const wordDict = {};
// Build single-char multi-reading dictionary (char -> [all readings])
const charReadings = {};

let wordCount = 0;
let singleCount = 0;

for (const row of rows) {
    const word = (row['字詞名'] || '').trim();
    const zhuyin = (row['注音一式'] || '').trim();
    if (!word || !zhuyin || word.includes('{')) continue;

    if (word.length === 1) {
        // Single character - collect ALL readings
        if (!charReadings[word]) charReadings[word] = [];
        if (!charReadings[word].includes(zhuyin)) {
            charReadings[word].push(zhuyin);
        }
    } else {
        // Multi-char word - only keep first reading
        if (!wordDict[word]) {
            wordDict[word] = zhuyin;
            wordCount++;
        }
    }
}

// Build the final dictionary:
// - For multi-char words: "銀行" -> "ㄧㄣˊ　ㄏㄤˊ"
// - For single chars with 1 reading: "我" -> "ㄨㄛˇ"
// - For single chars with multiple readings: "行" -> ["ㄏㄤˊ", "ㄒㄧㄥˊ"]
const finalDict = {};

// Add word-level entries as strings
for (const [word, zhuyin] of Object.entries(wordDict)) {
    finalDict[word] = zhuyin;
}

// Add single-char entries
let multiReadingCount = 0;
for (const [char, readings] of Object.entries(charReadings)) {
    if (readings.length === 1) {
        finalDict[char] = readings[0];
    } else {
        finalDict[char] = readings.join(" / "); // Join multiple readings
        multiReadingCount++;
    }
    singleCount++;
}

const jsonStr = JSON.stringify(finalDict);
fs.writeFileSync('../../Sources/LexLib/Resources/moe_zhuyin.json', jsonStr);

const stats = fs.statSync('../../Sources/LexLib/Resources/moe_zhuyin.json');
console.log("\nResults:");
console.log("  Multi-char words:           " + wordCount);
console.log("  Single chars (1 reading):   " + (singleCount - multiReadingCount));
console.log("  Single chars (multi read):  " + multiReadingCount);
console.log("  Total entries:              " + (wordCount + singleCount));
console.log("  File size:                  " + (stats.size / 1024 / 1024).toFixed(2) + " MB");

// Verify polyphones
console.log("\nMultiple-reading chars:");
const checkChars = ['行', '重', '樂', '說', '長', '為', '便', '著', '數'];
for (const c of checkChars) {
    console.log("  " + c + ": " + JSON.stringify(finalDict[c]));
}

// Verify commonly mispronounced words
console.log("\nCommonly mispronounced words:");
const checkWords = ['骰子', '曝光', '秘魯', '龜裂', '蛤蜊', '脂肪', '牛仔褲', '巷弄', '友誼', '亞洲'];
for (const w of checkWords) {
    console.log("  " + w + ": " + (finalDict[w] || '(not found)'));
}
