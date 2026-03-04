import { pinyin } from 'pinyin-pro';
import fs from 'fs';

// To maximize accuracy, we don't just use single characters from hyzd.
// We should rely on `pinyin-pro`'s internal dictionary which is very robust.
// However, since we need to do this in Swift offline, we need a lookup table.
//
// Since a full phrase dictionary is huge, we'll generate:
// 1. A single-character Bopomofo map (for basic fallback)
// 2. We'll use pinyin-pro to generate a robust mapping for common Chinese characters (about 5000)

// Instead of a huge JS script, let's use the actual Swift library we just found: `vChewing/Tekkon`
// Or if we go the JSON route, here is a dump of the most common 3000 chars

import fetch from 'node-fetch';

async function generate() {
    console.log("Fetching hyzd data for character list...");
    const res = await fetch("https://raw.githubusercontent.com/kfcd/hyzd/master/hyzd.txt");
    const text = await res.text();

    const lines = text.split('\n');
    const dict = {};

    let count = 0;
    for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;

        const parts = line.split('\t');
        if (parts.length >= 2) {
            const chars = [parts[0], parts[1]]; // Trad, Simp
            for (const ch of chars) {
                if (ch && ch.length === 1 && !dict[ch]) {
                    // pinyin-pro can return multiple pronunciations for heteronyms
                    const polys = pinyin(ch, { type: 'array', multiple: true, pattern: 'bopomofo' });
                    if (polys && polys.length > 0) {
                        dict[ch] = polys;
                        count++;
                    }
                }
            }
        }
    }

    fs.writeFileSync('../Sources/LexLib/Resources/zhuyin_dict.json', JSON.stringify(dict, null, 0));
    console.log(`Saved ${count} characters to zhuyin_dict.json`);
}

generate().catch(console.error);
