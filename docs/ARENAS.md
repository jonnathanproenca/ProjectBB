# Arenas de combate

Status: decisões da grade e da câmera aceitas (ADR-059 a ADR-063). Arte ainda não gerada.

## Câmera e grade

- Câmera em 3/4 diagonal fixa, sem rotação (ADR-060). O combate continua por turnos.
- Grade hexagonal flat-top: topo e base retos, colunas verticais (ADR-059). Cada hex é 1,5 m.
- Área padrão visível: cerca de 12 × 9 hexes. A arte precisa caber nessa área.
- Personagens são sprites em pé, com escala pela profundidade da linha.

## Regra separada da arte (ADR-061)

Cada arena tem:

- **Fundo visual:** imagem gerada, sem personagens, com chão e objetos de contorno claro.
- **Dados por hex:** `chao`, `bloqueado`, `dificil`, `cobertura` (nenhuma, meia, três quartos ou total) e `altura`.
- **Calibrador:** ponto de origem e transformação de perspectiva, para a grade desenhada pelo código cair sobre o fundo.

A imagem nunca define colisão nem cobertura.

## Linha de visão e alcance (ADR-062)

- Calculados por linha de hexes entre atacante e alvo.
- Hex bloqueado no caminho corta a visão.
- Cobertura meia: +2 de CA. Cobertura três quartos: +5 de CA.

## Tipos de arena e variantes (ADR-063)

Cada tipo tem 3 variantes, com layout diferente (posição de coberturas e obstáculos) e iluminação própria.

| Tipo | Objetos de cobertura sugeridos |
|---|---|
| Caverna | Estalactites, pedras, poça d'água |
| Estrada | Carroça tombada, cerca, barris |
| Acampamento | Fogueira, barracas, caixotes |
| Taverna | Mesas tombadas, balcão, barris |
| Casa abandonada | Móveis quebrados, vigas, escombros |
| Poço | Borda de pedra, roldana, degraus |
| Ruína de igreja | Bancos, colunas, altar quebrado |
| Ruína antiga | Pedra cortada, estátuas, musgo |
| Floresta | Troncos, arbustos, clareira |
| Beco urbano | Caixas, muros, lixo, varal |

**Primeira leva:** estrada, taverna e ruína de igreja (cobrem o prólogo e o primeiro encontro). Os demais ficam para depois.

## Geração de arte

- Uma geração no Google Flow por tipo, pedindo as 3 variantes no mesmo prompt.
- Câmera fixa em 3/4 de cima, ângulo de cerca de 35°, mesmo enquadramento em todas as variantes.
- Sem personagens no fundo.
- Coberturas geradas à parte, sobre verde chroma key, seguindo o pipeline já usado nas espécies.
- Referências externas (assets prontos) só como guia de estilo, a não ser que estejam em 3/4 ou visão lateral.

## Arquivos planejados

- Fundos: `assets/arenas/<tipo>/<variante>.png`
- Coberturas: `assets/arenas/<tipo>/props/<nome>.png`
- Dados por arena: `scripts/data/arenas/<tipo>_<variante>.gd`
- Regra de hexes (coordenadas, vizinhos, distância, linha de visão): `scripts/rules/hex_rules.gd`, com teste em `scripts/tests/test_hex_rules.gd`

## Pendências

- Confirmar a ordem da primeira leva.
- Confirmar o estilo de arte (pintura ou pixel art) antes de gerar a primeira leva.
