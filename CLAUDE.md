# Instruções do projeto (para o Claude)

## Contexto

- RPG de turnos estilo D&D (SRD 5.2) com influências de Baldur's Gate 3.
- Engine: Godot 4.7+ (GDScript). Renderer: GL Compatibility.
- MVP single player, PC; co-op e mobile depois.
- Equipe: 2 pessoas + Claude. Uso de IA em ~90% do desenvolvimento.
- Sem privilégio de administrador no ambiente: ferramentas portáteis apenas.

## Skills

- As skills de game dev estão em `.claude/skills/` (catálogo Apache-2.0, ver `NOTICE-catalog.txt`).
- Ponto de entrada: `.claude/skills/_router/SKILL.md`. Os caminhos `skills/...` citados pelo
  router correspondem a `.claude/skills/...` neste projeto.
- Engine: `.claude/skills/godot/`. Disciplinas: `.claude/skills/disciplines/`.
  Gênero: `.claude/skills/genres/rpg/` (e `roguelike` para a ordem de turno). Processo: `.claude/skills/workflows/`.
- Escolha a skill sozinho a partir do pedido (o usuário não quer decorar comandos).
- Não executar scripts de terceiros dentro das skills sem pedido explícito.

## Regras de código

- Parâmetros de escopo ficam em `scripts/config/game_config.gd` (party, nível máximo, multiclasse).
- Regras puras (cálculos de D&D) ficam em `scripts/rules/`, sem nós de cena, para testar headless.
- Todo cálculo novo de regra ganha teste em `scripts/tests/`.
- Rodar testes: `godot --headless --path . -s res://scripts/tests/test_dnd_rules.gd`.
- GDScript 4 com tipagem explícita.

## Gemini

- Pedidos ao Gemini passam pela ferramenta `pedir_prompt` do MCP `gemini` (`.mcp.json`, `mcp_servers/gemini/`).
- A chave vem da variável de ambiente `GEMINI_API_KEY` configurada no ambiente da sessão. Nunca escreva a chave em arquivos, documentos ou memória.
- Dependência: `pip install -r mcp_servers/gemini/requirements.txt`.

## Documentação

- `docs/GDD.md`: escopo e regras. Atualizar quando uma decisão mudar.
- `docs/DECISIONS.md`: ADRs. Nova decisão vira nova linha, nunca apagada.

## Idioma

- Documentos, comentários e conversa com o time em português (Brasil).
- Identificadores de código em inglês.
