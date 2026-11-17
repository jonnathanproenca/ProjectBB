# Roadmap

Prazo indeterminado, sem orçamento. Marcos por entrega jogável, não por data.

| Marco | Entrega | Critério de pronto |
|---|---|---|
| M0 — Fundação | Projeto, regras puras, testes, skills, GDD | Testes de regra passam headless (feito, via GitHub Actions) |
| M1 — Personagem | Criação inicial como no Baldur's Gate 3: classe, raça, origem, espécie; personagens jogáveis; UI de personagem | Criar personagem completo e ver a ficha |
| M2 — Mundo | Movimento no mapa, ambiente, sons e aparência de cenário | Andar pelo mapa de um ato com ambiente e sons |
| M3 — Diálogo e quests | Árvore de diálogo com flags, quests com estado | Uma quest completa com escolha que muda estado |
| M4 — UI de menu | Menus de pausa, inventário e ficha, com a identidade visual do jogo | Navegar em todos os menus sem tela quebrada |
| M5 — Combate | Grade tática, iniciativa, ataque, dano pela fórmula de defesa, grupo e ações de turno | Batalha 4x4 com reação e movimento |
| M6 — Vertical slice (MVP) | Fluxo completo: mundo, diálogo, combate, save | Jogável do início ao fim do ato 1 |
| M7 — Co-op | Sessão de rede para o grupo | Dois jogadores completam o ato 1 |
| M8 — Mobile | Porte e ajuste de controles | Build mobile rodando o ato 1 |

## Status (última atualização: noite de 16/11/2026)

- M0: feito.
- M1: implementado (criação em etapas, ficha e grupo). Falta o teste no navegador listado em docs/CRIACAO.md.
- M2: implementado (mundo em grade, NPC, menu de pausa). Sem arte de cenário e sem som (sem arquivos de áudio no projeto).
- M3: implementado (diálogo com flags e quest de exemplo). Falta o teste no navegador.
- M4: implementado (menu de pausa, inventário, ficha). Inventário ainda sem itens reais no perfil.
- M5 a M8: não iniciados.
