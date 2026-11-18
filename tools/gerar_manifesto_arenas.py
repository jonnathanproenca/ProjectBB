#!/usr/bin/env python3
"""Gera assets/arenas/manifesto.json: o catálogo de assets que o gerador de arenas lê.

Só entra asset da lista curada abaixo. Motivo: tiles com borda grossa, bisel ou cor
chapada (laranja, rosa, azul, amarelo) e props altos (portão, tenda, varal) deixavam
a arena com cara de colagem. A lista é de arquivos pelo nome, então adicionar um
asset novo exige mexer aqui de propósito.

Uso (na raiz do repositório): python tools/gerar_manifesto_arenas.py
Rode de novo e faça commit do manifesto sempre que a lista mudar.
"""
import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ARENAS = RAIZ / "assets" / "arenas"
PASTA_TILES = ARENAS / "estrada" / "tiles_flow"
PASTA_PROPS = ARENAS / "props_geral"
TEMAS_PROPS = [
    "estrada_antiga", "acampamento", "patio_poco", "ruina_pedra",
    "taverna_antiga", "floresta_caverna", "igreja_cemiterio", "beco_urbano",
]

# Tiles de terra, pedra e estrada, sem borda nem cor chapada. Papel definido à mão.
TILES_ESTRADA = {
    "campo": [
        "tile_estrada_01_terra_lisa", "tile_estrada_02_terra_pedrinhas",
        "tile_estrada_09_entulho_tijolo", "tile_estrada_10_cascalho_grama",
        "tile_estrada_10_entulho_tijolo_2", "tile_estrada_11_buraco_terra",
        "tile_estrada_13_palha_trancada", "tile_estrada_14_cacos_ceramica",
        "tile_estrada_18_pegadas", "tile_estrada_39_ferrugem_pedra",
        "tile_estrada_40_entulho_metal_pedra", "tile_estrada_43_terra_cascalho",
        "tile_estrada_46_folhas_secas", "tile_estrada_47_pedrinhas_terra",
        "tile_estrada_49_terra_rachada", "tile_estrada_50_terra_rachada_palha",
        "tile_estrada_54_pedras_areia", "tile_estrada_55_cascalho_fino",
        "tile_estrada_56_terra_manchas_escuras", "tile_estrada_57_cascalho_folhas",
        "tile_estrada_59_terra_fendas_poca", "tile_estrada_61_pedra_cacos",
    ],
    "pista": [
        "tile_estrada_26_trilha_carroca_rodas", "tile_estrada_12_tabua_pregos",
        "tile_estrada_51_tabua_trilhos",
    ],
    "centro": [
        "tile_estrada_05_paralelepipedo_gasto", "tile_estrada_07_piso_rachado",
        "tile_estrada_08_piso_rachado_2", "tile_estrada_36_pedra_azul_blocos",
        "tile_estrada_37_pedra_rachada_clara",
    ],
    "borda": [
        "tile_estrada_19_cascalho_escuro", "tile_estrada_33_folhas_secas_escuras",
        "tile_estrada_38_pedra_musgo", "tile_estrada_48_manchas_ferrugem",
        "tile_estrada_53_pocas_pedra", "tile_estrada_41_entulho_tijolo",
    ],
}

# Props que ficam no chão e têm cara de cobertura baixa. Tipo pelo nome (cerca, lampião, cobertura).
PROPS_ESTRADA = {
    "prop_18_carroca_tombada", "prop_20_pilha_barris", "prop_21_poste_lampiao_apagado",
    "prop_41_carroca_quebrada", "prop_42_cerca_quebrada", "prop_43_barris",
    "prop_44_lampiao_apagado", "prop_45_marco_pedra", "prop_47_banco",
    "prop_59_caixote", "prop_62_toco_corte", "prop_64_sacos_lona",
    "prop_68_sarcofago", "prop_69_bacia_pedra", "prop_70_urna",
    "prop_73_poco", "prop_75_balde_madeira", "prop_79_grade_ferro",
    "prop_80_lampiao_rua", "prop_81_tronco_caido", "prop_82_toco_grande",
    "prop_83_arbusto", "prop_84_pedra_musgo", "prop_97_lixeira",
    "prop_98_caixotes_lixo", "prop_100_vaso_quebrado", "prop_104_sacos_lixo",
}

PALAVRAS_PROP = [
    ("lampiao", ["lampiao"]),
    ("cerca", ["cerca", "grade", "muro", "estaca", "arame"]),
]
PADRAO_PROP = "cobertura"


def classificar(nome: str) -> str:
    nome = nome.lower()
    for papel, palavras in PALAVRAS_PROP:
        if any(p in nome for p in palavras):
            return papel
    return PADRAO_PROP


def caminho_res(arquivo: Path) -> str:
    return "res://" + arquivo.relative_to(RAIZ).as_posix()


def entrada(arquivo: Path, tipo: str, papel: str) -> dict:
    return {"arquivo": caminho_res(arquivo), "tipo_arena": tipo, "papel": papel}


def main() -> None:
    tiles: list[dict] = []
    props: list[dict] = []

    for papel, nomes in TILES_ESTRADA.items():
        for nome in nomes:
            arq = PASTA_TILES / f"{nome}.png"
            if not arq.exists():
                raise SystemExit(f"tile ausente: {arq.relative_to(RAIZ)}")
            tiles.append(entrada(arq, "estrada", papel))

    candidatos = [PASTA_TILES.parent.parent / "props" / f"{n}.png" for n in PROPS_ESTRADA]
    candidatos += [PASTA_PROPS / tema / f"{n}.png" for tema in TEMAS_PROPS for n in PROPS_ESTRADA]
    for arq in candidatos:
        if arq.exists():
            props.append(entrada(arq, "estrada", classificar(arq.stem)))

    saida = ARENAS / "manifesto.json"
    saida.write_text(json.dumps({"tiles": tiles, "props": props}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(tiles)} tiles e {len(props)} props em {saida.relative_to(RAIZ)}")


if __name__ == "__main__":
    main()
