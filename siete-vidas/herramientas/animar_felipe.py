"""Genera animaciones de Felipe por código a partir de un solo sprite (opción gratis).

Separa el sprite en capas (cola, cuerpo, cuatro patas) y las mueve pixel por pixel,
sin rotaciones ni suavizado, para que el resultado siga siendo pixel art.

Uso: python3 animar_felipe.py <sprite_base.png> <carpeta_salida>
"""
import math
import sys
from pathlib import Path

from PIL import Image

PAD = 6
# Zonas medidas sobre felipe-A-base.png (86x94).
TAIL_MAX_X, TAIL_MAX_Y = 32, 44
LEGS_TOP = 86
LEGS = [(21, 34), (35, 45), (46, 58), (59, 72)]  # trasera lejana, trasera, delantera lejana, delantera


def split_layers(sprite):
    w, h = sprite.size
    tail = Image.new("RGBA", (w, h))
    body = Image.new("RGBA", (w, h))
    legs = [Image.new("RGBA", (w, h)) for _ in LEGS]
    src = sprite.load()
    for y in range(h):
        for x in range(w):
            p = src[x, y]
            if p[3] == 0:
                continue
            if x <= TAIL_MAX_X and y < TAIL_MAX_Y:
                tail.putpixel((x, y), p)
            elif y >= LEGS_TOP and any(a <= x <= b for a, b in LEGS):
                i = next(i for i, (a, b) in enumerate(LEGS) if a <= x <= b)
                legs[i].putpixel((x, y), p)
            else:
                body.putpixel((x, y), p)
    return tail, body, legs


def sway(tail, amount):
    """Inclina la cola desplazando cada fila; la base queda fija."""
    w, h = tail.size
    out = Image.new("RGBA", (w, h))
    src = tail.load()
    for y in range(h):
        k = ((TAIL_MAX_Y - y) / TAIL_MAX_Y) ** 1.5 if y < TAIL_MAX_Y else 0
        dx = round(amount * k)
        for x in range(w):
            if src[x, y][3]:
                nx = x + dx
                if 0 <= nx < w:
                    out.putpixel((nx, y), src[x, y])
    return out


def frame(tail, body, legs, tail_amount, body_dy, leg_offsets):
    w, h = body.size
    canvas = Image.new("RGBA", (w + PAD * 2, h + PAD * 2))
    for leg, (dx, dy) in zip(legs, leg_offsets):
        canvas.alpha_composite(leg, (PAD + dx, PAD + dy))
    canvas.alpha_composite(sway(tail, tail_amount), (PAD, PAD + body_dy))
    canvas.alpha_composite(body, (PAD, PAD + body_dy))
    return canvas


def walk(tail, body, legs, n=8):
    frames = []
    for i in range(n):
        t = i / n * 2 * math.pi
        lift_a = max(0, math.sin(t))   # patas 0 y 2 (diagonal)
        lift_b = max(0, -math.sin(t))  # patas 1 y 3
        step = math.cos(t)
        offs = []
        for j in range(4):
            lift = lift_a if j in (0, 2) else lift_b
            sign = 1 if j in (0, 2) else -1
            offs.append((round(sign * step * 1.5), -round(lift * 2)))
        body_dy = -1 if abs(math.sin(t)) > 0.7 else 0
        frames.append(frame(tail, body, legs, round(math.sin(t) * 3), body_dy, offs))
    return frames


def idle(tail, body, legs, n=8):
    frames = []
    for i in range(n):
        t = i / n * 2 * math.pi
        frames.append(frame(tail, body, legs, round(math.sin(t) * 3), 0 if i < n // 2 else -1, [(0, 0)] * 4))
    return frames


def save(frames, out, name, fps=10):
    w, h = frames[0].size
    sheet = Image.new("RGBA", (w * len(frames), h))
    for i, f in enumerate(frames):
        sheet.alpha_composite(f, (i * w, 0))
    sheet.save(out / f"{name}-sheet.png")
    bg = (236, 231, 224, 255)
    preview = []
    for f in frames:
        b = Image.new("RGBA", f.size, bg)
        b.alpha_composite(f)
        preview.append(b.resize((w * 4, h * 4), Image.NEAREST).convert("P", palette=Image.ADAPTIVE))
    preview[0].save(out / f"{name}-preview.gif", save_all=True, append_images=preview[1:],
                    duration=int(1000 / fps), loop=0, disposal=2)


def main():
    sprite = Image.open(sys.argv[1]).convert("RGBA")
    out = Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    tail, body, legs = split_layers(sprite)
    save(walk(tail, body, legs), out, "felipe-caminar-codigo")
    save(idle(tail, body, legs), out, "felipe-quieto-codigo", fps=6)


if __name__ == "__main__":
    main()
