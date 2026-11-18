#!/usr/bin/env python3
"""Remove o resto de chroma verde (#00FF00) das imagens de arena.

Pixels muito verdes viram transparentes. Pixels na faixa de transição perdem
verde e ficam semitransparentes, para não sobrar franja. Musgo e grama têm pouco
excesso de verde, então ficam intactos.

Uso: python tools/refinar_chroma.py <pasta> [<pasta> ...]
Os originais vão para <pasta>/_originais/ antes de qualquer alteração.
"""
import shutil
import sys
from pathlib import Path

import numpy as np
from PIL import Image

LIMITE_FUNDO = 120    # excesso de verde acima disso = fundo, some
LIMITE_BORDA = 60     # entre LIMITE_BORDA e LIMITE_FUNDO = transição, fica semitransparente


def refinar(caminho: Path) -> tuple[int, int]:
    img = Image.open(caminho).convert("RGBA")
    a = np.array(img).astype(np.int16)
    r, g, b, alfa = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
    excesso = g - np.maximum(r, b)

    fundo = excesso > LIMITE_FUNDO
    borda = (excesso > LIMITE_BORDA) & ~fundo

    novo_g = g.copy()
    novo_g[borda] = np.minimum(g[borda], np.maximum(r[borda], b[borda]) + 10)

    novo_alfa = alfa.copy()
    novo_alfa[fundo] = 0
    fator = 1.0 - (excesso[borda] - LIMITE_BORDA) / (LIMITE_FUNDO - LIMITE_BORDA)
    novo_alfa[borda] = np.clip(alfa[borda] * fator, 0, 255)

    saida = np.stack([r, novo_g, b, novo_alfa], axis=-1).astype(np.uint8)
    Image.fromarray(saida, "RGBA").save(caminho)
    return int(fundo.sum()), int(borda.sum())


def main(pastas: list[str]) -> None:
    for pasta in pastas:
        raiz = Path(pasta)
        originais = raiz / "_originais"
        originais.mkdir(exist_ok=True)
        for png in sorted(raiz.glob("*.png")):
            if not (originais / png.name).exists():
                shutil.copy2(png, originais / png.name)
            fundo, borda = refinar(png)
            print(f"{png.name}: {fundo} px de fundo removidos, {borda} px de borda suavizados")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    main(sys.argv[1:])
