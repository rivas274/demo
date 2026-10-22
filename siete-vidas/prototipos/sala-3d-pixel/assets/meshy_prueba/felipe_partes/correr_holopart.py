"""HoloPart local (RTX 4060 de 8 GB): completa cada parte de una malla ya segmentada.

Uso: python correr_holopart.py <entrada_partes.glb> <salida.glb> [pasos=50] [semilla=42] [profundidad=9]

La entrada es una escena GLB con una malla por parte (segmentar_felipe.py la arma).
Diferencias con scripts/inference_holopart.py del repo:
- una parte a la vez y fp16; los latentes se guardan junto a la salida (<salida>_latentes/) y se reutilizan,
  así un fallo en la extracción no obliga a repetir la difusión (~50 s por parte);
- extracción jerárquica con marching cubes de scikit-image: el decodificador "flash" necesita diso, que en
  Windows no tiene binario (no hay nvcc). El run_holopart del repo además le pasa a
  hierarchical_extract_geometry un argumento que no existe (final_octree_depth), por eso el bucle va aquí.
"""
import os
import sys
import time

sys.path.insert(0, r"C:\IA3D\HoloPart")
sys.path.insert(0, r"C:\IA3D\HoloPart\scripts")

import numpy as np  # noqa: E402
import torch  # noqa: E402
import trimesh  # noqa: E402

from holopart.inference_utils import hierarchical_extract_geometry  # noqa: E402
from holopart.pipelines.pipeline_holopart import HoloPartPipeline  # noqa: E402
from inference_holopart import prepare_data, simplify_mesh  # noqa: E402

entrada, salida = sys.argv[1], sys.argv[2]
pasos = int(sys.argv[3]) if len(sys.argv) > 3 else 50
semilla = int(sys.argv[4]) if len(sys.argv) > 4 else 42
profundidad = int(sys.argv[5]) if len(sys.argv) > 5 else 9
dir_latentes = salida.rsplit(".", 1)[0] + "_latentes"
os.makedirs(dir_latentes, exist_ok=True)

t = time.time()
pipe = HoloPartPipeline.from_pretrained(r"C:\IA3D\HoloPart\pretrained_weights\HoloPart").to("cuda", torch.float16)
datos = prepare_data(entrada, device="cuda")
nombres = datos["part_id_list"]
print("partes:", nombres, "carga:", round(time.time() - t), "s", flush=True)

partes = []
with torch.no_grad():
    for i, nombre in enumerate(nombres):
        ruta_lat = os.path.join(dir_latentes, f"{nombre}.pt")
        if os.path.exists(ruta_lat):
            lat = torch.load(ruta_lat).to("cuda", torch.float16)
        else:
            lat = pipe(
                part_surface=datos["part_cond"][i:i + 1],
                whole_surface=datos["whole_cond"][i:i + 1],
                part_local_surface=datos["part_local_cond"][i:i + 1],
                num_inference_steps=pasos,
                guidance_scale=3.5,
                generator=torch.Generator(device="cuda").manual_seed(semilla),
                output_type="latent",
            ).samples
            torch.save(lat.cpu(), ruta_lat)
        salida_geo = hierarchical_extract_geometry(
            lambda x: pipe.vae.decode(lat, sampled_points=x).sample,
            "cuda",
            bounds=(-1.05, -1.05, -1.05, 1.05, 1.05, 1.05),
            dense_octree_depth=8,
            hierarchical_octree_depth=profundidad,
        )
        v, f = salida_geo[0]
        if v is None:
            print("sin superficie:", nombre, flush=True)
            continue
        malla = simplify_mesh(trimesh.Trimesh(v, f), 10000)
        malla.apply_scale(datos["part_scale_list"][i])
        malla.apply_translation(datos["part_center_list"][i].numpy())
        malla.metadata["name"] = nombre
        partes.append((nombre, malla))
        print(f"{nombre}: {len(malla.faces)} caras, cerrada={malla.is_watertight}, {round(time.time() - t)} s",
              flush=True)
        torch.cuda.empty_cache()

escena = trimesh.Scene()
for nombre, malla in partes:
    escena.add_geometry(malla, node_name=nombre, geom_name=nombre)
escena.export(salida)
print("ok", salida, "tiempo:", round(time.time() - t), "s", "VRAM pico:",
      round(torch.cuda.max_memory_allocated() / 1e9, 2), "GB")
