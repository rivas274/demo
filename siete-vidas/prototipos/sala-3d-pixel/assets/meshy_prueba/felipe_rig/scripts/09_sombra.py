# Sombra de la pata trasera, antes y después de arreglar los pesos (muslo y brazo que se
# llevaban la grupa y el flanco). Renderiza de cerca la pata trasera en la caminata, con luz
# y con las normales a color, desde un .blend de animación.
# Uso: python3 09_sombra.py <anim.blend> <prefijo de salida> [cuadros=6,9]
import sys, os, bpy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_render as R

blend, pref = sys.argv[1], sys.argv[2]
cuadros = [int(c) for c in (sys.argv[3] if len(sys.argv) > 3 else "6,9").split(",")]
bpy.ops.wm.open_mainfile(filepath=blend)
arm = bpy.data.objects["FelipeRig"]
m = bpy.data.objects["Felipe"]
acc = bpy.data.actions["caminar"]
arm.animation_data.action = acc
try:
    if acc.slots:
        arm.animation_data.action_slot = acc.slots[0]
except AttributeError:
    pass
for t in arm.animation_data.nla_tracks:
    t.mute = True
R.escena(320, 16)
R.luz()
nt = m.data.materials[0].node_tree
bs = nt.nodes.get("Principled BSDF")
out = nt.nodes.get("Material Output")
em = nt.nodes.new("ShaderNodeEmission")
geo = nt.nodes.new("ShaderNodeNewGeometry")
vm = nt.nodes.new("ShaderNodeVectorMath"); vm.operation = "MULTIPLY_ADD"
vm.inputs[1].default_value = (0.5, 0.5, 0.5); vm.inputs[2].default_value = (0.5, 0.5, 0.5)
nt.links.new(geo.outputs["Normal"], vm.inputs[0])
nt.links.new(vm.outputs[0], em.inputs[0])
for f in cuadros:
    bpy.context.scene.frame_set(f)
    for modo in ("luz", "normales"):
        for l in list(out.inputs[0].links):
            nt.links.remove(l)
        nt.links.new((bs if modo == "luz" else em).outputs[0], out.inputs[0])
        R.camara((-1, 0.15, 0.25), centro=(0, 0.06, 0.1), tam=0.26)
        R.mostrar_solo([m])
        R.render("%s_%d_%s.png" % (pref, f, modo))
