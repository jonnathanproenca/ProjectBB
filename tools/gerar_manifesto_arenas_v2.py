#!/usr/bin/env python3
"""Gera assets/arenas/manifesto_v2.json: catálogo da V2 (tiles e props feitos no Blender).

Reaproveita a classificação de papéis de gerar_manifesto_arenas.py (TILES_ESTRADA,
classificar), trocando só a origem dos arquivos. O manifesto original não muda.

Uso (na raiz do repositório): python tools/gerar_manifesto_arenas_v2.py
"""
import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))

from gerar_manifesto_arenas import TILES_ESTRADA, classificar  # noqa: E402

ARENAS = RAIZ / "assets" / "arenas"
PASTA_TILES = ARENAS / "estrada" / "tiles_blender"
PASTA_PROPS = ARENAS / "props_blender"

# Tile de trilho da V2: versão renderizada no Blender, com o mesmo nome do original.
TILE_TRILHO = PASTA_TILES / "tile_03_trilha_carroca_sulcos.png"

PROPS_BLENDER = [
    "prop_bl_01_caixote",
    "prop_bl_02_barril",
    "prop_bl_03_cerca",
    "prop_bl_04_lampiao",
    "prop_bl_05_pedra",
    "prop_bl_06_toco",
]


def caminho_res(arquivo: Path) -> str:
    return "res://" + arquivo.relative_to(RAIZ).as_posix()


def entrada(arquivo: Path, papel: str) -> dict:
    return {"arquivo": caminho_res(arquivo), "tipo_arena": "estrada", "papel": papel}


def main() -> None:
    tiles: list[dict] = []
    props: list[dict] = []

    for papel, nomes in TILES_ESTRADA.items():
        for nome in nomes:
            arq = PASTA_TILES / f"{nome}.png"
            if not arq.exists():
                raise SystemExit(f"tile ausente: {arq.relative_to(RAIZ)}")
            tiles.append(entrada(arq, papel))

    if not TILE_TRILHO.exists():
        raise SystemExit(f"trilho ausente: {TILE_TRILHO.relative_to(RAIZ)}")
    tiles.append(entrada(TILE_TRILHO, "trilho"))

    for nome in PROPS_BLENDER:
        arq = PASTA_PROPS / f"{nome}.png"
        if not arq.exists():
            raise SystemExit(f"prop ausente: {arq.relative_to(RAIZ)}")
        props.append(entrada(arq, classificar(arq.stem)))

    saida = ARENAS / "manifesto_v2.json"
    saida.write_text(json.dumps({"tiles": tiles, "props": props}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(tiles)} tiles e {len(props)} props em {saida.relative_to(RAIZ)}")


if __name__ == "__main__":
    main()
