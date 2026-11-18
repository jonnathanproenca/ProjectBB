#!/usr/bin/env python3
"""Gera assets/arenas/manifesto.json: o catálogo de assets que o gerador de arenas lê.

Cada arquivo recebe um papel. Há duas fontes:
- Assets já commitados no repositório (lista explícita abaixo, para a versão no git funcionar).
- Pastas novas geradas no Flow/Pixel Lab (classificadas pelo nome, por palavras-chave).

Uso (na raiz do repositório): python tools/gerar_manifesto_arenas.py
Rode de novo e faça commit do manifesto sempre que entrar asset novo commitado.
"""
import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ARENAS = RAIZ / "assets" / "arenas"

# Assets já no repositório, usados como base da arena de estrada.
# Fora desta lista, os tiles não entram (ex.: 02 e tiles octogonais ficam de fora).
TILES_REPO_ESTRADA = {
    "01_estrada_terra_batida_flat": "campo",
    "tile_01_grama_seca_ferrugem": "campo",
    "tile_03_trilha_carroca_sulcos": "pista",
    "03_lama_com_pocas_flat": "centro",
    "04_piso_rachado_pedra_flat": "borda",
    "07_entulho_tijolo_pedra_flat": "borda",
}

# Pastas novas (Flow / Pixel Lab) da arena de estrada, classificadas pelo nome.
PASTAS_TILES_NOVOS_ESTRADA = [ARENAS / "estrada" / "tiles_flow"]
PASTAS_PROPS_NOVOS = {
    "estrada": [
        "estrada_antiga",
        "acampamento",
        "patio_poco",
        "ruina_pedra",
        "taverna_antiga",
        "floresta_caverna",
        "igreja_cemiterio",
        "beco_urbano",
    ],
}

PALAVRAS_TILE = [
    ("pista", ["trilha", "carroca"]),
    ("centro", ["paralelepipedo", "pedra_cortada", "degrau"]),
    ("borda", ["pedra_rachada", "piso_rachado", "muro", "entulho", "cacos"]),
]
PADRAO_TILE = "campo"

PALAVRAS_PROP = [
    ("lampiao", ["lampiao"]),
    ("cerca", ["cerca", "muro", "estaca", "arame", "grade", "portao"]),
]
PADRAO_PROP = "cobertura"


def classificar(nome: str, regras, padrao: str) -> str:
    nome = nome.lower()
    for papel, palavras in regras:
        if any(p in nome for p in palavras):
            return papel
    return padrao


def caminho_res(arquivo: Path) -> str:
    return "res://" + arquivo.relative_to(RAIZ).as_posix()


def entrada(arquivo: Path, tipo: str, papel: str) -> dict:
    return {"arquivo": caminho_res(arquivo), "tipo_arena": tipo, "papel": papel}


def main() -> None:
    tiles: list[dict] = []
    props: list[dict] = []

    # Repositório: tiles e props que já estão commitados.
    for stem, papel in TILES_REPO_ESTRADA.items():
        arq = ARENAS / "tiles" / f"{stem}.png"
        if arq.exists():
            tiles.append(entrada(arq, "estrada", papel))
    for arq in sorted((ARENAS / "estrada" / "props").glob("*.png")):
        props.append(entrada(arq, "estrada", classificar(arq.stem, PALAVRAS_PROP, PADRAO_PROP)))

    # Pastas novas: entram se existirem (depois de commitadas).
    for pasta in PASTAS_TILES_NOVOS_ESTRADA:
        for arq in sorted(pasta.glob("*.png")):
            tiles.append(entrada(arq, "estrada", classificar(arq.stem, PALAVRAS_TILE, PADRAO_TILE)))
    for tipo, temas in PASTAS_PROPS_NOVOS.items():
        for tema in temas:
            for arq in sorted((ARENAS / "props_geral" / tema).glob("*.png")):
                props.append(entrada(arq, tipo, classificar(arq.stem, PALAVRAS_PROP, PADRAO_PROP)))

    saida = ARENAS / "manifesto.json"
    saida.write_text(json.dumps({"tiles": tiles, "props": props}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(tiles)} tiles e {len(props)} props em {saida.relative_to(RAIZ)}")


if __name__ == "__main__":
    main()
