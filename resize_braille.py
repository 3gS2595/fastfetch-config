#!/usr/bin/env python3
"""Resize braille ASCII art by decoding it to a 1-bit bitmap (each cell is a
2x4 dot grid), scaling, and re-encoding to braille."""
import sys
from PIL import Image

# (dx, dy) -> braille dot bit
BITS = {(0,0):0x01,(0,1):0x02,(0,2):0x04,(0,3):0x40,
        (1,0):0x08,(1,1):0x10,(1,2):0x20,(1,3):0x80}

def decode(path):
    lines = [l.rstrip("\n") for l in open(path, encoding="utf-8")]
    Wc = max(len(l) for l in lines)
    Hc = len(lines)
    img = Image.new("L", (2*Wc, 4*Hc), 0)
    px = img.load()
    for r, line in enumerate(lines):
        for c, ch in enumerate(line):
            code = ord(ch) - 0x2800
            if code < 0 or code > 0xFF:
                continue
            for (dx,dy),bit in BITS.items():
                if code & bit:
                    px[c*2+dx, r*4+dy] = 255
    return img

def encode(img, thresh):
    W, H = img.size
    W2 = (W + 1)//2*2
    H4 = (H + 3)//4*4
    if (W2,H4) != (W,H):
        canvas = Image.new("L",(W2,H4),0); canvas.paste(img,(0,0)); img = canvas
    px = img.load()
    out = []
    for r in range(0, H4, 4):
        row = []
        for c in range(0, W2, 2):
            code = 0
            for (dx,dy),bit in BITS.items():
                if px[c+dx, r+dy] >= thresh:
                    code |= bit
            row.append(chr(0x2800 + code))
        out.append("".join(row).rstrip())   # trim trailing blank cells
    return "\n".join(out)

def main():
    src, rows, dst = sys.argv[1], int(sys.argv[2]), sys.argv[3]
    thresh = int(sys.argv[4]) if len(sys.argv) > 4 else 96
    img = decode(src)
    if rows > 0:
        W, H = img.size
        newH = rows*4
        newW = max(2, round(W * newH / H))
        img = img.resize((newW, newH), Image.BOX)
    art = encode(img, thresh)
    open(dst, "w", encoding="utf-8").write(art + "\n")
    w = max((len(l) for l in art.splitlines()), default=0)
    print(f"wrote {dst}: {len(art.splitlines())} rows x {w} cols")

if __name__ == "__main__":
    main()
