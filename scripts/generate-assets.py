#!/usr/bin/env python3
"""Generuje kompletní sadu vizuálních assetů CibulkaOS („Archiv StB × siderické kyvadlo“ + razítko C//OS)."""
import math
import os
import subprocess
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PORTRAIT = os.path.join(ROOT, "Petr_Cibulka.jpg")

FONT_MONO_BLACK = "/usr/share/fonts/noto/NotoSansMono-Black.ttf"
FONT_MONO_BOLD = "/usr/share/fonts/noto/NotoSansMono-Bold.ttf"
FONT_MONO_REG = "/usr/share/fonts/noto/NotoSansMono-Regular.ttf"
FONT_SANS_BOLD = "/usr/share/fonts/noto/NotoSans-Bold.ttf"

# Palette
CHARCOAL = (11, 10, 12)
PANEL = (22, 19, 26)
LINE = (44, 37, 49)
PARCHMENT = (236, 230, 214)
MUTED = (166, 158, 142)
GOLD = (255, 215, 0)
GOLD_DIM = (184, 148, 0)
CRIMSON = (179, 18, 46)
CRIMSON_HI = (224, 56, 79)

def load_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        return ImageFont.load_default()

STAMP_SVG = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">
  <g transform="rotate(-7 128 128)">
    <rect x="20" y="54" width="216" height="148" rx="14" fill="#0b0a0c" stroke="#e0384f" stroke-width="9"/>
    <rect x="33" y="67" width="190" height="122" rx="7" fill="none" stroke="#ffd700" stroke-width="3.5"/>
    <line x1="48" y1="145" x2="208" y2="145" stroke="#b3122e" stroke-width="2.2" opacity="0.85"/>
    <text x="128" y="130" text-anchor="middle" fill="#ffd700"
          font-family="Noto Sans Mono, DejaVu Sans Mono, monospace"
          font-size="52" font-weight="900" letter-spacing="2">C//OS</text>
    <text x="128" y="174" text-anchor="middle" fill="#e0384f"
          font-family="Noto Sans Mono, DejaVu Sans Mono, monospace"
          font-size="22" font-weight="800" letter-spacing="4.5">ANTI-GRU</text>
  </g>
</svg>
"""

def draw_stamp_overlay(base_img, cx, cy, scale=1.0, angle=-7, text1="ANTI-GRUB", text2="PROVĚŘENO"):
    """Vykreslí ostré razítko na libovolný RGBA obrázek."""
    w, h = int(340 * scale), int(124 * scale)
    stamp = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(stamp)
    pad = int(8 * scale)
    d.rounded_rectangle([pad, pad, w - pad, h - pad], radius=int(10 * scale),
                        fill=(11, 10, 12, 205), outline=CRIMSON_HI + (245,), width=max(2, int(4 * scale)))
    pad2 = int(17 * scale)
    d.rounded_rectangle([pad2, pad2, w - pad2, h - pad2], radius=int(5 * scale),
                        outline=GOLD + (210,), width=max(1, int(2 * scale)))
    f1 = load_font(FONT_MONO_BLACK, max(12, int(34 * scale)))
    f2 = load_font(FONT_MONO_BOLD, max(10, int(19 * scale)))
    d.text((w // 2, int(h * 0.36)), text1, fill=GOLD + (255,), font=f1, anchor="mm")
    d.text((w // 2, int(h * 0.72)), text2, fill=CRIMSON_HI + (255,), font=f2, anchor="mm")
    rot = stamp.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
    base_img.alpha_composite(rot, (cx - rot.width // 2, cy - rot.height // 2))

def draw_foucault_rosette(draw, cx, cy, rx, ry, count=12, color=(255, 215, 0, 55), width=2):
    """Kreslí Foucaultovu rozetu kyvadla pomocí polygonů (plná alfa podpora)."""
    steps = 120
    for k in range(count):
        ang = math.pi * k / count
        ca, sa = math.cos(ang), math.sin(ang)
        pts = []
        for i in range(steps + 1):
            t = 2 * math.pi * i / steps
            x = rx * math.cos(t)
            y = ry * math.sin(t)
            px = cx + x * ca - y * sa
            py = cy + x * sa + y * ca
            pts.append((px, py))
        draw.line(pts, fill=color, width=width)

def build_logo():
    svg_paths = [
        os.path.join(ROOT, "archlive/airootfs/usr/share/icons/hicolor/scalable/apps/cibulkaos-logo.svg"),
        os.path.join(ROOT, "web/assets/cibulkaos-stamp.svg"),
    ]
    for p in svg_paths:
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, "w", encoding="utf-8") as f:
            f.write(STAMP_SVG)

    src_svg = svg_paths[0]
    png_targets = [
        (256, os.path.join(ROOT, "archlive/airootfs/etc/calamares/branding/cibulkaos/cibulkaos-stamp.png")),
        (128, os.path.join(ROOT, "archlive/airootfs/usr/share/icons/hicolor/128x128/apps/cibulkaos-logo.png")),
        (64, os.path.join(ROOT, "archlive/airootfs/usr/share/icons/hicolor/64x64/apps/cibulkaos-logo.png")),
        (48, os.path.join(ROOT, "archlive/grub/themes/cibulkaos/icons/cibulkaos.png")),
        (48, os.path.join(ROOT, "archlive/airootfs/usr/share/grub/themes/cibulkaos/icons/cibulkaos.png")),
    ]
    for size, out in png_targets:
        os.makedirs(os.path.dirname(out), exist_ok=True)
        subprocess.check_call(["rsvg-convert", "-w", str(size), "-h", str(size), src_svg, "-o", out])
    print("OK: logo SVG + PNGs")

def build_grub_background():
    W, H = 1920, 1080
    img = Image.new("RGBA", (W, H), CHARCOAL + (255,))
    draw = ImageDraw.Draw(img)

    # Jemná archivní mřížka vlevo (na vlastní alfa vrstvě, aby nebyla křiklavá)
    grid = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(grid)
    for x in range(0, W, 64):
        gd.line([(x, 0), (x, H)], fill=(255, 215, 0, 18), width=1)
    for y in range(0, H, 64):
        gd.line([(0, y), (W, y)], fill=(255, 215, 0, 18), width=1)
    img.alpha_composite(grid)

    # Jemná Foucaultova rozeta za pravou částí
    rosette = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    rd = ImageDraw.Draw(rosette)
    draw_foucault_rosette(rd, int(W * 0.72), int(H * 0.48), 420, 155, count=9, color=(255, 215, 0, 28), width=2)
    img.alpha_composite(rosette)

    # Pravá 46 % plocha: portrét Petra Cibulky ve zlatém halftone/duotonu
    pw = int(W * 0.48)
    por = Image.open(PORTRAIT).convert("RGB")
    por = ImageOps.fit(por, (pw, H), method=Image.Resampling.LANCZOS, centering=(0.55, 0.22))
    gray = ImageOps.grayscale(por)
    gray = ImageEnhance.Contrast(gray).enhance(1.55)
    # Duotone: charcoal -> gold
    duotone = ImageOps.colorize(gray, black="#0b0a0c", mid="#9e7608", white="#ffe04d").convert("RGBA")

    # Halftone dot mask pro grafický rastr
    dots = Image.new("L", (pw, H), 235)
    dd = ImageDraw.Draw(dots)
    step = 6
    for y in range(0, H, step):
        for x in range(0, pw, step):
            dd.point((x, y), fill=95)
            if x + 1 < pw and y + 1 < H:
                dd.point((x + 1, y + 1), fill=130)

    # Plynulý gradient fade zleva + shora/zdola
    alpha = Image.new("L", (pw, H), 255)
    ad = ImageDraw.Draw(alpha)
    fade_w = int(pw * 0.42)
    for x in range(pw):
        if x < fade_w:
            t = x / fade_w
            a = int(205 * (t * t))
        else:
            a = 205
        ad.line([(x, 0), (x, H)], fill=a)
    # Kombinace alfy a halftone
    combined_a = Image.composite(alpha, Image.new("L", (pw, H), 60), dots)
    duotone.putalpha(combined_a)
    img.alpha_composite(duotone, (W - pw, 0))

    # Horní a spodní zlatá linka
    draw.rectangle([0, 0, W, 4], fill=GOLD + (230,))
    draw.rectangle([0, H - 4, W, H], fill=CRIMSON + (220,))

    # Karmínové razítko ANTI-GRUB · PROVĚŘENO vpravo dole
    draw_stamp_overlay(img, int(W * 0.84), int(H * 0.84), scale=1.15, angle=-8,
                       text1="ANTI-GRUB", text2="PROVĚŘENO")

    out_rgb = img.convert("RGB")
    targets = [
        os.path.join(ROOT, "archlive/grub/themes/cibulkaos/background.png"),
        os.path.join(ROOT, "archlive/airootfs/usr/share/grub/themes/cibulkaos/background.png"),
    ]
    for t in targets:
        os.makedirs(os.path.dirname(t), exist_ok=True)
        out_rgb.save(t, "PNG", optimize=True)

    # Syslinux BIOS splash (640x480)
    splash = out_rgb.resize((640, 480), Image.Resampling.LANCZOS)
    splash.save(os.path.join(ROOT, "archlive/syslinux/splash.png"), "PNG", optimize=True)

    # Zlatý 9-slice výběrový pruh pro Anti-GRUB menu (select_w / select_c / select_e)
    bar_h = 44
    for theme_dir in [
        os.path.join(ROOT, "archlive/grub/themes/cibulkaos"),
        os.path.join(ROOT, "archlive/airootfs/usr/share/grub/themes/cibulkaos"),
    ]:
        # select_w: 12x44 s ostrým zlatým okrajem a karmínovým proužkem vlevo
        sw = Image.new("RGBA", (12, bar_h), (0, 0, 0, 0))
        sd = ImageDraw.Draw(sw)
        sd.rectangle([0, 2, 4, bar_h - 3], fill=CRIMSON_HI + (255,))
        sd.rectangle([4, 2, 11, bar_h - 3], fill=GOLD + (245,))
        sw.save(os.path.join(theme_dir, "select_w.png"))

        sc = Image.new("RGBA", (16, bar_h), (0, 0, 0, 0))
        sd = ImageDraw.Draw(sc)
        sd.rectangle([0, 2, 15, bar_h - 3], fill=GOLD + (245,))
        sc.save(os.path.join(theme_dir, "select_c.png"))

        se = Image.new("RGBA", (16, bar_h), (0, 0, 0, 0))
        sd = ImageDraw.Draw(se)
        sd.polygon([(0, 2), (15, 2), (8, bar_h - 3), (0, bar_h - 3)], fill=GOLD + (245,))
        se.save(os.path.join(theme_dir, "select_e.png"))

    print("OK: Anti-GRUB background + select_*.png + syslinux splash")

def build_calamares_welcome():
    W, H = 640, 320
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))

    # Karta zažloutlého spisu s jemným stínem
    card = Image.new("RGBA", (W - 36, H - 36), (0, 0, 0, 0))
    cd = ImageDraw.Draw(card)
    cw, ch = card.size
    cd.rounded_rectangle([0, 0, cw - 1, ch - 1], radius=8, fill=(235, 227, 206, 255),
                         outline=(168, 154, 124, 255), width=2)
    # Linky formuláře – pevná rozteč, text se na ně usazuje účařím (anchor "ls")
    RULE_TOP, RULE_PITCH = 50, 30
    rules = list(range(RULE_TOP, ch - 20, RULE_PITCH))
    for y in rules:
        cd.line([(230, y), (cw - 24, y)], fill=(195, 184, 158, 160), width=1)
    # Horní červeno-černý pruh spisu
    cd.rectangle([18, 18, cw - 18, 22], fill=CRIMSON + (230,))

    # Sépiový portrét v rámečku vlevo
    por = Image.open(PORTRAIT).convert("RGB")
    por = ImageOps.fit(por, (176, 206), method=Image.Resampling.LANCZOS, centering=(0.55, 0.22))
    gray = ImageOps.grayscale(por)
    gray = ImageEnhance.Contrast(gray).enhance(1.22)
    sepia = ImageOps.colorize(gray, black="#241c14", mid="#8c7557", white="#efe6d1").convert("RGBA")

    photo_frame = Image.new("RGBA", (190, 220), (250, 247, 239, 255))
    photo_frame.alpha_composite(sepia, (7, 7))
    pfd = ImageDraw.Draw(photo_frame)
    pfd.rectangle([0, 0, 189, 219], outline=(150, 138, 114, 255), width=2)
    photo_rot = photo_frame.rotate(2.2, resample=Image.Resampling.BICUBIC, expand=True)
    card.alpha_composite(photo_rot, (22, 34))

    # Kancelářská sponka nahoře na fotce
    cd.rounded_rectangle([72, 16, 94, 56], radius=10, outline=(95, 98, 108, 255), width=4)
    cd.rounded_rectangle([78, 22, 88, 50], radius=5, outline=(165, 168, 178, 255), width=2)

    # Texty spisu vpravo
    f_tag = load_font(FONT_MONO_BOLD, 16)
    f_big = load_font(FONT_MONO_BLACK, 30)
    f_sub = load_font(FONT_MONO_BOLD, 15)
    f_body = load_font(FONT_MONO_REG, 13)
    on_rule = lambda i: rules[i] - 4  # účaří 4 px nad linkou
    cd.text((234, on_rule(0)), "SPIS č. 100 666 · ARCHIV StB", fill=CRIMSON + (255,), font=f_tag, anchor="ls")
    cd.text((234, on_rule(1)), "CIBULKAOS", fill=(24, 21, 28, 255), font=f_big, anchor="ls")
    cd.text((234, on_rule(2)), "ANTI-GRU · ARCH LINUX", fill=(90, 74, 42, 255), font=f_sub, anchor="ls")
    cd.text((234, on_rule(3)), "• KDE Plasma 6 (Wayland) + Btrfs", fill=(55, 49, 41, 255), font=f_body, anchor="ls")
    cd.text((234, on_rule(4)), "• Root účet: cibulka | sudo → kyvadlo", fill=(55, 49, 41, 255), font=f_body, anchor="ls")
    cd.text((234, on_rule(5)), "• Lustrace: 100 666 reálných záznamů", fill=(55, 49, 41, 255), font=f_body, anchor="ls")

    # Razítko v pravém dolním rohu spisu (bez překryvu s textem)
    draw_stamp_overlay(card, cw - 115, ch - 38, scale=0.56, angle=-6,
                       text1="ODTAJNĚNO", text2="C//OS 2026")

    # Jemný stín + mírné natočení celého spisu
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    shd = ImageDraw.Draw(shadow)
    shd.rounded_rectangle([22, 24, W - 14, H - 12], radius=8, fill=(0, 0, 0, 85))
    shadow = shadow.filter(ImageFilter.GaussianBlur(7))
    img.alpha_composite(shadow)
    rot_card = card.rotate(-1.2, resample=Image.Resampling.BICUBIC, expand=False)
    img.alpha_composite(rot_card, (18, 16))

    out = os.path.join(ROOT, "archlive/airootfs/etc/calamares/branding/cibulkaos/calamares-welcome.png")
    img.save(out, "PNG", optimize=True)
    print("OK: calamares-welcome.png")

def build_wallpaper():
    W, H = 2560, 1440
    img = Image.new("RGBA", (W, H), CHARCOAL + (255,))
    draw = ImageDraw.Draw(img)

    # Radiální hloubka obsidiánu
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    cx, cy = W // 2, int(H * 0.47)
    for r in range(950, 40, -25):
        t = 1 - (r / 950)
        col = (int(28 * t + 11), int(22 * t + 10), int(40 * t + 12), int(120 * t))
        gd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col)
    img.alpha_composite(glow)

    # Hvězdné body (deterministické)
    star_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(star_layer)
    seed = 19891117
    for _ in range(220):
        seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
        sx = seed % W
        seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
        sy = seed % H
        seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
        sr = 1 + (seed % 3)
        col = GOLD + (110,) if (seed % 4 == 0) else PARCHMENT + (80,)
        sd.ellipse([sx - sr, sy - sr, sx + sr, sy + sr], fill=col)
    img.alpha_composite(star_layer)

    # Siderické kruhy + stupnice
    ring_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring_layer)
    for r, a in [(540, 40), (410, 28), (270, 32)]:
        rd.ellipse([cx - r, cy - r, cx + r, cy + r], outline=GOLD + (a,), width=2)
    for deg in range(0, 360, 15):
        rad = math.radians(deg)
        r1 = 528 if deg % 45 == 0 else 535
        r2 = 552 if deg % 45 == 0 else 545
        rd.line([(cx + r1 * math.cos(rad), cy + r1 * math.sin(rad)),
                 (cx + r2 * math.cos(rad), cy + r2 * math.sin(rad))],
                fill=GOLD + (95 if deg % 45 == 0 else 45,), width=2)
    # Foucaultova rozeta kyvadla (12 elips)
    draw_foucault_rosette(rd, cx, cy, 480, 150, count=12, color=(255, 215, 0, 68), width=2)
    draw_foucault_rosette(rd, cx, cy, 310, 96, count=6, color=(224, 56, 79, 55), width=2)
    # Zlatý středový bod kyvadla
    rd.ellipse([cx - 18, cy - 18, cx + 18, cy + 18], fill=CHARCOAL + (255,), outline=GOLD + (240,), width=3)
    rd.ellipse([cx - 7, cy - 7, cx + 7, cy + 7], fill=GOLD + (255,))
    img.alpha_composite(ring_layer)

    # Malé decentní razítko C//OS v pravém dolním rohu (s rezervou pro 16:10 i spodní panel)
    draw_stamp_overlay(img, W - 250, H - 220, scale=0.66, angle=-6, text1="C//OS", text2="ANTI-GRU")

    out = os.path.join(ROOT, "archlive/airootfs/usr/share/wallpapers/CibulkaOS/wallpaper-kyvadlo.png")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.convert("RGB").save(out, "PNG", optimize=True)
    print("OK: wallpaper-kyvadlo.png")

def build_sddm_background():
    W, H = 1920, 1080
    img = Image.new("RGBA", (W, H), CHARCOAL + (255,))

    # Rozmazaná textura kartotéky (řádky archivních svazků)
    text_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    td = ImageDraw.Draw(text_layer)
    f = load_font(FONT_MONO_REG, 22)
    lines = [
        "05449  REGISTRAČNÍ PROTOKOL  |  SVAZEK: TS   |  KRYCÍ: KYVADLO    |  II. SPRÁVA FMV",
        "25875  ARCHIVNÍ PROTOKOL     |  SVAZEK: KTS  |  KRYCÍ: PERISKOP   |  S StB OSTRAVA",
        "19882  PROVEŘENÝ ZÁZNAM      |  SVAZEK: A    |  KRYCÍ: REDAKTOR   |  KS-SNB PRAHA",
        "43219  I. SPRÁVA SNB         |  SVAZEK: D    |  KRYCÍ: ARCHIVÁŘ   |  ODBOR 4 · SPIS",
        "100666 CIBULKAOS ANTI-GRU    |  STATUS: OK   |  RNG: /dev/kyvadlo |  NFTABLES ACTIVE",
    ]
    for idx, y in enumerate(range(30, H, 42)):
        txt = lines[idx % len(lines)] + "    ·    " + lines[(idx + 2) % len(lines)]
        td.text((40 - (idx % 3) * 35, y), txt, fill=PARCHMENT + (76,), font=f)
    text_layer = text_layer.filter(ImageFilter.GaussianBlur(2.6))
    img.alpha_composite(text_layer)

    # Středová viněta + jemná zlatá rozeta pro skvělou čitelnost SDDM Breeze formuláře
    vig = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vig)
    cx, cy = W // 2, H // 2
    draw_foucault_rosette(vd, cx, cy, 480, 155, count=10, color=(255, 215, 0, 62), width=2)
    vd.ellipse([cx - 340, cy - 260, cx + 340, cy + 260], fill=(11, 10, 12, 165))
    vig = vig.filter(ImageFilter.GaussianBlur(18))
    img.alpha_composite(vig)

    # Horní zlatá linka a razítko v rohu
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, W, 3], fill=GOLD + (200,))
    draw_stamp_overlay(img, W - 160, H - 90, scale=0.65, angle=-7, text1="C//OS", text2="LUSTRACE")

    out = os.path.join(ROOT, "archlive/airootfs/usr/share/wallpapers/CibulkaOS/sddm-background.png")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.convert("RGB").save(out, "PNG", optimize=True)
    print("OK: sddm-background.png")

if __name__ == "__main__":
    build_logo()
    build_grub_background()
    build_calamares_welcome()
    build_wallpaper()
    build_sddm_background()
    print("ALL CIBULKAOS VISUAL ASSETS GENERATED SUCCESSFULLY!")
