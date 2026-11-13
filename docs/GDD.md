# GDD — RPG estilo D&D (working title)

Versão: 0.1 (fundação, dia 0). Documento vivo.

## 1. Visão

RPG de turnos para PC, com regras do D&D 5e (SRD 5.2) adaptadas ao que o Baldur's Gate 3 faz
bem: combate tático em grade, exploração com testes de habilidade e diálogo com escolhas.
MVP single player; co-op depois. Porte futuro para mobile.

## 2. Pilares

1. **Regras de mesa, leitura de jogo.** Dados e testes visíveis, mas sem exigir que o jogador
   saiba a regra.
2. **Combate tático.** Posição, ação, ação bônus, movimento e reação importam.
3. **Escolha com consequência.** Diálogo e exploração mudam o estado do mundo e do grupo.

## 3. Escopo

| Área | MVP (single player) | Pós-MVP |
|---|---|---|
| Modo | Single player | Co-op |
| Plataforma | PC | Mobile |
| Nível máximo | 5 | Aumentar até 20 (limites do D&D) |
| Grupo | Até `GameConfig.PARTY_MAX_SIZE` (padrão 4) | Ajustar por parâmetro |
| Classes | Predefinidas (SRD 5.2) | Ampliar |
| Origens | Predefinidas | Ampliar |
| Espécies | Predefinidas (SRD) | Ampliar |
| Multiclasse | Sim, com pré-requisitos de atributo | — |

## 4. Regras

- Base: SRD 5.2 (CC-BY-4.0). Evitar o nome "D&D" como marca no título e no marketing.
- Atributos, modificador `floor((valor-10)/2)`, bônus de proficiência por faixa de nível.
- XP: tabela oficial de limiares (`scripts/rules/dnd_rules.gd`).
- Dano: redução por defesa em razão `dano * K / (K + defesa)` (sem imunidade por acúmulo).
- Adaptações para se aproximar do BG3: iniciativa por turno, ação/ação bônus/movimento/reação,
  testes de habilidade com resultado visível, ataques de oportunidade e superfícies do cenário
  (a definir na fase de combate).

## 5. Combate (MVP)

- Grade tática, turnos por iniciativa.
- Ações: atacar, mover, usar item, ação bônus, reação, magia (quando houver).
- Alvo de design (ponto de partida, não medido): inimigo normal cai em 2–4 golpes do jogador
  de mesmo nível; jogador aguenta 5–8 golpes normais; chefe leva 25–60 golpes.

## 6. Exploração e diálogo

- Exploração em mapas com interação, testes de habilidade e flags de estado.
- Diálogo em árvore com condições (flags, testes, classe) e consequências persistentes.
- Escolhas de diálogo entram no mesmo sistema de flags do save.

## 7. Criação de personagem

- Classes, origens e espécies predefinidas.
- Multiclasse permitida, respeitando pré-requisitos de atributo e a regra de espaço de nível.
- Atributos por valores padrão no MVP (point buy ou rolagem ficam para depois).

## 8. Progressão

- XP por combate e exploração/missões.
- Teto de nível configurável em `GameConfig.MAX_LEVEL` (5 no MVP).

## 9. Arte e áudio

- Pixel art. Mistura de: download de bancos de arte, geração por IA, criação manual e geração
  por prompt. Padronizar paleta e resolução por família de assets antes de produzir em massa.
- Sem dublagem no MVP.
- Música: geração procedural ou trilhas licenciadas/obtidas de fontes com licença clara.
  Registrar a origem e a licença de cada faixa e de cada asset externo.

## 10. Uso de IA no desenvolvimento

- Meta: 90%+ do desenvolvimento assistido por IA (Claude e outras ferramentas, incluindo
  IAs de apoio à construção do mundo).
- Toda saída de IA entra com revisão humana e teste (ver `scripts/tests`).

## 11. Fora de escopo por enquanto

- História e narrativa: definir depois, com apoio de IAs de worldbuilding.
- Estratégia e negócio: não definida.

## 12. Ferramentas e restrições de ambiente

- Godot 4.7 ou superior, versão portátil (sem instalação com privilégio de administrador).
- Sem dependências que exijam instalação de sistema.
- Sem infraestrutura externa (servidores, bancos) no MVP.
