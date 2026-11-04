#!/usr/bin/env python3
"""
Independent Adversarial Stress-Test and Verification Script for Milestone M3.
Evaluates store materials, Fastlane configs, character/byte constraints,
unicode emoji presence, keyword overlap, legal links, and integrity.
"""

import os
import re
import subprocess
import sys
import unicodedata

ROOT_DIR = "/Volumes/DAT/GIT/360_verb"

def run_tests():
    checks = []
    
    def log_check(name, passed, detail=""):
        checks.append((name, passed, detail))
        status = "[PASS]" if passed else "[FAIL]"
        print(f"{status} {name}: {detail}")

    # 1. Google Play Android
    # en-US
    p_title_en = os.path.join(ROOT_DIR, "app/android/fastlane/metadata/android/en-US/title.txt")
    p_short_en = os.path.join(ROOT_DIR, "app/android/fastlane/metadata/android/en-US/short_description.txt")
    p_full_en = os.path.join(ROOT_DIR, "app/android/fastlane/metadata/android/en-US/full_description.txt")
    
    with open(p_title_en, "r", encoding="utf-8") as f:
        t_en = f.read().strip()
    with open(p_short_en, "r", encoding="utf-8") as f:
        s_en = f.read().strip()
    with open(p_full_en, "r", encoding="utf-8") as f:
        f_en = f.read().strip()

    log_check("Android en-US Title <= 30", len(t_en) <= 30, f"{len(t_en)} chars: '{t_en}'")
    log_check("Android en-US Short Desc <= 80", len(s_en) <= 80, f"{len(s_en)} chars")
    log_check("Android en-US Full Desc <= 4000", len(f_en) <= 4000, f"{len(f_en)} chars")
    log_check("Android en-US Full Desc Privacy Policy link", "https://360verb.phuongdan.io.vn/privacy.html" in f_en, "URL present")
    log_check("Android en-US Full Desc Terms link", "https://360verb.phuongdan.io.vn/terms.html" in f_en, "URL present")

    # vi-VN
    p_title_vi = os.path.join(ROOT_DIR, "app/android/fastlane/metadata/android/vi-VN/title.txt")
    p_short_vi = os.path.join(ROOT_DIR, "app/android/fastlane/metadata/android/vi-VN/short_description.txt")
    p_full_vi = os.path.join(ROOT_DIR, "app/android/fastlane/metadata/android/vi-VN/full_description.txt")
    
    with open(p_title_vi, "r", encoding="utf-8") as f:
        t_vi = f.read().strip()
    with open(p_short_vi, "r", encoding="utf-8") as f:
        s_vi = f.read().strip()
    with open(p_full_vi, "r", encoding="utf-8") as f:
        f_vi = f.read().strip()

    log_check("Android vi-VN Title <= 30", len(t_vi) <= 30, f"{len(t_vi)} chars: '{t_vi}'")
    log_check("Android vi-VN Short Desc <= 80", len(s_vi) <= 80, f"{len(s_vi)} chars")
    log_check("Android vi-VN Full Desc <= 4000", len(f_vi) <= 4000, f"{len(f_vi)} chars")
    log_check("Android vi-VN Full Desc Privacy Policy link", "https://360verb.phuongdan.io.vn/privacy.html" in f_vi, "URL present")
    log_check("Android vi-VN Full Desc Terms link", "https://360verb.phuongdan.io.vn/terms.html" in f_vi, "URL present")

    # 2. Apple App Store iOS
    apple_eula = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

    def find_all_emojis(text):
        emoji_pattern = re.compile(
            "["
            "\U0001F600-\U0001F64F"  # emoticons
            "\U0001F300-\U0001F5FF"  # symbols & pictographs
            "\U0001F680-\U0001F6FF"  # transport & map
            "\U0001F1E0-\U0001F1FF"  # flags (iOS)
            "\U00002702-\U000027B0"
            "\U000024C2-\U0001F251"
            "\U0001F900-\U0001F9FF"  # supplemental symbols
            "\U0001FA70-\U0001FAFF"  # symbols and pictographs extended-a
            "\U00002600-\U000026FF"  # misc symbols
            "]+",
            flags=re.UNICODE,
        )
        return emoji_pattern.findall(text)

    # iOS en-US
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/en-US/name.txt"), "r", encoding="utf-8") as f:
        ios_name_en = f.read().strip()
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/en-US/subtitle.txt"), "r", encoding="utf-8") as f:
        ios_sub_en = f.read().strip()
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/en-US/description.txt"), "r", encoding="utf-8") as f:
        ios_desc_en = f.read().strip()
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/en-US/keywords.txt"), "r", encoding="utf-8") as f:
        ios_kw_en = f.read().strip()
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/en-US/promotional_text.txt"), "r", encoding="utf-8") as f:
        ios_promo_en = f.read().strip()

    log_check("iOS en-US Name <= 30", len(ios_name_en) <= 30, f"{len(ios_name_en)} chars: '{ios_name_en}'")
    log_check("iOS en-US Subtitle <= 30", len(ios_sub_en) <= 30, f"{len(ios_sub_en)} chars: '{ios_sub_en}'")
    log_check("iOS en-US Desc <= 4000", len(ios_desc_en) <= 4000, f"{len(ios_desc_en)} chars")
    
    emojis_en = find_all_emojis(ios_desc_en)
    log_check("iOS en-US Desc 0 emojis", len(emojis_en) == 0, f"Found {len(emojis_en)} emojis: {emojis_en}")
    log_check("iOS en-US Desc Apple standard EULA", apple_eula in ios_desc_en, "EULA present")
    log_check("iOS en-US Desc Privacy Policy", "https://360verb.phuongdan.io.vn/privacy.html" in ios_desc_en, "Privacy URL present")
    
    kw_en_bytes = len(ios_kw_en.encode("utf-8"))
    log_check("iOS en-US Keywords <= 100 bytes UTF-8", kw_en_bytes <= 100, f"{kw_en_bytes} bytes: '{ios_kw_en}'")
    log_check("iOS en-US Keywords no space after comma", ", " not in ios_kw_en, "No spaces")
    
    # Overlap check
    name_sub_words_en = set(re.findall(r"\w+", (ios_name_en + " " + ios_sub_en).lower()))
    kw_tokens_en = [w.strip().lower() for w in ios_kw_en.split(",")]
    overlap_en = [w for w in kw_tokens_en if w in name_sub_words_en]
    log_check("iOS en-US Keywords 0 overlap with Title/Subtitle", len(overlap_en) == 0, f"Overlaps: {overlap_en}")
    log_check("iOS en-US Promo Text <= 170", len(ios_promo_en) <= 170, f"{len(ios_promo_en)} chars")

    # iOS vi
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/vi/name.txt"), "r", encoding="utf-8") as f:
        ios_name_vi = f.read().strip()
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/vi/subtitle.txt"), "r", encoding="utf-8") as f:
        ios_sub_vi = f.read().strip()
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/vi/description.txt"), "r", encoding="utf-8") as f:
        ios_desc_vi = f.read().strip()
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/vi/keywords.txt"), "r", encoding="utf-8") as f:
        ios_kw_vi = f.read().strip()
    with open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/vi/promotional_text.txt"), "r", encoding="utf-8") as f:
        ios_promo_vi = f.read().strip()

    log_check("iOS vi Name <= 30", len(ios_name_vi) <= 30, f"{len(ios_name_vi)} chars: '{ios_name_vi}'")
    log_check("iOS vi Subtitle <= 30", len(ios_sub_vi) <= 30, f"{len(ios_sub_vi)} chars: '{ios_sub_vi}'")
    log_check("iOS vi Desc <= 4000", len(ios_desc_vi) <= 4000, f"{len(ios_desc_vi)} chars")
    
    emojis_vi = find_all_emojis(ios_desc_vi)
    log_check("iOS vi Desc 0 emojis", len(emojis_vi) == 0, f"Found {len(emojis_vi)} emojis: {emojis_vi}")
    log_check("iOS vi Desc Apple standard EULA", apple_eula in ios_desc_vi, "EULA present")
    log_check("iOS vi Desc Privacy Policy", "https://360verb.phuongdan.io.vn/privacy.html" in ios_desc_vi, "Privacy URL present")
    
    kw_vi_bytes = len(ios_kw_vi.encode("utf-8"))
    log_check("iOS vi Keywords <= 100 bytes UTF-8", kw_vi_bytes <= 100, f"{kw_vi_bytes} bytes: '{ios_kw_vi}'")
    log_check("iOS vi Keywords no space after comma", ", " not in ios_kw_vi, "No spaces")
    
    name_sub_words_vi = set(re.findall(r"\w+", (ios_name_vi + " " + ios_sub_vi).lower()))
    kw_tokens_vi = [w.strip().lower() for w in ios_kw_vi.split(",")]
    overlap_vi = [w for w in kw_tokens_vi if w in name_sub_words_vi]
    log_check("iOS vi Keywords 0 overlap with Title/Subtitle", len(overlap_vi) == 0, f"Overlaps: {overlap_vi}")
    log_check("iOS vi Promo Text <= 170", len(ios_promo_vi) <= 170, f"{len(ios_promo_vi)} chars")

    # 3. App Review information
    rev_first = open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/review_information/first_name.txt")).read().strip()
    rev_last = open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/review_information/last_name.txt")).read().strip()
    rev_phone = open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/review_information/phone_number.txt")).read().strip()
    rev_email = open(os.path.join(ROOT_DIR, "app/ios/fastlane/metadata/review_information/email_address.txt")).read().strip()
    
    log_check("Review Info first_name == 'Dan'", rev_first == "Dan", f"Got '{rev_first}'")
    log_check("Review Info last_name == 'Nguyen Van'", rev_last == "Nguyen Van", f"Got '{rev_last}'")
    log_check("Review Info phone_number == '+84 355533893'", rev_phone == "+84 355533893", f"Got '{rev_phone}'")
    log_check("Review Info email_address == 'nguyenvandan868@gmail.com'", rev_email == "nguyenvandan868@gmail.com", f"Got '{rev_email}'")

    # 4. Fastlane configuration files
    for r_file in [
        "app/android/fastlane/Appfile",
        "app/android/fastlane/Fastfile",
        "app/ios/fastlane/Appfile",
        "app/ios/fastlane/Fastfile",
    ]:
        full_p = os.path.join(ROOT_DIR, r_file)
        res = subprocess.run(["ruby", "-c", full_p], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        log_check(f"Fastlane Ruby Syntax {r_file}", res.returncode == 0, res.stdout.strip())

    # Check Appfile identifiers
    appfile_android = open(os.path.join(ROOT_DIR, "app/android/fastlane/Appfile")).read()
    appfile_ios = open(os.path.join(ROOT_DIR, "app/ios/fastlane/Appfile")).read()
    log_check("Android Appfile package_name has 'vn.phuongdan.verb360'", "vn.phuongdan.verb360" in appfile_android, "Matches Android namespace")
    log_check("iOS Appfile app_identifier is 'vn.phuongdan.360verb'", 'app_identifier("vn.phuongdan.360verb")' in appfile_ios, "Matches iOS bundle ID")

    # 5. Legal Policies in docs/
    legal_files = [
        "docs/privacy_policy_en.md",
        "docs/privacy_policy_en.html",
        "docs/privacy_policy_vi.md",
        "docs/privacy_policy_vi.html",
        "docs/terms_of_use_en.md",
        "docs/terms_of_use_en.html",
        "docs/terms_of_use_vi.md",
        "docs/terms_of_use_vi.html",
        "docs/privacy.html",
        "docs/terms.html"
    ]
    for lf in legal_files:
        full_lf = os.path.join(ROOT_DIR, lf)
        exists = os.path.exists(full_lf)
        size = os.path.getsize(full_lf) if exists else 0
        log_check(f"Legal Doc exists and substantive: {lf}", exists and size > 500, f"{size} bytes")
        if "terms" in lf:
            content = open(full_lf, encoding="utf-8").read()
            log_check(f"Terms doc {lf} includes Apple Standard EULA", apple_eula in content, "Found Apple EULA")

    # 6. Integrity checks
    # Check for placeholder markers like TODO, FIXME, XXX, LOREM IPSUM, DUMMY
    bad_tokens = ["TODO", "FIXME", "XXX", "LOREM IPSUM", "DUMMY", "FACADE"]
    found_bad = []
    for root, _, files in os.walk(os.path.join(ROOT_DIR, "app/android/fastlane")):
        for f in files:
            path = os.path.join(root, f)
            text = open(path, "r", encoding="utf-8", errors="ignore").read()
            for bt in bad_tokens:
                if bt.lower() in text.lower():
                    found_bad.append((path, bt))
    for root, _, files in os.walk(os.path.join(ROOT_DIR, "app/ios/fastlane")):
        for f in files:
            path = os.path.join(root, f)
            text = open(path, "r", encoding="utf-8", errors="ignore").read()
            for bt in bad_tokens:
                if bt.lower() in text.lower():
                    found_bad.append((path, bt))
    for root, _, files in os.walk(os.path.join(ROOT_DIR, "docs")):
        for f in files:
            path = os.path.join(root, f)
            text = open(path, "r", encoding="utf-8", errors="ignore").read()
            for bt in bad_tokens:
                if bt.lower() in text.lower():
                    found_bad.append((path, bt))
    
    log_check("Integrity: Zero dummy/placeholder tokens", len(found_bad) == 0, f"Found {len(found_bad)}: {found_bad}")

    # Report results
    total = len(checks)
    failures = [c for c in checks if not c[1]]
    print(f"\n==========================================")
    print(f"Total Checks: {total} | Passed: {total - len(failures)} | Failed: {len(failures)}")
    if failures:
        print("FAILURES:")
        for f in failures:
            print(f"- {f[0]}: {f[2]}")
        sys.exit(1)
    else:
        print("ALL AUDIT AND STRESS TESTS PASSED CLEANLY!")
        sys.exit(0)

if __name__ == "__main__":
    run_tests()
