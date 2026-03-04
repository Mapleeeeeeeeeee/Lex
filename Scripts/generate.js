import fetch from 'node-fetch';
import fs from 'fs';

const initialMap = {
    "zh": "ㄓ", "ch": "ㄔ", "sh": "ㄕ", "r": "ㄖ", "z": "ㄗ", "c": "ㄘ", "s": "ㄙ",
    "b": "ㄅ", "p": "ㄆ", "m": "ㄇ", "f": "ㄈ", "d": "ㄉ", "t": "ㄊ", "n": "ㄋ", "l": "ㄌ",
    "g": "ㄍ", "k": "ㄎ", "h": "ㄏ", "j": "ㄐ", "q": "ㄑ", "x": "ㄒ",
    "y": "ㄧ", "w": "ㄨ"
};

const finalMap = {
    "a": "ㄚ", "o": "ㄛ", "e": "ㄜ", "ai": "ㄞ", "ei": "ㄟ", "ao": "ㄠ", "ou": "ㄡ",
    "an": "ㄢ", "en": "ㄣ", "ang": "ㄤ", "eng": "ㄥ", "er": "ㄦ",
    "ia": "ㄧㄚ", "io": "ㄧㄛ", "ie": "ㄧㄝ", "iai": "ㄧㄞ", "iao": "ㄧㄠ", "iu": "ㄧㄡ",
    "ian": "ㄧㄢ", "in": "ㄧㄣ", "iang": "ㄧㄤ", "ing": "ㄧㄥ",
    "ua": "ㄨㄚ", "uo": "ㄨㄛ", "uai": "ㄨㄞ", "ui": "ㄨㄟ", "uan": "ㄨㄢ", "un": "ㄨㄣ", "uang": "ㄨㄤ",
    "ong": "ㄨㄥ",
    "ve": "ㄩㄝ", "van": "ㄩㄢ", "vn": "ㄩㄣ", "iong": "ㄩㄥ", "ue": "ㄩㄝ", "uan": "ㄩㄢ", "un": "ㄩㄣ"
};

const toneMap = {
    "1": "", "2": "ˊ", "3": "ˇ", "4": "ˋ", "5": "˙"
};

function pinyinToBopomofo(p) {
    if (!p || typeof p !== "string") return "";

    // Normalize edge cases (wu->u, yi->i)
    if (p.startsWith("yu")) p = p.replace("yu", "v");
    if (p.startsWith("y")) p = p.replace("y", "i");
    if (p.startsWith("w")) p = p.replace("w", "u");

    // "j", "q", "x", "y" followed by "u" is actually "v" (ü)
    if (p.match(/^[jqx]u/)) p = p.replace("u", "v");

    // special cases for empty finals
    if (p.match(/^[zcsr](h)?i/)) p = p.replace("i", "");

    let tone = p.match(/\d/)?.[0] || "1";
    p = p.replace(/\d/g, "");

    let initial = "";
    let finalCode = p;

    for (const [k, v] of Object.entries(initialMap)) {
        if (p.startsWith(k)) {
            initial = v;
            finalCode = p.substring(k.length);
            break;
        }
    }

    // Final special mappings
    if (finalCode === "v") finalCode = "ㄩ";
    else if (finalCode === "i") finalCode = "ㄧ";
    else if (finalCode === "u") finalCode = "ㄨ";
    else if (finalMap[finalCode]) finalCode = finalMap[finalCode];

    let toneChar = toneMap[tone] || "";
    // Fifth tone (neutral) goes BEFORE the syllable in Zhuyin
    if (tone === "5") return "˙" + initial + finalCode;
    return initial + finalCode + toneChar;
}

async function generate() {
    console.log("Fetching hyzd data...");
    const res = await fetch("https://raw.githubusercontent.com/kfcd/hyzd/master/hyzd.txt");
    const text = await res.text();
    const lines = text.split('\n');
    const dict = {};
    let count = 0;

    for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;
        const parts = line.split('\t');
        if (parts.length >= 3) {
            const trad = parts[0];
            const simp = parts[1];
            // Format: "ai2/yan2"
            const pinyinsRaw = parts[2].split('/');

            const zhuyins = pinyinsRaw.map(p => pinyinToBopomofo(p.trim())).filter(x => x);

            if (zhuyins.length > 0) {
                if (trad && trad.length === 1 && !dict[trad]) {
                    dict[trad] = zhuyins;
                    count++;
                }
                if (simp && simp.length === 1 && !dict[simp]) {
                    dict[simp] = zhuyins;
                }
            }
        }
    }

    fs.writeFileSync('../Sources/LexLib/Resources/zhuyin_dict.json', JSON.stringify(dict, null, 0));
    console.log(`Saved ${count} traditional characters to zhuyin_dict.json`);
}

generate().catch(console.error);
