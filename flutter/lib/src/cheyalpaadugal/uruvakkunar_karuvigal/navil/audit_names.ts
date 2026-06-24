import { transliterate } from './transliterate';

// ─────────────────────────────────────────────────────────────────────────────
// All folder/file names and AGENTS.md keys that are Tamil compound words.
// LEFT: Correct Tamil (with proper புணர்ச்சி doubling)
// RIGHT: Current Tanglish name in the codebase
// ─────────────────────────────────────────────────────────────────────────────

const compoundWords: { tamil: string; currentName: string; usage: string }[] = [
  // ── Folder names ──
  { tamil: "கைப்பேசி",       currentName: "kaipaesi",          usage: "folder: chattagam/kaatchi/kaipaesi/" },
  { tamil: "செயல்பாடுகள்",    currentName: "cheyalpaadugal",    usage: "folder: lib/src/cheyalpaadugal/" },
  { tamil: "தரவுத்தளம்",      currentName: "tharavuthalam",     usage: "folder: adippadai/tharavuthalam/" },
  { tamil: "தரவுகள்",        currentName: "tharavugal",        usage: "folder: multiple tharavugal/" },
  { tamil: "மொழியாக்கம்",    currentName: "mozhiyaakkam",      usage: "folder: adippadai/mozhiyaakkam/" },
  { tamil: "காட்சி",         currentName: "kaatchi",           usage: "folder: kaatchi/" },
  { tamil: "கூறுகள்",        currentName: "koorugal",          usage: "folder: koorugal/" },
  { tamil: "திரைகள்",        currentName: "thiraigal",         usage: "folder: thiraigal/" },
  { tamil: "திருத்தி",        currentName: "thiruthi",          usage: "folder: thiruthi/" },
  { tamil: "களஞ்சியம்",      currentName: "kalanjiyam",        usage: "folder: kalanjiyam/" },
  { tamil: "நிலைமை",        currentName: "nilaimai",          usage: "folder: nilaimai/" },
  { tamil: "அமைப்புகள்",     currentName: "amaippugal",        usage: "folder: amaippugal/" },
  { tamil: "கணினி",          currentName: "kanini",            usage: "folder: kanini/" },
  { tamil: "அறிக்கைகள்",     currentName: "arikkaigal",        usage: "folder: arikkaigal/" },
  { tamil: "வரவேற்பு படிகள்", currentName: "varavaerpu_padigal", usage: "folder: varavaerpu_padigal/" },
  { tamil: "உள்நுழைவு",      currentName: "ullnuzhaivu",       usage: "folder: ullnuzhaivu/" },
  { tamil: "சட்டகம்",        currentName: "chattagam",         usage: "folder: chattagam/" },
  { tamil: "பட்டியல்",       currentName: "pattiyal",          usage: "folder: pattiyal/" },
  { tamil: "வணிகர்",         currentName: "vanigar",           usage: "folder: vanigar/" },
  { tamil: "பொருள்",         currentName: "porul",             usage: "folder: porul/" },
  { tamil: "பற்றுச்சீட்டு",    currentName: "patrucheettu",      usage: "folder: patrucheettu/" },
  { tamil: "பொதுக்கூறுகள்",  currentName: "podhu_koorugal",    usage: "folder: podhu_koorugal/" },
  { tamil: "மேலடுக்குகள்",    currentName: "meladukkugal",      usage: "folder: meladukkugal/" },
  { tamil: "புலன்கூறுகள்",   currentName: "pulan_koorugal",    usage: "folder: pulan_koorugal/" },
  { tamil: "உள்ளீடுகள்",     currentName: "ulleedugal",        usage: "folder: ulleedugal/" },

  // ── AGENTS.md standardized keys ──
  { tamil: "தொலைப்பேசி",     currentName: "tholaipaesi",       usage: "key: Phone" },
  { tamil: "மின்னஞ்சல்",     currentName: "minnanjal",         usage: "key: Email" },
  { tamil: "ஓவுரு",          currentName: "oavuru",            usage: "key: Logo/Image" },
  { tamil: "அகல ஓவுரு",     currentName: "agalaOavuru",       usage: "key: Wide Logo" },
  { tamil: "அஞ்சல்குறியீடு",  currentName: "anjalKuriyeedu",    usage: "key: Zip/PIN" },
  { tamil: "தோற்றநிறம்",     currentName: "thoatraNiram",      usage: "key: Theme Color" },
  { tamil: "தலைப்புவடிவு",   currentName: "thalaippuVadivu",   usage: "key: Header Format" },
  { tamil: "கடவுச்சொல்",     currentName: "kadavuchol",        usage: "key: Password" },
  { tamil: "பற்றுச்சீட்டு",    currentName: "patrucheettu",      usage: "key: Receipt" },
  { tamil: "அடிப்படை",       currentName: "adippadai",         usage: "folder: adippadai/" },

  // ── File name components ──
  { tamil: "திரை",           currentName: "thirai",            usage: "suffix: _thirai.dart" },
  { tamil: "கூறு",           currentName: "kooru",             usage: "suffix: _kooru.dart" },
  { tamil: "மேலடுக்கு",       currentName: "meladukku",         usage: "suffix: _meladukku.dart" },
  { tamil: "தரவுரு",         currentName: "tharavuru",         usage: "suffix: _tharavuru.dart" },
  { tamil: "உதவி",           currentName: "uthavi",            usage: "suffix: _uthavi.dart" },
];

console.log("=== NAVIL EXTENDED++ TRANSLITERATION AUDIT ===\n");
console.log("Tamil".padEnd(22) + "Current".padEnd(22) + "Engine Output".padEnd(22) + "Match?  Usage");
console.log("─".repeat(100));

let mismatches = 0;

for (const { tamil, currentName, usage } of compoundWords) {
  const engineOutput = transliterate(tamil, "extended++");
  const clean = engineOutput.replace(/\s+/g, ''); // remove spaces for compound words
  const match = clean === currentName;
  
  const marker = match ? "✅" : "❌";
  if (!match) mismatches++;
  
  console.log(
    `${tamil.padEnd(20)} ${currentName.padEnd(22)} ${clean.padEnd(22)} ${marker}      ${usage}`
  );
}

console.log("\n" + "─".repeat(100));
console.log(`\nTotal: ${compoundWords.length} words, ${mismatches} mismatches found.`);
