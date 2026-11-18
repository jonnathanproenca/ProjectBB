#!/usr/bin/env python3
"""Converte tiles pointy-top (vértice em cima) para flat-top (vértice dos lados), o formato do tabuleiro.

Detecção pela máscara de transparência: num tile flat-top a linha de cima é quase toda opaca;
num pointy-top ela tem só o vértice. Tiles pointy são girados 30 graus e ampliados para
preencher 64x54, o que fecha os cantos e elimina os espaços pretos entre hexes.
Tiles já flat-top são deixados como estão. Rode de novo sem efeito colateral.

Uso: python tools/padronizar_tiles_flat.py <pasta> [<pasta> ...]
Os originais vão para <pasta>/_pointy_originais/ antes de qualquer alteração.
"""
import shutil
import sys
from pathlib import Path

import numpy as np
from PIL import Image

LARGURA, ALTURA = 64, 54
LIMITE_LINHA = 20  # opacos na linha de cima: acima disso é flat-top


def eh_pointy(img: Image.Image) -> bool:
    alfa = np.array(img.convert("RGBA"))[..., 3] > 128
    return int(alfa[0].sum()) < LIMITE_LINHA


def converter(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    girada = rgba.rotate(30, resample=Image.BICUBIC, expand=True)
    caixa = girada.getbbox()
    recortada = girada.crop(caixa)
    escala = LARGURA / recortada.width
    nova_altura = min(ALTURA, round(recortada.height * escala))
    ampliada = recortada.resize((LARGURA, nova_altura), Image.LANCZOS)
    saida = Image.new("RGBA", (LARGURA, ALTURA), (0, 0, 0, 0))
    saida.paste(ampliada, (0, (ALTURA - nova_altura) // 2), ampliada)
    return saida


def main(pastas: list[str]) -> None:
    for pasta in pastas:
        raiz = Path(pasta)
        originais = raiz / "_pointy_originais"
        originais.mkdir(exist_ok=True)
        for png in sorted(raiz.glob("*.png")):
            img = Image.open(png)
            if not eh_pointy(img):
                continue
            if not (originais / png.name).exists():
                shutil.copy2(png, originais / png.name)
            converter(img).save(png)
            print(f"convertido: {png.name}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    main(sys.argv[1:])
