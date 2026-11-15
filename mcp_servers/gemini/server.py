"""Servidor MCP mínimo para pedir prompts ao Gemini.

A chave vem da variável de ambiente GEMINI_API_KEY, configurada no ambiente da
sessão do projeto. Nunca escreva a chave neste arquivo nem no repositório.
"""

import json
import os
import urllib.error
import urllib.request

from mcp.server.fastmcp import FastMCP

API_URL = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
DEFAULT_MODEL = os.environ.get("GEMINI_MODEL", "gemini-2.5-flash")

mcp = FastMCP("gemini")


@mcp.tool()
def pedir_prompt(pedido: str, modelo: str = DEFAULT_MODEL) -> str:
    """Envia um pedido ao Gemini e devolve o texto da resposta."""
    key = os.environ.get("GEMINI_API_KEY", "")
    if not key:
        raise RuntimeError("GEMINI_API_KEY não está configurada no ambiente da sessão.")

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
