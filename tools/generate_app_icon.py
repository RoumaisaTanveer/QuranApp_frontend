"""Generate Quran Journal app icons matching splash screen branding."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
BG = (0x17, 0x17, 0x1E)
PURPLE = (0x6F, 0x54, 0xD8)
PURPLE_LIGHT = (0x92, 0x74, 0xE2)
PURPLE_DARK = (0x5B, 0x3C, 0xC4)
GOLD = (0xD4, 0xA8, 0x4B)
WHITE = (255, 255, 255)

OUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "icon"


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def lerp_color(
    c1: tuple[int, int, int], c2: tuple[int, int, int], t: float
) -> tuple[int, int, int]:
    return (lerp(c1[0], c2[0], t), lerp(c1[1], c2[1], t), lerp(c1[2], c2[2], t))


def radial_gradient_circle(
    size: int, cx: int, cy: int, r: int
) -> Image.Image:
    """Purple orb gradient aligned with splash screen (top-left light, bottom-right dark)."""
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    for y in range(cy - r - 2, cy + r + 3):
        for x in range(cx - r - 2, cx + r + 3):
            dx, dy = x - cx, y - cy
            dist_sq = dx * dx + dy * dy
            if dist_sq > r * r:
                continue
            dist = math.sqrt(dist_sq) / r
            # Diagonal gradient like splash LinearGradient topLeft -> bottomRight
            diag = ((dx / r) * -0.45 + (dy / r) * 0.55 + 1.0) / 2.0
            diag = max(0.0, min(1.0, diag))
            edge = dist**0.85
            t = diag * 0.72 + edge * 0.28
            color = lerp_color(PURPLE_LIGHT, PURPLE_DARK, t)
            # Soft inner highlight near top-left
            highlight = max(0.0, 1.0 - math.hypot(dx + r * 0.28, dy + r * 0.32) / (r * 0.95))
            if highlight > 0:
                color = lerp_color(color, (255, 255, 255), highlight * 0.14)
            layer.putpixel((x, y), color + (255,))
    return layer


def draw_outer_glow(base: Image.Image, cx: int, cy: int, r: int) -> Image.Image:
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    for i in range(100, 0, -1):
        alpha = int(22 * (i / 100) ** 2.2)
        radius = r + int(52 * (1 - i / 100))
        gdraw.ellipse(
            (cx - radius, cy - radius, cx + radius, cy + radius),
            fill=(PURPLE[0], PURPLE[1], PURPLE[2], alpha),
        )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=6))
    return Image.alpha_composite(base.convert("RGBA"), glow)


def draw_gold_ring(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int) -> None:
    ring_r = r + 6
    draw.ellipse(
        (cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r),
        outline=GOLD + (90,),
        width=3,
    )


def draw_book_shadow(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: float) -> None:
    sw = int(200 * scale)
    sh = int(28 * scale)
    draw.ellipse(
        (cx - sw // 2, cy + int(58 * scale), cx + sw // 2, cy + int(58 * scale) + sh),
        fill=(0, 0, 0, 55),
    )


def draw_menu_book(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: float) -> None:
    """Material-style open book (matches splash Icons.menu_book_rounded)."""
    w = int(248 * scale)
    h = int(188 * scale)
    spine_w = int(20 * scale)
    page_gap = int(10 * scale)
    left = cx - w // 2
    top = cy - h // 2 + int(6 * scale)
    radius = int(22 * scale)

    draw_book_shadow(draw, cx, cy, scale)

    page_fill = (0xFA, 0xFA, 0xFF)
    spine_fill = (0xE4, 0xE4, 0xF2)
    line_color = (0xB8, 0xB8, 0xD0)

    # Left page
    draw.rounded_rectangle(
        (left, top, left + w // 2 - page_gap // 2, top + h),
        radius=radius,
        fill=page_fill,
    )
    # Right page
    draw.rounded_rectangle(
        (left + w // 2 + page_gap // 2, top, left + w, top + h),
        radius=radius,
        fill=page_fill,
    )
    # Spine
    draw.rounded_rectangle(
        (
            cx - spine_w // 2,
            top + int(10 * scale),
            cx + spine_w // 2,
            top + h - int(10 * scale),
        ),
        radius=int(8 * scale),
        fill=spine_fill,
    )
    # Page lines
    for x0, x1 in (
        (left + int(28 * scale), left + w // 2 - page_gap // 2 - int(18 * scale)),
        (left + w // 2 + page_gap // 2 + int(18 * scale), left + w - int(28 * scale)),
    ):
        for i in range(5):
            y = top + int(38 * scale) + i * int(26 * scale)
            draw.line((x0, y, x1, y), fill=line_color, width=max(2, int(3 * scale)))


def render_icon(*, with_background: bool) -> Image.Image:
    cx, cy = SIZE // 2, SIZE // 2
    circle_r = int(SIZE * 0.36)

    if with_background:
        img = Image.new("RGBA", (SIZE, SIZE), BG + (255,))
    else:
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    orb = radial_gradient_circle(SIZE, cx, cy, circle_r)
    img = Image.alpha_composite(img, orb)
    img = draw_outer_glow(img, cx, cy, circle_r)

    draw = ImageDraw.Draw(img)
    draw_gold_ring(draw, cx, cy, circle_r)
    draw_menu_book(draw, cx, cy, scale=1.15)
    return img


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    full = render_icon(with_background=True)
    full.save(OUT_DIR / "app_icon.png", "PNG")

    foreground = render_icon(with_background=False)
    foreground.save(OUT_DIR / "app_icon_foreground.png", "PNG")

    print(f"Wrote {OUT_DIR / 'app_icon.png'}")
    print(f"Wrote {OUT_DIR / 'app_icon_foreground.png'}")


if __name__ == "__main__":
    main()