# Registro de decisões (ADR)

| # | Decisão | Motivo | Status |
|---|---|---|---|
| ADR-001 | Engine: Godot 4.7+ | Gratuita, portátil, sem instalação admin, 2D e 3D, boa para RPG de turnos, porte futuro | Aceita |
| ADR-002 | Renderer: GL Compatibility | Roda em mais hardware e facilita porte para mobile | Aceita |
| ADR-003 | Regras: SRD 5.2 (CC-BY-4.0) | Base aberta, evita marca "D&D" e licenças fechadas | Aceita |
| ADR-004 | Plataforma-alvo: PC; mobile depois | Escopo do MVP | Aceita |
| ADR-005 | Single player no MVP; co-op depois | Escopo do MVP | Aceita |
| ADR-006 | Nível máximo 5 no MVP, configurável | Escopo; regra do D&D até 20 | Aceita |
| ADR-007 | Grupo limitado por `GameConfig.PARTY_MAX_SIZE` | Facilitar ajuste sem refatorar | Aceita |
| ADR-008 | Classes, origens e espécies predefinidas; multiclasse liberada | Escopo do MVP | Aceita |
| ADR-009 | Arte em pixel art com mistura de fontes | Pedido do time | Aceita |
| ADR-010 | Sem voz no MVP; música procedural ou com licença clara | Escopo e licenças | Aceita |
| ADR-011 | História e estratégia de negócio não definidas | Serão definidas depois | Adiada |
| ADR-012 | Skills de game dev do catálogo copiadas para `.claude/skills` (Apache-2.0, ver NOTICE) | Projeto já nasce com o contexto | Aceita |
| ADR-013 | Cenário: pós-guerra decadente, tom trágico e político, tecnologia arcano-mecânica (armas de fogo convertidas em focos arcanos) | Direção escolhida na conversa com o time; detalhes em `docs/ESTILO-VISUAL.md` | Aceita (história e nome do mundo: adiados) |
| ADR-014 | Guia de estilo visual v0.1 com paleta de 30 cores fixas e regras de pixel art (32x32 tile, 32x48 personagem) | Base para briefing de geradores de arte externos | Aceita |
| ADR-015 | Nível de tecnologia: pós-guerra decadente (restos de tecnologia avançada, sem produção nova; não vapor nem dieselpunk) | Confirmado pelo time; combina com tom trágico e político | Aceita |
| ADR-016 | Idiomas: português (padrão), inglês e espanhol | Pedido do time; tradução por tabela (CSV) desde o início | Aceita |
| ADR-017 | Controles: mouse e teclado, gamepad (PS4, Xbox, GameSir) e touch | Pedido do time; porte mobile depois | Aceita |
| ADR-018 | Save local em `user://` (desktop) e IndexedDB do navegador (web) | Save persiste entre refreshes nos testes pelo GitHub Pages | Aceita |
| ADR-019 | Grade quadrada, 1 casa = 1,5 m, movimento em metros convertido em casas, diagonal = 1 casa | Pedido do time (valor de X ainda não informado; padrão SRD) | Proposta |
| ADR-020 | Ataque de oportunidade no MVP | Pedido do time | Aceita |
| ADR-021 | MVP com 5 classes: Guerreiro, Clérigo, Ladino, Mago-Engenheiro, Atirador Arcano; mais 15 classes depois (total 20) | Pedido do time | Aceita |
| ADR-022 | Rifle é foco arcano: disparo comum sem custo, disparos especiais limitados por descanso curto ou longo conforme a classe | Pedido do time, referência de magias no Baldur's Gate 3 | Aceita |
| ADR-023 | Formas de poder: Magia, Arcano, Combustível, Influência, Milagre (Instinto proposto) | Pedido do time | Aceita (Instinto: proposta) |
| ADR-024 | 50 classes propostas, corte final de 12, MVP de 5 | Pedido do time | Aceita |
