# Rutas y mapeo compartidos por los pasos del rig de Felipe (Blender 5.2, bpy como módulo).
# Coordenadas de Blender: Z arriba, Felipe mira hacia -Y, su lado izquierdo (.L) es +X.
import os

AQUI = os.path.dirname(os.path.abspath(__file__))
RIG = os.path.dirname(AQUI)                      # assets/meshy_prueba/felipe_rig
MESHY = os.path.dirname(RIG)                     # assets/meshy_prueba
GLB_ORIGINAL = os.path.join(MESHY, "felipe_meshy.glb")
PLANTILLA = os.path.join(MESHY, "plantilla_esqueleto")
GLB_SALIDA = os.path.join(RIG, "felipe_rig.glb")
# Archivos de trabajo (grandes, no se suben): carpeta temporal o la que diga FELIPE_TRABAJO.
TRABAJO = os.environ.get("FELIPE_TRABAJO", "/tmp/felipe_rig_trabajo")
os.makedirs(TRABAJO, exist_ok=True)
BLEND_RETOPO = os.path.join(TRABAJO, "01_retopo.blend")
BLEND_TEXTURA = os.path.join(TRABAJO, "02_textura.blend")
BLEND_RIG = os.path.join(TRABAJO, "03_rig.blend")
BLEND_ANIM = os.path.join(TRABAJO, "05_anim.blend")

# Alto final de Felipe en metros (AABB entero, con la cola): 67 px del juego a 121 px/m.
ALTO_M = 67.0 / 121.0

# Mapeo de las plantillas del creador (vistas.gd en Godot): modelo centrado en su AABB,
# cámara ortográfica de 2,184 unidades para 1024 px. Perfil: girado 90° en Y (mira a la
# derecha, x de pantalla = -Y de Blender); frente: x de pantalla = +X de Blender.
PX = 2.184 / 1024.0
# Centro del AABB del GLB original en Blender (se mide en 01_retopo y se guarda aquí).
CENTRO_ORIGINAL = (-0.0019, 0.0018, -0.0008)
# Después de centrar: X e Y al centro del AABB y el piso (z mínimo) en 0.
Z_PISO_ORIGINAL = -0.808374


def perfil(px, py, x=0.0):
    """Punto de la vista de perfil (px, py) a coordenadas del modelo centrado (piso en z=0)."""
    y = -(px - 512) * PX
    z = -(py - 512) * PX + CENTRO_ORIGINAL[2] - Z_PISO_ORIGINAL
    return (x, y, z)


def frente_x(px):
    return (px - 512) * PX


def frente_z(py):
    return -(py - 512) * PX + CENTRO_ORIGINAL[2] - Z_PISO_ORIGINAL
