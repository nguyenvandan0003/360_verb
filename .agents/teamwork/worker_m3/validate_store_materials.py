#!/usr/bin/env python3
"""
Automated Verification Script for Milestone M3: Store Upload Materials & Fastlane Deployment.
Checks character limits, UTF-8 byte sizes, emoji absences, legal URL presences, and Fastlane syntax.
"""

import os
import re
import subprocess
import sys
import unicodedata

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))

failures = []
passed = 0


def assert_condition(condition, msg):
    global passed
    if not condition:
        print(f"[FAIL] {msg}")
        failures.append(msg)
    else:
        print(f"[PASS] {msg}")
        passed += 1


def read_file(rel_path):
    full_path = os.path.join(ROOT_DIR, rel_path)
    assert_condition(os.path.exists(full_path), f"File exists: {rel_path}")
    if not os.path.exists(full_path):
        return ""
    with open(full_path, "r", encoding="utf-8") as f:
        return f.read()


def count_emojis(text):
    # Regex for common emoji ranges
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
        "]+",
        flags=re.UNICODE,
    )
    return len(emoji_pattern.findall(text))


def check_ruby_syntax(rel_path):
    full_path = os.path.join(ROOT_DIR, rel_path)
    if not os.path.exists(full_path):
        return
    res = subprocess.run(
        ["ruby", "-c", full_path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    assert_condition(
        res.returncode == 0,
        f"Ruby syntax check for {rel_path}: {res.stdout.strip()} {res.stderr.strip()}",
    )


def test_android_metadata():
    print("\n=== Testing Google Play Android Metadata ===")
    # en-US
    title_en = read_file("app/android/fastlane/metadata/android/en-US/title.txt").strip()
    assert_condition(len(title_en) <= 30, f"Android en-US title <= 30 chars (got {len(title_en)})")

    short_en = read_file("app/android/fastlane/metadata/android/en-US/short_description.txt").strip()
    assert_condition(len(short_en) <= 80, f"Android en-US short_description <= 80 chars (got {len(short_en)})")

    full_en = read_file("app/android/fastlane/metadata/android/en-US/full_description.txt").strip()
    assert_condition(len(full_en) <= 4000, f"Android en-US full_description <= 4000 chars (got {len(full_en)})")
    assert_condition("Privacy Policy:" in full_en, "Android en-US full_description has Privacy Policy link")
    assert_condition("Terms of Service:" in full_en, "Android en-US full_description has Terms link")

    changelog_en = read_file("app/android/fastlane/metadata/android/en-US/changelogs/default.txt").strip()
    assert_condition(len(changelog_en) > 0, "Android en-US changelogs/default.txt exists")

    # vi-VN
    title_vi = read_file("app/android/fastlane/metadata/android/vi-VN/title.txt").strip()
    assert_condition(len(title_vi) <= 30, f"Android vi-VN title <= 30 chars (got {len(title_vi)})")

    short_vi = read_file("app/android/fastlane/metadata/android/vi-VN/short_description.txt").strip()
    assert_condition(len(short_vi) <= 80, f"Android vi-VN short_description <= 80 chars (got {len(short_vi)})")

    full_vi = read_file("app/android/fastlane/metadata/android/vi-VN/full_description.txt").strip()
    assert_condition(len(full_vi) <= 4000, f"Android vi-VN full_description <= 4000 chars (got {len(full_vi)})")
    assert_condition("Privacy Policy:" in full_vi, "Android vi-VN full_description has Privacy Policy link")
    assert_condition("Terms of Service:" in full_vi, "Android vi-VN full_description has Terms link")

    changelog_vi = read_file("app/android/fastlane/metadata/android/vi-VN/changelogs/default.txt").strip()
    assert_condition(len(changelog_vi) > 0, "Android vi-VN changelogs/default.txt exists")


def test_ios_metadata():
    print("\n=== Testing Apple App Store iOS Metadata ===")
    apple_eula = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

    # Root metadata
    for root_file in [
        "primary_category.txt",
        "secondary_category.txt",
        "copyright.txt",
        "privacy_url.txt",
        "support_url.txt",
        "marketing_url.txt",
    ]:
        content = read_file(f"app/ios/fastlane/metadata/{root_file}").strip()
        assert_condition(len(content) > 0, f"iOS root metadata/{root_file} is non-empty")

    # en-US
    name_en = read_file("app/ios/fastlane/metadata/en-US/name.txt").strip()
    assert_condition(len(name_en) <= 30, f"iOS en-US name <= 30 chars (got {len(name_en)})")

    subtitle_en = read_file("app/ios/fastlane/metadata/en-US/subtitle.txt").strip()
    assert_condition(len(subtitle_en) <= 30, f"iOS en-US subtitle <= 30 chars (got {len(subtitle_en)})")

    desc_en = read_file("app/ios/fastlane/metadata/en-US/description.txt").strip()
    assert_condition(len(desc_en) <= 4000, f"iOS en-US description <= 4000 chars (got {len(desc_en)})")
    assert_condition(count_emojis(desc_en) == 0, f"iOS en-US description STRICTLY 0 emojis (got {count_emojis(desc_en)})")
    assert_condition(apple_eula in desc_en, "iOS en-US description has standard Apple EULA URL")
    assert_condition("Privacy Policy:" in desc_en, "iOS en-US description has Privacy Policy URL")

    kw_en = read_file("app/ios/fastlane/metadata/en-US/keywords.txt").strip()
    kw_en_bytes = len(kw_en.encode("utf-8"))
    assert_condition(kw_en_bytes <= 100, f"iOS en-US keywords <= 100 bytes UTF-8 (got {kw_en_bytes} bytes)")
    assert_condition(", " not in kw_en, "iOS en-US keywords has no space after comma")

    # Check non-overlap with title & subtitle
    name_words = set(re.findall(r"\w+", (name_en + " " + subtitle_en).lower()))
    kw_items_en = kw_en.lower().split(",")
    overlap_en = [w for w in kw_items_en if w in name_words]
    assert_condition(len(overlap_en) == 0, f"iOS en-US keywords 0 overlap with name/subtitle (overlap: {overlap_en})")

    promo_en = read_file("app/ios/fastlane/metadata/en-US/promotional_text.txt").strip()
    assert_condition(len(promo_en) <= 170, f"iOS en-US promotional_text <= 170 chars (got {len(promo_en)})")

    for u in ["privacy_url.txt", "support_url.txt", "marketing_url.txt", "release_notes.txt"]:
        val = read_file(f"app/ios/fastlane/metadata/en-US/{u}").strip()
        assert_condition(len(val) > 0, f"iOS en-US {u} is non-empty")

    # vi
    name_vi = read_file("app/ios/fastlane/metadata/vi/name.txt").strip()
    assert_condition(len(name_vi) <= 30, f"iOS vi name <= 30 chars (got {len(name_vi)})")

    subtitle_vi = read_file("app/ios/fastlane/metadata/vi/subtitle.txt").strip()
    assert_condition(len(subtitle_vi) <= 30, f"iOS vi subtitle <= 30 chars (got {len(subtitle_vi)})")

    desc_vi = read_file("app/ios/fastlane/metadata/vi/description.txt").strip()
    assert_condition(len(desc_vi) <= 4000, f"iOS vi description <= 4000 chars (got {len(desc_vi)})")
    assert_condition(count_emojis(desc_vi) == 0, f"iOS vi description STRICTLY 0 emojis (got {count_emojis(desc_vi)})")
    assert_condition(apple_eula in desc_vi, "iOS vi description has standard Apple EULA URL")
    assert_condition("Privacy Policy:" in desc_vi, "iOS vi description has Privacy Policy URL")

    kw_vi = read_file("app/ios/fastlane/metadata/vi/keywords.txt").strip()
    kw_vi_bytes = len(kw_vi.encode("utf-8"))
    assert_condition(kw_vi_bytes <= 100, f"iOS vi keywords <= 100 bytes UTF-8 (got {kw_vi_bytes} bytes)")
    assert_condition(", " not in kw_vi, "iOS vi keywords has no space after comma")

    name_vi_words = set(re.findall(r"\w+", (name_vi + " " + subtitle_vi).lower()))
    kw_items_vi = kw_vi.lower().split(",")
    overlap_vi = [w for w in kw_items_vi if w in name_vi_words]
    assert_condition(len(overlap_vi) == 0, f"iOS vi keywords 0 overlap with name/subtitle (overlap: {overlap_vi})")

    promo_vi = read_file("app/ios/fastlane/metadata/vi/promotional_text.txt").strip()
    assert_condition(len(promo_vi) <= 170, f"iOS vi promotional_text <= 170 chars (got {len(promo_vi)})")

    for u in ["privacy_url.txt", "support_url.txt", "marketing_url.txt", "release_notes.txt"]:
        val = read_file(f"app/ios/fastlane/metadata/vi/{u}").strip()
        assert_condition(len(val) > 0, f"iOS vi {u} is non-empty")


def test_review_information():
    print("\n=== Testing iOS Review Information ===")
    assert_condition(
        read_file("app/ios/fastlane/metadata/review_information/first_name.txt").strip() == "Dan",
        "first_name.txt is 'Dan'",
    )
    assert_condition(
        read_file("app/ios/fastlane/metadata/review_information/last_name.txt").strip() == "Nguyen Van",
        "last_name.txt is 'Nguyen Van'",
    )
    assert_condition(
        read_file("app/ios/fastlane/metadata/review_information/phone_number.txt").strip() == "+84 355533893",
        "phone_number.txt is '+84 355533893'",
    )
    assert_condition(
        read_file("app/ios/fastlane/metadata/review_information/email_address.txt").strip() == "nguyenvandan868@gmail.com",
        "email_address.txt is 'nguyenvandan868@gmail.com'",
    )
    assert_condition(
        len(read_file("app/ios/fastlane/metadata/review_information/demo_user.txt").strip()) > 0,
        "demo_user.txt is non-empty",
    )
    assert_condition(
        len(read_file("app/ios/fastlane/metadata/review_information/demo_password.txt").strip()) > 0,
        "demo_password.txt is non-empty",
    )
    assert_condition(
        len(read_file("app/ios/fastlane/metadata/review_information/notes.txt").strip()) > 0,
        "notes.txt is non-empty",
    )


def test_fastlane_configs():
    print("\n=== Testing Fastlane Appfile & Fastfile Syntax ===")
    check_ruby_syntax("app/android/fastlane/Appfile")
    check_ruby_syntax("app/android/fastlane/Fastfile")
    check_ruby_syntax("app/ios/fastlane/Appfile")
    check_ruby_syntax("app/ios/fastlane/Fastfile")


def test_legal_docs():
    print("\n=== Testing Legal Policy Documents ===")
    docs = [
        "docs/privacy_policy_en.md",
        "docs/privacy_policy_en.html",
        "docs/privacy_policy_vi.md",
        "docs/privacy_policy_vi.html",
        "docs/terms_of_use_en.md",
        "docs/terms_of_use_en.html",
        "docs/terms_of_use_vi.md",
        "docs/terms_of_use_vi.html",
    ]
    apple_eula = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

    for d in docs:
        content = read_file(d)
        assert_condition(len(content) > 500, f"{d} has substantial content (bytes: {len(content)})")
        if "terms" in d:
            assert_condition(apple_eula in content, f"{d} includes Apple Standard EULA link")


def main():
    print("Beginning automated validation of Store Upload Materials & Fastlane Deployment...")
    test_android_metadata()
    test_ios_metadata()
    test_review_information()
    test_fastlane_configs()
    test_legal_docs()

    print(f"\nSummary: {passed} assertions PASSED, {len(failures)} FAILED.")
    if failures:
        print("\nFailed assertions:")
        for f in failures:
            print(f"- {f}")
        sys.exit(1)
    else:
        print("\nALL VERIFICATIONS PASSED SUCCESSFULLY!")
        sys.exit(0)


if __name__ == "__main__":
    main()
