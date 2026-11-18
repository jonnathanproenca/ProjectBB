#!/usr/bin/env python3
"""Converte tiles pointy-top (vértice em cima) para flat-top (vértice dos lados), o formato do tabuleiro.

Detecção pela máscara de transparência: num tile flat-top a linha de cima é quase toda opaca;
num pointy-top ela tem só o vértice. Tiles pointy são girados 30 graus e ampliados para
preencher 64x54, o que fecha os cantos e elimina os espaços pretos entre hexes.
Tiles já flat-top são deixados como estão. Rode de novo sem efeito colateral.

Depois da conversão, limpa o contorno: recorta num hexágono flat-top perfeito (64x54) e
preenche por inpainting os buracos que a arte original deixou dentro dele. Isso remove
os recortes e os restos de borda da folha do Flow.

Uso: python tools/padronizar_tiles_flat.py <pasta> [<pasta> ...]
Os originais vão para <pasta>/_pointy_originais/ antes de qualquer alteração.
"""
import shutil
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

LARGURA, ALTURA = 64, 54
LIMITE_LINHA = 12  # pixels opacos na primeira linha: acima disso é aresta (flat-top)


def eh_pointy(img: Image.Image) -> bool:
    """Pointy: a primeira linha opaca é só o vértice (poucos pixels). Flat: é uma aresta larga."""
    alfa = np.array(img.convert("RGBA"))[..., 3] > 128
    linhas = np.where(alfa.any(axis=1))[0]
    if linhas.size == 0:
        return False
    return int(alfa[linhas[0]].sum()) < LIMITE_LINHA


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


def mascara_hexagono() -> np.ndarray:
    """Hexágono flat-top 64x54 com antisserrilhado (4x), valores de 0 a 1."""
    fator = 4
    w, h = LARGURA * fator, ALTURA * fator
    cx, cy = w / 2, h / 2
    raio = 32.0 * fator
    pontos = np.array([
        [cx - raio, cy], [cx - raio / 2, cy - raio * np.sqrt(3) / 2],
        [cx + raio / 2, cy - raio * np.sqrt(3) / 2], [cx + raio, cy],
        [cx + raio / 2, cy + raio * np.sqrt(3) / 2], [cx - raio / 2, cy + raio * np.sqrt(3) / 2],
    ], dtype=np.float32)
    alta = np.zeros((h, w), dtype=np.uint8)
    cv2.fillPoly(alta, [np.round(pontos).astype(np.int32)], 255)
    return cv2.resize(alta, (LARGURA, ALTURA), interpolation=cv2.INTER_AREA).astype(np.float32) / 255.0


MASCARA = mascara_hexagono()


def limpar_contorno(img: Image.Image) -> Image.Image:
    arr = np.array(img.convert("RGBA"))
    rgb = np.ascontiguousarray(arr[..., :3])
    alfa = arr[..., 3]
    dentro = MASCARA > 0.5
    buraco = (dentro & (alfa < 128)).astype(np.uint8) * 255
    if buraco.any():
        rgb = cv2.inpaint(rgb, buraco, 3, cv2.INPAINT_TELEA)
    nova = np.dstack([rgb, np.clip(MASCARA * 255, 0, 255).astype(np.uint8)])
    return Image.fromarray(nova, "RGBA")


def main(pastas: list[str]) -> None:
    for pasta in pastas:
        raiz = Path(pasta)
        originais = raiz / "_pointy_originais"
        originais.mkdir(exist_ok=True)
        for png in sorted(raiz.glob("*.png")):
            img = Image.open(png)
            if eh_pointy(img):
                if not (originais / png.name).exists():
                    shutil.copy2(png, originais / png.name)
                img = converter(img)
                print(f"convertido: {png.name}")
            limpar_contorno(img).save(png)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    main(sys.argv[1:])
