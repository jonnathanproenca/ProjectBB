"""Renderiza tiles hexagonais flat-top e props da arena via bpy.

Saídas:
  - Tiles: 64x54 px, hex flat-top, fundo transparente, câmera ortográfica de cima.
  - Props: 64x64 px, fundo transparente, câmera isométrica, base no centro inferior.

Uso pela linha de comando (Blender em modo background):
    blender -b -P tools/render_tiles_blender.py -- --tiles <pasta> --props <pasta>

Uso em sessão Blender já aberta:
    exec(open(caminho_do_script, encoding="utf-8").read())
    gerar_tudo(pasta_tiles, pasta_props)

Parâmetros de câmera e luz são fixos para todos os tiles e para todos os props.
A remoção da cena é feita objeto a objeto: não use read_factory_settings, que
recarrega o addon do Blender e derruba conexões externas.
"""

import argparse
import math
import os
import random
import sys

import bmesh
import bpy
from mathutils import Euler, Vector

# ---------------------------------------------------------------------------
# Geometria e saída
# ---------------------------------------------------------------------------
TILE_W, TILE_H = 64, 54
RAIO_X = TILE_W / 2.0                      # 32 px: vértices nas pontas esquerda/direita
RAIO_Y = TILE_H / 2.0                      # 27 px: topo e base planos
ESCALA_Y = RAIO_Y / (RAIO_X * math.sin(math.radians(60)))

PROP_W, PROP_H = 64, 64
PROP_ANCORA = (32, 63)                     # pixel da base do prop (centro inferior)

AMOSTRAS = 64

# ---------------------------------------------------------------------------
# Paletas dos tiles da arena (manifesto), extraídas das referências.
# Cada entrada: (cor_escura, cor_clara) em hex; a borda preta foi excluída.
# Nome = nome do arquivo sem extensão, igual ao manifesto.
# ---------------------------------------------------------------------------
PALETAS_TILES = {
    "tile_estrada_01_terra_lisa": ("#65503a", "#9b8261"),
    "tile_estrada_02_terra_pedrinhas": ("#4f3e30", "#5f5c55"),
    "tile_estrada_09_entulho_tijolo": ("#3f3c35", "#9d644a"),
    "tile_estrada_10_cascalho_grama": ("#4c433c", "#8f806d"),
    "tile_estrada_10_entulho_tijolo_2": ("#493625", "#817051"),
    "tile_estrada_11_buraco_terra": ("#4c4848", "#826e54"),
    "tile_estrada_13_palha_trancada": ("#604f41", "#b79562"),
    "tile_estrada_14_cacos_ceramica": ("#703e23", "#9b8566"),
    "tile_estrada_18_pegadas": ("#604b37", "#8e7959"),
    "tile_estrada_39_ferrugem_pedra": ("#65402e", "#888b86"),
    "tile_estrada_40_entulho_metal_pedra": ("#55483d", "#928e84"),
    "tile_estrada_43_terra_cascalho": ("#574837", "#8b8c7b"),
    "tile_estrada_46_folhas_secas": ("#413b3b", "#7b634a"),
    "tile_estrada_47_pedrinhas_terra": ("#4c4239", "#7d7163"),
    "tile_estrada_49_terra_rachada": ("#414246", "#938677"),
    "tile_estrada_50_terra_rachada_palha": ("#5a4730", "#95836d"),
    "tile_estrada_54_pedras_areia": ("#403e41", "#c29e4f"),
    "tile_estrada_55_cascalho_fino": ("#434242", "#7e756e"),
    "tile_estrada_56_terra_manchas_escuras": ("#3b383c", "#785e44"),
    "tile_estrada_57_cascalho_folhas": ("#513c27", "#8c715d"),
    "tile_estrada_59_terra_fendas_poca": ("#37373c", "#776958"),
    "tile_estrada_61_pedra_cacos": ("#3d4046", "#857b73"),
    "tile_estrada_26_trilha_carroca_rodas": ("#4b3c2d", "#928167"),
    "tile_estrada_12_tabua_pregos": ("#4d3b2b", "#7d6141"),
    "tile_estrada_51_tabua_trilhos": ("#42413f", "#8d7559"),
    "tile_estrada_05_paralelepipedo_gasto": ("#3c3f35", "#8b867b"),
    "tile_estrada_07_piso_rachado": ("#3c4049", "#898987"),
    "tile_estrada_08_piso_rachado_2": ("#42454d", "#908a85"),
    "tile_estrada_36_pedra_azul_blocos": ("#514434", "#7d9098"),
    "tile_estrada_37_pedra_rachada_clara": ("#41464d", "#8f969b"),
    "tile_estrada_19_cascalho_escuro": ("#383a3f", "#70767c"),
    "tile_estrada_33_folhas_secas_escuras": ("#423326", "#8e572a"),
    "tile_estrada_38_pedra_musgo": ("#3b4a25", "#858a8a"),
    "tile_estrada_48_manchas_ferrugem": ("#453333", "#7b6953"),
    "tile_estrada_53_pocas_pedra": ("#3a3b34", "#5a5a58"),
    "tile_estrada_41_entulho_tijolo": ("#454338", "#989183"),
    "tile_03_trilha_carroca_sulcos": ("#4a4825", "#a69b92"),
}

# ---------------------------------------------------------------------------
# Props: (nome, cor principal, cor secundária)
# ---------------------------------------------------------------------------
PROPS = [
    "prop_bl_01_caixote",
    "prop_bl_02_barril",
    "prop_bl_03_cerca",
    "prop_bl_04_lampiao",
    "prop_bl_05_pedra",
    "prop_bl_06_toco",
]


def hex_para_linear(h):
    h = h.lstrip("#")
    rgb = [int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in rgb]
    return (lin[0], lin[1], lin[2], 1.0)


# ---------------------------------------------------------------------------
# Cena e render
# ---------------------------------------------------------------------------
def limpar_cena():
    # Remove objetos, materiais, câmeras, luzes e mundos sem recarregar o Blender.
    for ob in list(bpy.data.objects):
        bpy.data.objects.remove(ob, do_unlink=True)
    for m in list(bpy.data.meshes):
        if m.users == 0:
            bpy.data.meshes.remove(m)
    for m in list(bpy.data.materials):
        if m.users == 0:
            bpy.data.materials.remove(m)
    for c in list(bpy.data.cameras):
        if c.users == 0:
            bpy.data.cameras.remove(c)
    for l in list(bpy.data.lights):
        if l.users == 0:
            bpy.data.lights.remove(l)
    for w in list(bpy.data.worlds):
        if w.users == 0:
            bpy.data.worlds.remove(w)


def configurar_render(largura, altura, saida_png):
    cena = bpy.context.scene
    cena.render.engine = "CYCLES"
    cena.cycles.device = "CPU"
    cena.cycles.samples = AMOSTRAS
    cena.cycles.use_denoising = False
    cena.cycles.max_bounces = 0
    cena.cycles.diffuse_bounces = 0
    cena.cycles.glossy_bounces = 0
    cena.cycles.transmission_bounces = 0
    cena.cycles.volume_bounces = 0
    # Cor exata, sem curva de tom.
    cena.view_settings.view_transform = "Standard"
    cena.view_settings.look = "None"
    cena.view_settings.exposure = 0.0
    cena.view_settings.gamma = 1.0
    r = cena.render
    r.resolution_x = largura
    r.resolution_y = altura
    r.resolution_percentage = 100
    r.film_transparent = True
    r.image_settings.file_format = "PNG"
    r.image_settings.color_mode = "RGBA"
    r.image_settings.color_depth = "8"
    r.filepath = saida_png
    return cena


def criar_mundo_uniforme(cena, forca):
    mundo = bpy.data.worlds.new("MundoArena")
    mundo.use_nodes = True
    bg = mundo.node_tree.nodes["Background"]
    bg.inputs["Color"].default_value = (1.0, 1.0, 1.0, 1.0)
    bg.inputs["Strength"].default_value = forca
    cena.world = mundo


def criar_camera_tile(cena):
    cam_data = bpy.data.cameras.new("CamTile")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = float(TILE_W)     # 1 unidade = 1 px
    cam = bpy.data.objects.new("CamTile", cam_data)
    cena.collection.objects.link(cam)
    cam.location = (0.0, 0.0, 10.0)
    cam.rotation_euler = (0.0, 0.0, 0.0)     # de cima para baixo
    cena.camera = cam
    return cam


def criar_hex(cena):
    malha = bpy.data.meshes.new("HexTile")
    obj = bpy.data.objects.new("HexTile", malha)
    cena.collection.objects.link(obj)
    bm = bmesh.new()
    verts = []
    for i in range(6):
        ang = math.radians(60 * i)
        verts.append(bm.verts.new((RAIO_X * math.cos(ang), RAIO_X * math.sin(ang) * ESCALA_Y, 0.0)))
    bm.faces.new(verts)
    bm.normal_update()
    bm.to_mesh(malha)
    bm.free()
    return obj


def criar_material_tile(nome, cor_escura, cor_clara):
    mat = bpy.data.materials.new("Mat_" + nome)
    mat.use_nodes = True
    nt = mat.node_tree
    nt.nodes.clear()
    saida = nt.nodes.new("ShaderNodeOutputMaterial")
    emi = nt.nodes.new("ShaderNodeEmission")
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    coord = nt.nodes.new("ShaderNodeTexCoord")
    ruido = nt.nodes.new("ShaderNodeTexNoise")
    ruido.inputs["Scale"].default_value = 0.12
    ruido.inputs["Detail"].default_value = 4.0
    fino = nt.nodes.new("ShaderNodeTexNoise")
    fino.inputs["Scale"].default_value = 0.5
    fino.inputs["Detail"].default_value = 2.0
    pg = nt.nodes.new("ShaderNodeMath")
    pg.operation = "MULTIPLY"
    pg.inputs[1].default_value = 0.65
    pf = nt.nodes.new("ShaderNodeMath")
    pf.operation = "MULTIPLY"
    pf.inputs[1].default_value = 0.35
    soma = nt.nodes.new("ShaderNodeMath")
    soma.operation = "ADD"
    # Contraste: o ruído fica concentrado perto de 0.5; posições 0.35/0.65 esticam a faixa.
    ramp.color_ramp.elements[0].position = 0.35
    ramp.color_ramp.elements[0].color = hex_para_linear(cor_escura)
    ramp.color_ramp.elements[1].position = 0.65
    ramp.color_ramp.elements[1].color = hex_para_linear(cor_clara)
    nt.links.new(coord.outputs["Object"], ruido.inputs["Vector"])
    nt.links.new(coord.outputs["Object"], fino.inputs["Vector"])
    nt.links.new(ruido.outputs["Fac"], pg.inputs[0])
    nt.links.new(fino.outputs["Fac"], pf.inputs[0])
    nt.links.new(pg.outputs["Value"], soma.inputs[0])
    nt.links.new(pf.outputs["Value"], soma.inputs[1])
    nt.links.new(soma.outputs["Value"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], emi.inputs["Color"])
    emi.inputs["Strength"].default_value = 1.0
    nt.links.new(emi.outputs["Emission"], saida.inputs["Surface"])
    return mat


def render_tile(nome, pasta_saida):
    cor_e, cor_c = PALETAS_TILES[nome]
    limpar_cena()
    cena = configurar_render(TILE_W, TILE_H, os.path.join(pasta_saida, nome + ".png"))
    criar_mundo_uniforme(cena, 1.0)
    criar_camera_tile(cena)
    obj = criar_hex(cena)
    obj.name = nome
    obj.data.materials.append(criar_material_tile(nome, cor_e, cor_c))
    bpy.ops.render.render(write_still=True)
    return cena.render.filepath


# ---------------------------------------------------------------------------
# Props
# ---------------------------------------------------------------------------
def material_simples(nome, cor_hex, rugosidade=0.85):
    mat = bpy.data.materials.new(nome)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = hex_para_linear(cor_hex)
    bsdf.inputs["Roughness"].default_value = rugosidade
    return mat


def _caixa(cena, nome, tamanho, pos, mat):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=pos)
    o = bpy.context.active_object
    o.name = nome
    o.scale = tamanho
    o.data.materials.append(mat)
    return o


def _cilindro(cena, nome, raio, altura, pos, mat):
    bpy.ops.mesh.primitive_cylinder_add(radius=raio, depth=altura, location=pos, vertices=16)
    o = bpy.context.active_object
    o.name = nome
    o.data.materials.append(mat)
    return o


def construir_prop(nome):
    """Cria a geometria do prop com a base em z=0 e centrada em x=y=0."""
    if nome == "prop_bl_01_caixote":
        m = material_simples("Caixote", "#8a6a45")
        m2 = material_simples("CaixoteTampa", "#6f5234")
        _caixa(None, "caixote", (22, 22, 22), (0, 0, 11), m)
        _caixa(None, "tampa", (23, 23, 2), (0, 0, 22.5), m2)
    elif nome == "prop_bl_02_barril":
        m = material_simples("Barril", "#7a5a3a")
        aro = material_simples("Aro", "#4a4a4c", 0.5)
        _cilindro(None, "barril", 9.0, 26.0, (0, 0, 13.0), m)
        _cilindro(None, "aro_baixo", 9.4, 2.0, (0, 0, 6.0), aro)
        _cilindro(None, "aro_alto", 9.4, 2.0, (0, 0, 20.0), aro)
    elif nome == "prop_bl_03_cerca":
        m = material_simples("Madeira", "#8a6a45")
        for x in (-22, 0, 22):
            _caixa(None, "estaca", (3, 3, 30), (x, 0, 15), m)
        _caixa(None, "ripa_alta", (48, 2.5, 3), (0, 0, 22), m)
        _caixa(None, "ripa_baixa", (48, 2.5, 3), (0, 0, 10), m)
    elif nome == "prop_bl_04_lampiao":
        ferro = material_simples("Ferro", "#2e2f33", 0.5)
        vidro = material_simples("Vidro", "#d9a35a", 0.3)
        _cilindro(None, "poste", 2.0, 46.0, (0, 0, 23.0), ferro)
        _caixa(None, "lanterna", (9, 9, 11), (0, 0, 50.0), vidro)
        _caixa(None, "topo", (11, 11, 2.5), (0, 0, 56.0), ferro)
    elif nome == "prop_bl_05_pedra":
        m = material_simples("Pedra", "#7a7d80", 0.95)
        rnd = random.Random(7)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0, location=(0, 0, 6.0))
        o = bpy.context.active_object
        o.name = "pedra"
        for v in o.data.vertices:
            k = 1.0 + rnd.uniform(-0.12, 0.12)
            v.co = Vector((v.co.x * k, v.co.y * k, v.co.z * k))
        o.scale = (18, 15, 11)
        o.data.materials.append(m)
    elif nome == "prop_bl_06_toco":
        m = material_simples("Toco", "#6b4c30")
        topo = material_simples("TocoCorte", "#c09a64", 0.7)
        _cilindro(None, "toco", 13.0, 14.0, (0, 0, 7.0), m)
        _cilindro(None, "corte", 12.6, 0.4, (0, 0, 14.2), topo)
    else:
        raise KeyError("Prop sem construtor: %s" % nome)


def criar_camera_prop(cena):
    # Isométrica leve: inclinação de ~35° e giro de 45°, igual para todos os props.
    cam_data = bpy.data.cameras.new("CamProp")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = float(PROP_W)    # 1 unidade = 1 px
    cam_data.clip_start = 0.1
    cam_data.clip_end = 400.0
    cam = bpy.data.objects.new("CamProp", cam_data)
    cena.collection.objects.link(cam)
    rot = Euler((math.radians(60.0), 0.0, math.radians(45.0)), "XYZ")
    cam.rotation_euler = rot
    # Posiciona a câmera sobre a direção de visão para que o eixo Z aponte para cima.
    cam.location = rot.to_matrix() @ Vector((0.0, 0.0, 200.0))
    cena.camera = cam
    # Desloca a câmera para que a origem (base do prop) caia em PROP_ANCORA.
    # shift é em fração do lado maior (64 px): Y positivo sobe a imagem.
    cam_data.shift_x = (PROP_ANCORA[0] - PROP_W / 2.0) / PROP_W
    cam_data.shift_y = (PROP_ANCORA[1] - PROP_H / 2.0) / PROP_W
    return cam


def criar_luz_sol(cena):
    sol_data = bpy.data.lights.new("SolProp", type="SUN")
    sol_data.energy = 2.5
    sol = bpy.data.objects.new("SolProp", sol_data)
    cena.collection.objects.link(sol)
    sol.rotation_euler = (math.radians(50.0), 0.0, math.radians(-30.0))


def render_prop(nome, pasta_saida):
    limpar_cena()
    cena = configurar_render(PROP_W, PROP_H, os.path.join(pasta_saida, nome + ".png"))
    criar_mundo_uniforme(cena, 0.7)
    criar_camera_prop(cena)
    criar_luz_sol(cena)
    construir_prop(nome)
    bpy.ops.render.render(write_still=True)
    return cena.render.filepath


def gerar_tudo(pasta_tiles, pasta_props, tiles=None, props=None):
    os.makedirs(pasta_tiles, exist_ok=True)
    os.makedirs(pasta_props, exist_ok=True)
    feitos = []
    for n in (tiles or list(PALETAS_TILES.keys())):
        feitos.append(render_tile(n, pasta_tiles))
    for n in (props or PROPS):
        feitos.append(render_prop(n, pasta_props))
    return feitos


def _argumentos():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    p = argparse.ArgumentParser()
    p.add_argument("--tiles", required=True, help="Pasta de saída dos tiles")
    p.add_argument("--props", required=True, help="Pasta de saída dos props")
    p.add_argument("--so-tiles", nargs="*", default=None)
    p.add_argument("--so-props", nargs="*", default=None)
    return p.parse_args(argv)


if __name__ == "__main__":
    a = _argumentos()
    for f in gerar_tudo(a.tiles, a.props, a.so_tiles, a.so_props):
        print("ok", f)
