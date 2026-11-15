"""Servidor MCP mínimo para pedir prompts ao Gemini.

A chave vem da variável de ambiente GEMINI_API_KEY ou, se ela não existir, do
arquivo gemini.env na raiz do projeto (ignorado pelo git). Nunca escreva a chave
neste arquivo nem no repositório.
"""

import json
import os
import urllib.error
import urllib.request
from pathlib import Path

from mcp.server.fastmcp import FastMCP

API_URL = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
DEFAULT_MODEL = os.environ.get("GEMINI_MODEL", "gemini-2.5-flash")
ENV_FILE = Path(__file__).resolve().parents[2] / "gemini.env"

mcp = FastMCP("gemini")


def _load_key() -> str:
    """Lê GEMINI_API_KEY do ambiente; se vazia, do arquivo gemini.env do projeto."""
    key = os.environ.get("GEMINI_API_KEY", "").strip()
    if key:
        return key
    if ENV_FILE.is_file():
        for linha in ENV_FILE.read_text(encoding="utf-8").splitlines():
            nome, _, valor = linha.partition("=")
            if nome.strip() == "GEMINI_API_KEY":
                valor = valor.strip().strip('"').strip("'")
                if valor and valor != "substitua_aqui":
                    return valor
    return ""


@mcp.tool()
def pedir_prompt(pedido: str, modelo: str = DEFAULT_MODEL) -> str:
    """Envia um pedido ao Gemini e devolve o texto da resposta."""
    key = _load_key()
    if not key:
        raise RuntimeError(
            "GEMINI_API_KEY não encontrada: defina a variável de ambiente ou "
            "preencha o arquivo gemini.env na raiz do projeto."
        )

    body = json.dumps({"contents": [{"parts": [{"text": pedido}]}]}).encode("utf-8")
    req = urllib.request.Request(
        API_URL.format(model=modelo),
        data=body,
        headers={"Content-Type": "application/json", "x-goog-api-key": key},
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.load(resp)
    except urllib.error.HTTPError as err:
        raise RuntimeError(f"Gemini respondeu com HTTP {err.code}.") from err

    parts = data["candidates"][0]["content"]["parts"]
    return "".join(part.get("text", "") for part in parts)


if __name__ == "__main__":
    mcp.run()
