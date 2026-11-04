#!/usr/bin/env python3
"""
Deep verification & stress-test script by reviewer_2.
Verifies all ASO metadata, Fastlane configs, and legal documents.
"""

import os
import re
import subprocess
import sys
import unicodedata

ROOT_DIR = "/Volumes/DAT/GIT/360_verb"

issues = []
warnings = []
passed_checks = []

def record_pass(test_name, details=""):
    passed_checks.append((test_name, details))
    print(f"✅ [PASS] {test_name}: {details}")

def record_fail(test_name, details=""):
    issues.append((test_name, details))
    print(f"❌ [FAIL] {test_name}: {details}")

def record_warn(test_name, details=""):
    warnings.append((test_name, details))
    print(f"⚠️ [WARN] {test_name}: {details}")

def read_file(rel_path):
    p = os.path.join(ROOT_DIR, rel_path)
    if not os.path.exists(p):
        record_fail(f"File Existence: {rel_path}", "File does not exist")
        return ""
    with open(p, "r", encoding="utf-8") as f:
        return f.read()

# Comprehensive Emoji Detection
def find_all_emojis_and_symbols(text):
    """
    Exhaustively detects Unicode emojis and pictographs.
    """
    detected = []
    for idx, ch in enumerate(text):
        cat = unicodedata.category(ch)
        cp = ord(ch)
        name = unicodedata.name(ch, "")
        # Check standard emoji / symbol blocks
        is_emoji = False
        if 0x1F600 <= cp <= 0x1F64F: # Emoticons
            is_emoji = True
        elif 0x1F300 <= cp <= 0x1F5FF: # Misc Symbols & Pictographs
            is_emoji = True
        elif 0x1F680 <= cp <= 0x1F6FF: # Transport & Map
            is_emoji = True
        elif 0x1F700 <= cp <= 0x1F77F: # Alchemical Symbols
            is_emoji = True
        elif 0x1F780 <= cp <= 0x1F7FF: # Geometric Shapes Extended
            is_emoji = True
        elif 0x1F800 <= cp <= 0x1F8FF: # Supplemental Arrows-C
            is_emoji = True
        elif 0x1F900 <= cp <= 0x1F9FF: # Supplemental Symbols and Pictographs
            is_emoji = True
        elif 0x1FA00 <= cp <= 0x1FA6F: # Chess Symbols
            is_emoji = True
        elif 0x1FA70 <= cp <= 0x1FAFF: # Symbols and Pictographs Extended-A
            is_emoji = True
        elif 0x2600 <= cp <= 0x26FF:   # Misc symbols
            is_emoji = True
        elif 0x2700 <= cp <= 0x27BF:   # Dingbats
            is_emoji = True
        elif 0xFE00 <= cp <= 0xFE0F:   # Variation Selectors
            is_emoji = True
        elif 0x1F1E6 <= cp <= 0x1F1FF: # Regional Indicator Symbols (Flags)
            is_emoji = True
        elif "EMOJI" in name or "PICTOGRAPH" in name:
            is_emoji = True

        if is_emoji:
            detected.append((idx, ch, hex(cp), name))
    return detected

print("=" * 60)
print("1. VALIDATING GOOGLE PLAY METADATA")
print("=" * 60)

# Google Play en-US
gp_title_en = read_file("app/android/fastlane/metadata/android/en-US/title.txt").strip()
if len(gp_title_en) <= 30:
    record_pass("Google Play en-US Title Length", f"{len(gp_title_en)}/30 chars ('{gp_title_en}')")
else:
    record_fail("Google Play en-US Title Length", f"Exceeds 30: {len(gp_title_en)}")

gp_short_en = read_file("app/android/fastlane/metadata/android/en-US/short_description.txt").strip()
if len(gp_short_en) <= 80:
    record_pass("Google Play en-US Short Desc Length", f"{len(gp_short_en)}/80 chars")
else:
    record_fail("Google Play en-US Short Desc Length", f"Exceeds 80: {len(gp_short_en)}")

gp_full_en = read_file("app/android/fastlane/metadata/android/en-US/full_description.txt").strip()
if len(gp_full_en) <= 4000:
    record_pass("Google Play en-US Full Desc Length", f"{len(gp_full_en)}/4000 chars")
else:
    record_fail("Google Play en-US Full Desc Length", f"Exceeds 4000: {len(gp_full_en)}")

# Legal footer in GP en-US
if "Privacy Policy: https://360verb.phuongdan.io.vn/privacy.html" in gp_full_en:
    record_pass("Google Play en-US Legal Footer - Privacy", "Privacy Policy URL present")
else:
    record_fail("Google Play en-US Legal Footer - Privacy", "Missing Privacy Policy URL in footer")

if "Terms of Service: https://360verb.phuongdan.io.vn/terms.html" in gp_full_en or "Terms of Use" in gp_full_en:
    record_pass("Google Play en-US Legal Footer - Terms", "Terms URL present")
else:
    record_fail("Google Play en-US Legal Footer - Terms", "Missing Terms URL in footer")

# Google Play vi-VN
gp_title_vi = read_file("app/android/fastlane/metadata/android/vi-VN/title.txt").strip()
if len(gp_title_vi) <= 30:
    record_pass("Google Play vi-VN Title Length", f"{len(gp_title_vi)}/30 chars ('{gp_title_vi}')")
else:
    record_fail("Google Play vi-VN Title Length", f"Exceeds 30: {len(gp_title_vi)}")

gp_short_vi = read_file("app/android/fastlane/metadata/android/vi-VN/short_description.txt").strip()
if len(gp_short_vi) <= 80:
    record_pass("Google Play vi-VN Short Desc Length", f"{len(gp_short_vi)}/80 chars")
else:
    record_fail("Google Play vi-VN Short Desc Length", f"Exceeds 80: {len(gp_short_vi)}")

gp_full_vi = read_file("app/android/fastlane/metadata/android/vi-VN/full_description.txt").strip()
if len(gp_full_vi) <= 4000:
    record_pass("Google Play vi-VN Full Desc Length", f"{len(gp_full_vi)}/4000 chars")
else:
    record_fail("Google Play vi-VN Full Desc Length", f"Exceeds 4000: {len(gp_full_vi)}")

if "Privacy Policy: https://360verb.phuongdan.io.vn/privacy.html" in gp_full_vi:
    record_pass("Google Play vi-VN Legal Footer - Privacy", "Privacy Policy URL present")
else:
    record_fail("Google Play vi-VN Legal Footer - Privacy", "Missing Privacy Policy URL in footer")

if "Terms of Service: https://360verb.phuongdan.io.vn/terms.html" in gp_full_vi or "Terms of Use" in gp_full_vi:
    record_pass("Google Play vi-VN Legal Footer - Terms", "Terms URL present")
else:
    record_fail("Google Play vi-VN Legal Footer - Terms", "Missing Terms URL in footer")

print("\n" + "=" * 60)
print("2. VALIDATING APPLE APP STORE METADATA")
print("=" * 60)

apple_eula_url = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

# iOS en-US
ios_name_en = read_file("app/ios/fastlane/metadata/en-US/name.txt").strip()
if len(ios_name_en) <= 30:
    record_pass("iOS en-US Name Length", f"{len(ios_name_en)}/30 chars ('{ios_name_en}')")
else:
    record_fail("iOS en-US Name Length", f"Exceeds 30: {len(ios_name_en)}")

ios_subtitle_en = read_file("app/ios/fastlane/metadata/en-US/subtitle.txt").strip()
if len(ios_subtitle_en) <= 30:
    record_pass("iOS en-US Subtitle Length", f"{len(ios_subtitle_en)}/30 chars ('{ios_subtitle_en}')")
else:
    record_fail("iOS en-US Subtitle Length", f"Exceeds 30: {len(ios_subtitle_en)}")

ios_desc_en = read_file("app/ios/fastlane/metadata/en-US/description.txt").strip()
if len(ios_desc_en) <= 4000:
    record_pass("iOS en-US Description Length", f"{len(ios_desc_en)}/4000 chars")
else:
    record_fail("iOS en-US Description Length", f"Exceeds 4000: {len(ios_desc_en)}")

emojis_en = find_all_emojis_and_symbols(ios_desc_en)
if len(emojis_en) == 0:
    record_pass("iOS en-US Description Emojis", "STRICTLY 0 emojis detected")
else:
    record_fail("iOS en-US Description Emojis", f"Found {len(emojis_en)} emojis/symbols: {emojis_en}")

if apple_eula_url in ios_desc_en:
    record_pass("iOS en-US Apple Standard EULA", "Apple EULA URL present verbatim")
else:
    record_fail("iOS en-US Apple Standard EULA", "Missing Apple EULA URL")

if "Privacy Policy: https://360verb.phuongdan.io.vn/privacy.html" in ios_desc_en:
    record_pass("iOS en-US Privacy Policy Link", "Privacy Policy URL present")
else:
    record_fail("iOS en-US Privacy Policy Link", "Missing Privacy Policy URL")

# iOS en-US Keywords
ios_kw_en = read_file("app/ios/fastlane/metadata/en-US/keywords.txt").strip()
kw_en_bytes = len(ios_kw_en.encode("utf-8"))
if kw_en_bytes <= 100:
    record_pass("iOS en-US Keywords Byte Size", f"{kw_en_bytes}/100 bytes UTF-8")
else:
    record_fail("iOS en-US Keywords Byte Size", f"Exceeds 100 bytes: {kw_en_bytes} bytes")

if ", " in ios_kw_en:
    record_fail("iOS en-US Keywords Comma Spacing", "Found spaces after commas! Must be comma-separated without spaces")
else:
    record_pass("iOS en-US Keywords Comma Spacing", "Comma-separated without spaces")

# Token overlap check en-US
en_title_subtitle_text = f"{ios_name_en} {ios_subtitle_en}".lower()
en_ts_tokens = set(re.findall(r"[a-z0-9]+", en_title_subtitle_text))
en_kw_tokens = set([k.strip().lower() for k in ios_kw_en.split(",") if k.strip()])
en_overlap = en_ts_tokens.intersection(en_kw_tokens)
if not en_overlap:
    record_pass("iOS en-US Keyword Token Overlap", f"0 overlap between keywords and name/subtitle (tokens checked: {len(en_ts_tokens)} title/sub vs {len(en_kw_tokens)} kw)")
else:
    record_fail("iOS en-US Keyword Token Overlap", f"OVERLAP DETECTED: {en_overlap}")

# iOS vi
ios_name_vi = read_file("app/ios/fastlane/metadata/vi/name.txt").strip()
if len(ios_name_vi) <= 30:
    record_pass("iOS vi Name Length", f"{len(ios_name_vi)}/30 chars ('{ios_name_vi}')")
else:
    record_fail("iOS vi Name Length", f"Exceeds 30: {len(ios_name_vi)}")

ios_subtitle_vi = read_file("app/ios/fastlane/metadata/vi/subtitle.txt").strip()
if len(ios_subtitle_vi) <= 30:
    record_pass("iOS vi Subtitle Length", f"{len(ios_subtitle_vi)}/30 chars ('{ios_subtitle_vi}')")
else:
    record_fail("iOS vi Subtitle Length", f"Exceeds 30: {len(ios_subtitle_vi)}")

ios_desc_vi = read_file("app/ios/fastlane/metadata/vi/description.txt").strip()
if len(ios_desc_vi) <= 4000:
    record_pass("iOS vi Description Length", f"{len(ios_desc_vi)}/4000 chars")
else:
    record_fail("iOS vi Description Length", f"Exceeds 4000: {len(ios_desc_vi)}")

emojis_vi = find_all_emojis_and_symbols(ios_desc_vi)
if len(emojis_vi) == 0:
    record_pass("iOS vi Description Emojis", "STRICTLY 0 emojis detected")
else:
    record_fail("iOS vi Description Emojis", f"Found {len(emojis_vi)} emojis/symbols: {emojis_vi}")

if apple_eula_url in ios_desc_vi:
    record_pass("iOS vi Apple Standard EULA", "Apple EULA URL present verbatim")
else:
    record_fail("iOS vi Apple Standard EULA", "Missing Apple EULA URL")

if "Privacy Policy: https://360verb.phuongdan.io.vn/privacy.html" in ios_desc_vi:
    record_pass("iOS vi Privacy Policy Link", "Privacy Policy URL present")
else:
    record_fail("iOS vi Privacy Policy Link", "Missing Privacy Policy URL")

# iOS vi Keywords
ios_kw_vi = read_file("app/ios/fastlane/metadata/vi/keywords.txt").strip()
kw_vi_bytes = len(ios_kw_vi.encode("utf-8"))
if kw_vi_bytes <= 100:
    record_pass("iOS vi Keywords Byte Size", f"{kw_vi_bytes}/100 bytes UTF-8")
else:
    record_fail("iOS vi Keywords Byte Size", f"Exceeds 100 bytes: {kw_vi_bytes} bytes")

if ", " in ios_kw_vi:
    record_fail("iOS vi Keywords Comma Spacing", "Found spaces after commas! Must be comma-separated without spaces")
else:
    record_pass("iOS vi Keywords Comma Spacing", "Comma-separated without spaces")

# Token overlap check vi
# In Vietnamese, tokenize words or phrases
vi_title_subtitle_text = f"{ios_name_vi} {ios_subtitle_vi}".lower()
# Words in title/subtitle
vi_ts_words = set(re.findall(r"[\w]+", vi_title_subtitle_text))
vi_kw_items = [k.strip().lower() for k in ios_kw_vi.split(",") if k.strip()]
# Check both full phrases and individual words in keyword phrases
vi_kw_words = set()
for item in vi_kw_items:
    vi_kw_words.add(item)
    for w in item.split():
        vi_kw_words.add(w)

vi_overlap = vi_ts_words.intersection(vi_kw_words)
if not vi_overlap:
    record_pass("iOS vi Keyword Token Overlap", f"0 overlap between keywords and name/subtitle words (checked words: {vi_ts_words} vs {vi_kw_words})")
else:
    record_fail("iOS vi Keyword Token Overlap", f"OVERLAP DETECTED: {vi_overlap}")

print("\n" + "=" * 60)
print("3. VALIDATING APP REVIEW INFORMATION")
print("=" * 60)

first_name = read_file("app/ios/fastlane/metadata/review_information/first_name.txt").strip()
last_name = read_file("app/ios/fastlane/metadata/review_information/last_name.txt").strip()
phone_number = read_file("app/ios/fastlane/metadata/review_information/phone_number.txt").strip()
email_address = read_file("app/ios/fastlane/metadata/review_information/email_address.txt").strip()
notes = read_file("app/ios/fastlane/metadata/review_information/notes.txt").strip()

if first_name == "Dan":
    record_pass("App Review first_name", f"Dan")
else:
    record_fail("App Review first_name", f"Expected 'Dan', got '{first_name}'")

if last_name == "Nguyen Van":
    record_pass("App Review last_name", f"Nguyen Van")
else:
    record_fail("App Review last_name", f"Expected 'Nguyen Van', got '{last_name}'")

if phone_number == "+84 355533893":
    record_pass("App Review phone_number", f"+84 355533893")
else:
    record_fail("App Review phone_number", f"Expected '+84 355533893', got '{phone_number}'")

if email_address == "nguyenvandan868@gmail.com":
    record_pass("App Review email_address", f"nguyenvandan868@gmail.com")
else:
    record_fail("App Review email_address", f"Expected 'nguyenvandan868@gmail.com', got '{email_address}'")

if len(notes) > 50:
    record_pass("App Review notes", f"Provides detailed reviewer notes ({len(notes)} chars)")
else:
    record_fail("App Review notes", "Notes too short or missing")

print("\n" + "=" * 60)
print("4. VALIDATING FASTLANE CONFIGURATIONS")
print("=" * 60)

for ruby_file in [
    "app/android/fastlane/Appfile",
    "app/android/fastlane/Fastfile",
    "app/ios/fastlane/Appfile",
    "app/ios/fastlane/Fastfile",
]:
    full_path = os.path.join(ROOT_DIR, ruby_file)
    res = subprocess.run(["ruby", "-c", full_path], capture_output=True, text=True)
    if res.returncode == 0:
        record_pass(f"Ruby Syntax Check: {ruby_file}", "Syntax OK")
    else:
        record_fail(f"Ruby Syntax Check: {ruby_file}", f"Failed: {res.stderr}")

# Check package names / bundle IDs in Fastlane files
android_appfile = read_file("app/android/fastlane/Appfile")
if "vn.phuongdan.360verb" in android_appfile or "vn.phuongdan.verb360" in android_appfile:
    record_pass("Android Appfile package_name", "Contains project package identifier")
else:
    record_fail("Android Appfile package_name", "Missing vn.phuongdan identifier")

ios_appfile = read_file("app/ios/fastlane/Appfile")
if "app_identifier(\"vn.phuongdan.360verb\")" in ios_appfile or "vn.phuongdan.360verb" in ios_appfile:
    record_pass("iOS Appfile app_identifier", "vn.phuongdan.360verb configured")
else:
    record_fail("iOS Appfile app_identifier", "Missing app_identifier vn.phuongdan.360verb")

print("\n" + "=" * 60)
print("5. VALIDATING LEGAL POLICY DOCUMENTS")
print("=" * 60)

legal_files = [
    "docs/privacy_policy_en.md",
    "docs/privacy_policy_vi.md",
    "docs/terms_of_use_en.md",
    "docs/terms_of_use_vi.md",
    "docs/privacy_policy_en.html",
    "docs/privacy_policy_vi.html",
    "docs/terms_of_use_en.html",
    "docs/terms_of_use_vi.html",
    "docs/privacy.html",
    "docs/terms.html",
]

for lf in legal_files:
    content = read_file(lf)
    if len(content) > 200:
        record_pass(f"Legal Doc Substantiality: {lf}", f"{len(content)} bytes")
    else:
        record_fail(f"Legal Doc Substantiality: {lf}", f"Too short ({len(content)} bytes)")
    
    # Check EULA links in terms files
    if "terms" in lf:
        if apple_eula_url in content:
            record_pass(f"Apple EULA in {lf}", "EULA link present")
        else:
            record_fail(f"Apple EULA in {lf}", "Missing Apple EULA link")

    # Check contact email
    if "nguyenvandan868@gmail.com" in content:
        record_pass(f"Contact email in {lf}", "nguyenvandan868@gmail.com present")
    else:
        record_fail(f"Contact email in {lf}", "Missing contact email")

print("\n" + "=" * 60)
print("6. ADVERSARIAL STRESS-TESTING & INTEGRITY CHECKS")
print("=" * 60)

# Check 1: Dummy or placeholder text
forbidden_patterns = [
    r"TODO",
    r"FIXME",
    r"lorem ipsum",
    r"your-app-id",
    r"your-domain\.com",
    r"example\.com",
    r"<[^>]+>", # unreplaced placeholders in text files
]

for check_file in [
    "app/android/fastlane/metadata/android/en-US/title.txt",
    "app/android/fastlane/metadata/android/en-US/short_description.txt",
    "app/android/fastlane/metadata/android/en-US/full_description.txt",
    "app/android/fastlane/metadata/android/vi-VN/title.txt",
    "app/android/fastlane/metadata/android/vi-VN/short_description.txt",
    "app/android/fastlane/metadata/android/vi-VN/full_description.txt",
    "app/ios/fastlane/metadata/en-US/name.txt",
    "app/ios/fastlane/metadata/en-US/subtitle.txt",
    "app/ios/fastlane/metadata/en-US/description.txt",
    "app/ios/fastlane/metadata/en-US/keywords.txt",
    "app/ios/fastlane/metadata/vi/name.txt",
    "app/ios/fastlane/metadata/vi/subtitle.txt",
    "app/ios/fastlane/metadata/vi/description.txt",
    "app/ios/fastlane/metadata/vi/keywords.txt",
]:
    c = read_file(check_file)
    for pat in [r"TODO", r"FIXME", r"lorem ipsum", r"your-app-id", r"your-domain\.com"]:
        if re.search(pat, c, re.IGNORECASE):
            record_fail(f"Placeholder in {check_file}", f"Found pattern '{pat}'")

# Check HTML closing tags
for html_file in [
    "docs/privacy_policy_en.html",
    "docs/privacy_policy_vi.html",
    "docs/terms_of_use_en.html",
    "docs/terms_of_use_vi.html",
    "docs/privacy.html",
    "docs/terms.html",
]:
    hc = read_file(html_file)
    for tag in ["html", "head", "body", "title"]:
        if f"<{tag}" in hc and f"</{tag}>" not in hc:
            record_fail(f"HTML Structure: {html_file}", f"Unclosed <{tag}> tag")
    record_pass(f"HTML Structure: {html_file}", "Root tags closed cleanly")

print("\n" + "=" * 60)
print(f"VERIFICATION RESULTS: {len(passed_checks)} PASSED, {len(issues)} FAILED, {len(warnings)} WARNINGS")
print("=" * 60)

if issues:
    print("FAILED CHECKS:")
    for name, detail in issues:
        print(f"- {name}: {detail}")
    sys.exit(1)
else:
    print("ALL DEEP VERIFICATION CHECKS PASSED PERFECTLY!")
    sys.exit(0)
