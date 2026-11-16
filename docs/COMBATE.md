# Combate — regras do slice (M1–M5)

Status: proposta v0.2. Decisões fechadas estão marcadas como **(decidido)**; valores **(padrão)** ainda podem ser ajustados.

## Grade e movimento

- Grade quadrada. Cada casa representa **1,5 m** (decidido).
- Movimento em metros, convertido em casas: 9 m = 6 casas (padrão).
- O jogador gasta o movimento em casas ou em metros, indistintamente.
- Diagonal conta como 1 casa (padrão, sem regra de 1,5 casa).

## Turno

- Ordem de iniciativa fixa, definida no início do combate pelos atributos de cada personagem (decidido).
- Ações por turno: **Ação**, **Ação bônus**, **Movimento**, **Reação**.
- Reação volta a ficar disponível no início do turno do personagem.

## Ataque de oportunidade

- Entra no MVP.
- Acionado quando um inimigo sai do alcance corpo a corpo, usando a Reação.

## Dano

- Fórmula de defesa em razão: `dano × K / (K + defesa)` (GDD, seção 4; implementada em `scripts/rules/dnd_rules.gd`).
- **K = 20 (decidido):** é a defesa que reduz o dano pela metade.
- **Vida dos inimigos (decidido):** pontos de vida pela tabela de monstros do SRD por nível. Os valores finais serão ajustados no balanceamento de saúde, para atingir o alvo de golpes do GDD (seção 5).

## Armas-foco arcanas (rifle)

- O rifle é um foco arcano. O disparo comum usa o **catalisador**: dado de dano + modificador de atributo (decidido: 1d8 + mod. no rifle básico).
- Armas melhores aumentam o dado do catalisador e adicionam propriedades (padrão: 1d10 e 2d6 nas próximas).
- **Disparo comum** (truque): sem custo, qualquer classe com rifle.
- **Disparo especial** (magia do rifle): consome carga por descanso curto ou longo, conforme a classe (ver `docs/CLASSES.md`).
- Padrão de referência: como truques e magias de nível no Baldur's Gate 3.

## Magias e ataques no slice

- Cada classe do slice tem 1 truque (sem custo) e 2 magias ou disparos especiais com carga.
- Sem magias de nível superior no slice.

## Escopo do slice

- Batalha de até 4 personagens do grupo contra 3–4 inimigos.
- Pelo menos um inimigo com ataque de oportunidade relevante.
