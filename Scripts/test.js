// Test pinyin library outputs
import pkg from 'pinyin';
const { pinyin, STYLE_BOPOMOFO } = pkg;

console.log("STYLE_BOPOMOFO =", STYLE_BOPOMOFO);
const result = pinyin("漢字", { style: STYLE_BOPOMOFO });
console.log("Result =", result);

// wait the package might not export STYLE_BOPOMOFO directly, it might be pinyin.STYLE_BOPOMOFO or something
console.log("pkg.STYLE_BOPOMOFO =", pkg.STYLE_BOPOMOFO);
