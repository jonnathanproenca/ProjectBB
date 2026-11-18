#!/usr/bin/env python3
"""Gera assets/arenas/manifesto.json a partir das pastas de tiles e props.

Cada arquivo recebe um papel pelo nome (palavras-chave). O gerador de arenas
(scripts/rules/arena_generator.gd) lê o manifesto, sem mexer nos arquivos.

Uso: python tools/gerar_manifesto_arenas.py
Rodar de novo sempre que entrarem imagens novas.
"""
import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ARENAS = RAIZ / "assets" / "arenas"

TIPOS = {
    "estrada": {
        "tiles_dir": ARENAS / "estrada" / "tiles_flow",
        "temas_props": ["estrada_antiga", "acampamento", "patio_poco"],
    },
}

# Ordem importa: a primeira regra que bater define o papel. Sem casamento, vira o padrão.
PALAVRAS_TILE = [
    ("pista", ["trilha", "carroca"]),
    ("centro", ["paralelepipedo", "pedra_cortada", "degrau"]),
    ("borda", ["pedra_rachada", "muro", "entulho", "cacos"]),
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


def main() -> None:
    manifesto = {"tiles": [], "props": []}
    for tipo, cfg in TIPOS.items():
        for arq in sorted(cfg["tiles_dir"].glob("*.png")):
            manifesto["tiles"].append({
                "arquivo": caminho_res(arq),
                "tipo_arena": tipo,
                "papel": classificar(arq.stem, PALAVRAS_TILE, PADRAO_TILE),
            })
        for tema in cfg["temas_props"]:
            for arq in sorted((ARENAS / "props_geral" / tema).glob("*.png")):
                manifesto["props"].append({
                    "arquivo": caminho_res(arq),
                    "tipo_arena": tipo,
                    "papel": classificar(arq.stem, PALAVRAS_PROP, PADRAO_PROP),
                })
    saida = ARENAS / "manifesto.json"
    saida.write_text(json.dumps(manifesto, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(manifesto['tiles'])} tiles e {len(manifesto['props'])} props em {saida}")


if __name__ == "__main__":
    main()
