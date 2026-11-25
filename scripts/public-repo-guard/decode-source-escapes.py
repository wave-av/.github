#!/usr/bin/env python3
"""Copy a tree, expanding language-level escapes so content-policy BLOCK regexes
still see reconstructed secrets.

gitleaks 8.30.1 already decodes JSON \\uXXXX and base64. It does not decode
JS/Python \\xHH, JS \\u{...}, or HTML numeric entities, and it does not strip
zero-width characters. This copy is additive in spirit: ASCII that was already
visible stays visible; hidden forms become visible.
"""
from __future__ import annotations

import os
import re
import sys

SKIP_DIRS = {
    ".git",
    "node_modules",
    "dist",
    "build",
    ".next",
    "target",
    "vendor",
    "public-repo-guard",
}
SKIP_FILES = {
    "pnpm-lock.yaml",
    "package-lock.json",
    "Cargo.lock",
    "go.sum",
    ".gitleaks.toml",
}
SKIP_SUFFIXES = (".lock",)

HEX = re.compile(r"\\x([0-9a-fA-F]{2})")
UNI_BRACE = re.compile(r"\\u\{([0-9a-fA-F]{1,6})\}")
UNI = re.compile(r"\\u([0-9a-fA-F]{4})")
HTML_HEX = re.compile(r"&#x([0-9a-fA-F]{1,6});", re.IGNORECASE)
HTML_DEC = re.compile(r"&#(\d{1,7});")
ZW = dict.fromkeys(map(ord, "\u200b\u200c\u200d\ufeff\u00ad"), None)
MAX_FILE_BYTES = 2 * 1024 * 1024


def _chr(num: int, fallback: str) -> str:
    if 0 < num <= 0x10FFFF:
        try:
            return chr(num)
        except ValueError:
            return fallback
    return fallback


def expand(text: str) -> str:
    def from_hex(match: re.Match[str]) -> str:
        return _chr(int(match.group(1), 16), match.group(0))

    def from_dec(match: re.Match[str]) -> str:
        return _chr(int(match.group(1), 10), match.group(0))

    text = HEX.sub(from_hex, text)
    text = UNI_BRACE.sub(from_hex, text)
    text = UNI.sub(from_hex, text)
    text = HTML_HEX.sub(from_hex, text)
    text = HTML_DEC.sub(from_dec, text)
    text = text.translate(ZW)
    return text.replace("\x00", "")


def should_skip_file(name: str) -> bool:
    if name in SKIP_FILES:
        return True
    return name.endswith(SKIP_SUFFIXES)


def copy_expanded(src_root: str, dest_root: str) -> None:
    src_root = os.path.abspath(src_root)
    dest_root = os.path.abspath(dest_root)
    if src_root == dest_root or dest_root.startswith(src_root + os.sep):
        raise SystemExit("decode-source-escapes: dest must be outside src")

    for dirpath, dirnames, filenames in os.walk(src_root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        rel_dir = os.path.relpath(dirpath, src_root)
        out_dir = dest_root if rel_dir == "." else os.path.join(dest_root, rel_dir)
        os.makedirs(out_dir, exist_ok=True)
        for name in filenames:
            if should_skip_file(name):
                continue
            src = os.path.join(dirpath, name)
            if os.path.islink(src) or not os.path.isfile(src):
                continue
            try:
                size = os.path.getsize(src)
            except OSError:
                continue
            if size > MAX_FILE_BYTES:
                continue
            try:
                raw = open(src, "rb").read()
            except OSError:
                continue
            if b"\x00" in raw[:8192]:
                continue
            try:
                text = raw.decode("utf-8")
            except UnicodeDecodeError:
                text = raw.decode("latin-1")
            expanded = expand(text)
            dest = os.path.join(out_dir, name)
            with open(dest, "w", encoding="utf-8") as handle:
                handle.write(expanded)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: decode-source-escapes.py SRC DEST", file=sys.stderr)
        return 2
    copy_expanded(sys.argv[1], sys.argv[2])
    return 0


if __name__ == "__main__":
    sys.exit(main())
