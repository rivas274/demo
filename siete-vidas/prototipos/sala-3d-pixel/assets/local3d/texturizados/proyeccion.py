"""Proyección de la imagen de entrada (de la que salió la forma) sobre la malla.

Cámara ortográfica: el modelo se gira `yaw` grados en Y (como el pivote en Godot)
y luego `pitch` grados en X (cámara mirando desde arriba si pitch > 0).
Pixel = (cx + s*u, cy - s*v) con (u, v) = (x, y) de la vista.
"""
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage, optimize


def rot(yaw, pitch):
    a, b = np.radians(yaw), np.radians(pitch)
    ry = np.array([[np.cos(a), 0, np.sin(a)], [0, 1, 0], [-np.sin(a), 0, np.cos(a)]])
    rx = np.array([[1, 0, 0], [0, np.cos(b), -np.sin(b)], [0, np.sin(b), np.cos(b)]])
    return rx @ ry


def vista(V, yaw, pitch):
    return V @ rot(yaw, pitch).T  # z de la vista: hacia la cámara


def a_pixel(P, s, cx, cy):
    return np.c_[cx + s * P[:, 0], cy - s * P[:, 1]]


def mascara_imagen(rgb, tol=10):
    """Fondo = lo parecido al color de las esquinas, conectado al borde."""
    img = ndimage.uniform_filter(rgb.astype(float), size=(3, 3, 1))
    fondo_col = np.median(np.r_[img[:4].reshape(-1, 3), img[-4:].reshape(-1, 3)], axis=0)
    parecido = np.abs(img - fondo_col).max(axis=2) < tol
    lab, _ = ndimage.label(parecido)
    borde = np.unique(np.r_[lab[0], lab[-1], lab[:, 0], lab[:, -1]])
    fondo = np.isin(lab, borde[borde > 0])
    obj = ~fondo
    obj = ndimage.binary_opening(obj, iterations=2)
    obj = ndimage.binary_fill_holes(obj)
    lab, n = ndimage.label(obj)
    if n > 1:
        tam = ndimage.sum(obj, lab, range(1, n + 1))
        obj = lab == (np.argmax(tam) + 1)
    return obj


def silueta(V, F, yaw, pitch, s, cx, cy, W, H, escala=1.0):
    P = vista(V, yaw, pitch)
    q = a_pixel(P, s * escala, cx * escala, cy * escala)
    im = Image.new("L", (int(W * escala), int(H * escala)), 0)
    d = ImageDraw.Draw(im)
    for t in q[F]:
        d.polygon([tuple(p) for p in t], fill=255)
    return np.array(im) > 0


def iou(a, b):
    return (a & b).sum() / max((a | b).sum(), 1)


def ajustar(V, F, obj, yaws, pitches, escala=0.25, recorte=None):
    """Busca yaw/pitch/escala/desplazamiento que igualan la silueta de la imagen."""
    H, W = obj.shape
    ys, xs = np.where(obj)
    small = np.array(Image.fromarray(obj.astype(np.uint8) * 255).resize((int(W * escala), int(H * escala)))) > 127
    mejor = None
    for yaw in yaws:
        for pitch in pitches:
            P = vista(V, yaw, pitch)
            s = (ys.max() - ys.min()) / (P[:, 1].max() - P[:, 1].min())
            cx = (xs.max() + xs.min()) / 2 - s * (P[:, 0].max() + P[:, 0].min()) / 2
            cy = (ys.max() + ys.min()) / 2 + s * (P[:, 1].max() + P[:, 1].min()) / 2
            v = iou(silueta(V, F, yaw, pitch, s, cx, cy, W, H, escala), small)
            if mejor is None or v > mejor[0]:
                mejor = (v, yaw, pitch, s, cx, cy)
    v0, yaw, pitch, s, cx, cy = mejor

    rc = (slice(None), slice(None)) if recorte is None else tuple(slice(int(a * escala), int(b * escala)) for a, b in recorte)

    def costo(p):
        return -iou(silueta(V, F, p[0], p[1], p[2], p[3], p[4], W, H, escala)[rc], small[rc])

    x0 = np.array([yaw, pitch, s, cx, cy])
    simplex = [x0] + [x0 + d for d in np.diag([3.0, 3.0, 0.03 * s, 4.0, 4.0])]
    r = optimize.minimize(costo, x0, method="Nelder-Mead",
                          options={"xatol": 0.05, "fatol": 1e-4, "maxiter": 400,
                                   "initial_simplex": np.array(simplex)})
    p = r.x
    full = iou(silueta(V, F, *p, W, H, 1.0), obj)
    return dict(yaw=p[0], pitch=p[1], s=p[2], cx=p[3], cy=p[4], iou=full, iou_inicial=v0)


def visibles(V, F, N, prm, W, H, umbral_normal=0.4, tolerancia=0.02):
    """Vértices que la cámara de la imagen ve (prueba de profundidad + normal)."""
    P = vista(V, prm["yaw"], prm["pitch"])
    Nv = vista(N, prm["yaw"], prm["pitch"])
    q = a_pixel(P, prm["s"], prm["cx"], prm["cy"])
    # z-buffer por pintor: id del triángulo más cercano en cada pixel
    zt = P[F, 2].mean(axis=1)
    orden = np.argsort(zt)
    im = Image.new("I", (W, H), -1)
    d = ImageDraw.Draw(im)
    for i in orden:
        d.polygon([tuple(p) for p in q[F[i]]], fill=int(i))
    ids = np.array(im)
    xi = np.clip(np.round(q[:, 0]).astype(int), 0, W - 1)
    yi = np.clip(np.round(q[:, 1]).astype(int), 0, H - 1)
    tri = ids[yi, xi]
    zfront = np.where(tri >= 0, P[F[np.maximum(tri, 0)], 2].max(axis=1), -9)
    vis = (P[:, 2] >= zfront - tolerancia) & (Nv[:, 2] > umbral_normal)
    return vis, q


def muestrear(img, q):
    """Bilineal; img HxWxC float."""
    H, W = img.shape[:2]
    x = np.clip(q[:, 0], 0, W - 1.001)
    y = np.clip(q[:, 1], 0, H - 1.001)
    x0, y0 = np.floor(x).astype(int), np.floor(y).astype(int)
    fx, fy = (x - x0)[:, None], (y - y0)[:, None]
    if img.ndim == 2:
        img = img[..., None]
    a = img[y0, x0] * (1 - fx) + img[y0, x0 + 1] * fx
    b = img[y0 + 1, x0] * (1 - fx) + img[y0 + 1, x0 + 1] * fx
    return a * (1 - fy) + b * fy


def superponer(img_rgb, obj, prm, V, F, path, alpha=0.5):
    """Imagen de control: silueta del modelo (contorno rojo) sobre la imagen."""
    H, W = obj.shape
    sil = silueta(V, F, prm["yaw"], prm["pitch"], prm["s"], prm["cx"], prm["cy"], W, H)
    borde = sil ^ ndimage.binary_erosion(sil, iterations=2)
    borde_img = obj ^ ndimage.binary_erosion(obj, iterations=2)
    out = img_rgb.copy()
    out[borde_img] = [0, 120, 255]
    out[borde] = [255, 0, 0]
    Image.fromarray(out).save(path)
