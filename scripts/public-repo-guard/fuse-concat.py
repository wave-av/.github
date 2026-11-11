#!/usr/bin/env python3
"""Rebuild source files with quoted concatenations joined (stdin: relative paths)."""
from __future__ import annotations

import os
import re
import sys

PLUS = re.compile(r"""['"]\s*\+\s*['"]""")
CONTINUATION = re.compile(r"\\\r?\n")
IMPLICIT_NL = re.compile(r"""['"][ \t]*\r?\n[ \t]*['"]""")
IMPLICIT_SP = re.compile(r"""['"][ \t]+['"]""")


def fuse(text: str, implicit: bool) -> str:
    data = CONTINUATION.sub("", text)
    data = PLUS.sub("", data)
    if implicit:
        data = IMPLICIT_NL.sub("", data)
        data = IMPLICIT_SP.sub("", data)
    return data


def main() -> int:
    dest = sys.argv[1]
    written = 0
    for rel in sys.stdin:
        rel = rel.rstrip("\n")
        if not rel or not os.path.isfile(rel):
            continue
        try:
            with open(rel, "r", encoding="utf-8", errors="surrogateescape") as fh:
                original = fh.read()
        except OSError:
            continue
        if "\0" in original:
            continue
        fused = fuse(original, rel.endswith(".py"))
        if fused == original:
            continue
        out = os.path.join(dest, rel)
        parent = os.path.dirname(out)
        if parent:
            os.makedirs(parent, exist_ok=True)
        with open(out, "w", encoding="utf-8", errors="surrogateescape") as fh:
            fh.write(fused)
        written += 1
    print(written)
    return 0


if __name__ == "__main__":
    sys.exit(main())
