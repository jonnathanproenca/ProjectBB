# RPG D&D (working title)

RPG de turnos estilo D&D (SRD 5.2) com influências de Baldur's Gate 3. Godot 4.7+.

## Como abrir (sem instalação com admin)

1. Baixar o Godot 4.7 (ou superior) na versão portátil (zip) e extrair em uma pasta do usuário.
2. Abrir o `project.godot` pelo executável do Godot.

## Testes de regra (headless)

```
godot --headless --path . -s res://scripts/tests/test_dnd_rules.gd
```

## Estrutura

- `scripts/config/`: parâmetros de escopo (autoload `GameConfig`).
- `scripts/rules/`: regras puras do D&D.
- `scripts/tests/`: testes headless.
- `scenes/`, `data/`, `assets/`: conteúdo (pixel art, música, dados de classe/origem/espécie/magia/item/monstro/diálogo).
- `docs/`: GDD e registro de decisões.
- `.claude/`: instruções e skills de game dev para o Claude.

## Licenças

- Regras: SRD 5.2 (Creative Commons Attribution 4.0). Ver créditos em `docs/` quando publicar.
- Skills em `.claude/skills/`: Apache-2.0 (ver `NOTICE-catalog.txt`).
- Assets e músicas: cada um com licença registrada em `assets/CREDITS.md` (criar ao adicionar o primeiro).

Na primeira abertura (ou após clonar), importar os recursos antes dos testes:

```
godot --headless --path . --import
```

## Testar no navegador (GitHub Pages)

Cada push na `main` roda os testes de regra, exporta o build web do Godot e publica no GitHub Pages:

- Página: https://jonnathanproenca.github.io/ProjectBB/
- Workflow: `.github/workflows/web-pages.yml`
- Versão do Godot: variável `GODOT_VERSION` no workflow (4.7 por padrão).

Configuração única no GitHub: Settings → Pages → Build and deployment → Source: **GitHub Actions**.

O build web roda sem threads e sem cabeçalhos especiais, para funcionar no GitHub Pages.
