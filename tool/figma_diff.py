#!/usr/bin/env python3
"""Pixel diff for Figma-to-Flutter fidelity loops.

    uv run --with pillow --with numpy python tool/figma_diff.py golden.png reference@2x.png

Compares a rendered capture against the exported reference. Resizes the reference to the
capture's size (so 1x vs 2x never silently "matches"), tolerates per-channel noise, and
reports the worst regions so the next fix is obvious.

Exit 0 = under threshold, 1 = over, 2 = bad input.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import numpy as np
    from PIL import Image
except ImportError:
    sys.exit(
        "missing deps: run with  uv run --with pillow --with numpy python tool/figma_diff.py ..."
    )


def load(path: Path) -> Image.Image:
    if not path.exists():
        sys.exit(f"missing file: {path}")
    return Image.open(path).convert("RGBA")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("capture", type=Path, help="golden/screenshot from Flutter")
    ap.add_argument("reference", type=Path, help="exported @2x PNG")
    ap.add_argument(
        "--threshold",
        type=int,
        default=6,
        help="per-channel tolerance 0-255 (default 6)",
    )
    ap.add_argument(
        "--max-pct",
        type=float,
        default=2.0,
        help="fail above this %% of differing pixels (default 2.0)",
    )
    ap.add_argument(
        "--grid",
        type=int,
        default=4,
        help="report worst regions on a grid x grid split (default 4)",
    )
    ap.add_argument("--ignore-alpha", action="store_true")
    args = ap.parse_args()

    cap = load(args.capture)
    ref = load(args.reference)
    if ref.size != cap.size:
        print(f"note: reference {ref.size} resized to capture {cap.size}")
        ref = ref.resize(cap.size, Image.LANCZOS)

    a = np.asarray(cap, dtype=np.int16)
    b = np.asarray(ref, dtype=np.int16)
    if args.ignore_alpha:
        a, b = a[..., :3], b[..., :3]

    delta = np.abs(a - b).max(axis=2)
    bad = delta > args.threshold
    pct = float(bad.mean() * 100.0)

    print(f"capture   : {args.capture}  {cap.size}")
    print(f"reference : {args.reference}  {ref.size}")
    print(f"tolerance : {args.threshold} per channel")
    print(
        f"diff      : {pct:.2f}% of pixels differ (max channel delta {int(delta.max())})"
    )

    g = args.grid
    h, w = bad.shape
    regions = []
    for ry in range(g):
        for rx in range(g):
            block = bad[
                ry * h // g : (ry + 1) * h // g, rx * w // g : (rx + 1) * w // g
            ]
            if block.size:
                regions.append((float(block.mean() * 100.0), ry, rx))
    regions.sort(reverse=True)
    print("worst regions (of a %dx%d grid):" % (g, g))
    for share, ry, rx in regions[:5]:
        if share > 0:
            print(f"  row {ry} col {rx}: {share:.1f}%")

    ok = pct <= args.max_pct
    print(f"result    : {'PASS' if ok else 'FAIL'} ({pct:.2f}% vs max {args.max_pct}%)")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
