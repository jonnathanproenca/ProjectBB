# Brief — Combate MVP (M1)

QUESTION:   Um combate por casas com ataque de oportunidade e disparo focado é legível e divertido em uma batalha curta?
CORE VERB:  Mover e atacar, escolhendo entre disparo comum e disparo focado.
THROWAWAY:  não. O código fica no projeto por pedido do time, mas marcado como protótipo (cena `scenes/combat.tscn`).
TIMEBOX:    uma sessão de teste (cerca de 10 minutos de combate).

KEEP IF:    o jogador entende o turno sem explicação, usa o disparo focado de forma deliberada e percebe o ataque de oportunidade.
KILL IF:    o jogador não entende quando pode mover ou atacar, ou o combate termina em menos de 3 rodadas sem decisão.

## Ajustes (constantes em `scripts/combat/combat_view.gd`)

- Grade: 10 × 7 casas, cada casa 1,5 m.
- Movimento: 6 casas (9 m).
- Alcance corpo a corpo: 1 casa. Alcance do rifle: 16 casas (24 m).
- Rifle: 3 cargas de disparo focado (2d8 + modificador). Disparo comum: 1d8 + modificador.
- Jogadores: Guerreiro (corpo a corpo) e Atirador (rifle).
- Inimigos: três bandidos com 9 PV e CA 12.

## Limites deste protótipo

- Sem ação bônus, sem magias e sem combate com cobertura ou linha de visão.
- Ataque de oportunidade simplificado: dispara quando um inimigo corpo a corpo sai de uma casa adjacente, comparando só a casa de partida e a de chegada.
- Descanso não existe: o botão "Recarregar (teste)" restaura as cargas só para testar.
- Sem gamepad nesta versão. Touch funciona pela emulação de mouse do navegador.

## RESULT

Pendente. Preencher após o teste com a decisão (keep, kill ou retune) e a evidência.
