# Criação de personagem — MVP (M1)

Status: proposta v0.1. Decisões fechadas estão marcadas como **(decidido)**; valores **(padrão)** podem ser ajustados no balanceamento.

## Fluxo (como no Baldur's Gate 3)

1. Nome (já existe na tela de perfil).
2. Espécie.
3. Classe.
4. Origem.
5. Atributos: valores padrão da classe, somados ao bônus da espécie.
6. Aparência: presets de rosto, corpo e cor.
7. Revisão e confirmação.

## Decisões do MVP

- **Espécies: 3 (decidido):** Humanos, Autômatos e Mestiços.
- **Variantes: masculino e feminino por espécie (decidido).** Sem tipo de corpo como variante de espécie.
- **Origens: 5 (decidido):** Soldado, Órfão, Nobre, Criminoso e Eremita.
- **Tela em estilo BG3 (decidido):** abas no topo (Espécie, Classe, Origem, Aparência, Revisão), seletores com setas, retrato central e resumo à direita.
- **Imagens de espécie (decidido):** corpo inteiro com fundo transparente, centralizado no retrato; ícones em busto com fundo ferrugem (#4a2416) dentro de moldura redonda steampunk.
- **Nome no celular (decidido):** a detecção de plataforma fica em `scripts/ui/plataforma.gd`. No celular, o nome é pedido pelo diálogo nativo do navegador ao tocar no campo.
- **Aparência: presets de rosto, corpo e cor (decidido).** Sem personalização completa estilo BG3 no MVP.
- **Atributos: valores padrão por classe (decidido).** Sem compra de pontos nem rolagem no MVP.
- **Classes do MVP: 5 (decidido):** Guerreiro, Clérigo, Ladino, Mago-Engenheiro e Atirador Arcano (ver `docs/CLASSES.md`).

## Espécies (padrão)

| Espécie | Bônus de atributo |
|---|---|
| Humanos | +1 Carisma, +1 Constituição |
| Autômatos | +2 Constituição, +1 Inteligência |
| Mestiços | +2 Carisma, +1 Destreza |

## Origens (padrão)

Cada origem dá duas perícias.

| Origem | Perícias |
|---|---|
| Soldado | Atletismo, Intimidação |
| Órfão | Furtividade, Percepção |
| Nobre | História, Persuasão |
| Criminoso | Enganação, Prestidigitação |
| Eremita | Sobrevivência, Medicina |

## Arquivos de imagem (em `assets/ui/criacao/`)

Ids usados nos nomes: `humano`, `automato`, `mestico`. Sexos: `masculino`, `feminino`.

| Arquivo | Uso |
|---|---|
| `especie_<id>_<sexo>.png` | Corpo inteiro, fundo transparente, centralizado no retrato |
| `busto_<id>_<sexo>.png` | Ícone em busto, sobre fundo ferrugem (#4a2416) |
| `icone_<id>_<sexo>.png` | Ícone final: busto dentro da moldura redonda |
| `moldura_steampunk.png` | Moldura redonda dos ícones |

## Atributos padrão por classe (padrão)

Conjunto 15, 14, 13, 12, 10, 8 distribuído por classe. Dado de vida no nível 1 entre parênteses.

| Classe | For | Des | Con | Int | Sab | Car | Dado de vida |
|---|---|---|---|---|---|---|---|
| Guerreiro | 15 | 13 | 14 | 10 | 12 | 8 | d10 |
| Clérigo | 13 | 10 | 14 | 8 | 15 | 12 | d8 |
| Ladino | 8 | 15 | 13 | 14 | 10 | 12 | d8 |
| Mago-Engenheiro | 10 | 13 | 14 | 15 | 12 | 8 | d6 |
| Atirador Arcano | 10 | 15 | 14 | 12 | 13 | 8 | d8 |

Pontos de vida no nível 1: maior valor do dado de vida + modificador de Constituição, mínimo 1.

## Regras de código

- Dados e cálculos ficam em `scripts/rules/character_rules.gd`, sem nós de cena.
- Testes em `scripts/tests/test_character_rules.gd`, rodados no GitHub Actions.
- Parâmetros de escopo (espécies, origens e classes do MVP) ficam nas constantes desse arquivo.

## Pendente

- Tela de criação em etapas, com a identidade visual do jogo.
- Ficha do personagem (M1, depois da criação).
- Lista de personagens jogáveis do grupo.
