# Sprites de classe por espécie: guia para geração no Google Flow

Público: agente que gera as imagens no Google Flow (navegador embutido). Este arquivo é a instrução completa. Leia tudo antes de começar.

## 1. O que estamos fazendo

Cada espécie de início (Humanos, Autômatos, Mestiços) já tem uma imagem de referência masculina e uma feminina. Use sempre as versões com fundo verde chroma key `referencia_<espécie>_<sexo>_verde.png` (a versão original de `assets/ui/criacao/` tem fundo transparente e não deve ser usada no Flow). Agora precisamos de uma variação da mesma espécie para cada classe, com a mesma roupa e o mesmo estilo, mudando só o equipamento e os acessórios.

Resultado final: 12 folhas por espécie (uma por classe), cada folha com um homem e uma mulher lado a lado, ambos da mesma espécie e da mesma classe.

## 2. Regras que não podem ser quebradas

- **Modelo:** Nano Banana, versão **Lite** (a mais leve, que gasta menos tokens). Se não houver a versão Lite na conta, pare e avise. Não troque de modelo sem perguntar.
- **Conta:** o Google Flow é acessado com a conta do usuário, que faz o login no navegador embutido. Não digite senha, não aceite termos e não altere configurações da conta.
- **Referência:** toda solicitação leva as duas imagens de referência da espécie (masculina e feminina) anexadas. Sem referência, não gere.
- **Mesma roupa:** a roupa, o rosto, o cabelo, a paleta e o estilo de pintura são os da referência. A única mudança permitida é o equipamento e os acessórios da classe.
- **Direção:** os dois personagens olham para a direita, como nas referências.
- **Fundo:** verde chroma key sólido (#00FF00), sem sombra no chão, sem gradiente, sem moldura, sem texto.
- **Uma espécie por vez:** faça todas as 12 classes de uma espécie, na ordem abaixo. Ao terminar a espécie, entregue as imagens e pare. Não comece a próxima espécie na mesma execução, porque o limite de tokens pode acabar antes da entrega.
- **Economia:** uma solicitação por classe. O Flow devolve 3 variações; escolha a melhor. Não refaça mais de 2 vezes a mesma classe. Se falhar 3 vezes, pule e registre no relatório.

## 3. Ordem de trabalho

Primeiro as 5 classes do MVP, depois as demais. Dentro de cada espécie, sempre nesta ordem:

| # | Classe (id) | Prioridade |
|---|---|---|
| 1 | Paladino (`paladino`) | MVP (ADR-068; Guerreiro fica para depois) |
| 2 | Clérigo (`clerigo`) | MVP |
| 3 | Ladino (`ladino`) | MVP |
| 4 | Mago-Engenheiro (`mago_engenheiro`) | MVP |
| 5 | Atirador Arcano (`atirador_arcano`) | MVP |
| 6 | Piromante (`piromante`) | depois |
| 7 | Bardo (`bardo`) | depois |
| 8 | Paladino (`paladino`) | depois |
| 9 | Bárbaro (`barbaro`) | depois |
| 10 | Mecânico de Campo (`mecanico_de_campo`) | depois |
| 11 | Monge (`monge`) | depois |
| 12 | Bruxo (`bruxo`) | depois |

**Espécies, nesta ordem:** 1º Humanos (`humano`), 2º Autômatos (`automato`), 3º Mestiços (`mestico`).

Ao terminar **uma espécie inteira** (12 folhas), pare e entregue. Espere o usuário confirmar antes de começar a próxima.

## 4. Como fazer cada solicitação

1. Abra um novo projeto ou gere na tela de geração de imagens com o modelo Nano Banana Lite.
2. Anexe as duas referências verdes da espécie: `referencia_<espécie>_masculino_verde.png` e `referencia_<espécie>_feminino_verde.png`.
3. Cole o prompt da espécie com o equipamento da classe (seção 5 e 6, no lugar de `[EQUIPAMENTO]`).
4. Gere. Você recebe 3 variações.
5. Escolha a variação em que: (a) os dois personagens olham para a direita; (b) a roupa é igual à da referência; (c) o fundo é verde puro; (d) o corpo inteiro aparece, da cabeça aos pés, sem corte; (e) o equipamento da classe aparece claramente.
6. Baixe o arquivo original (sem editar nem recortar).
7. Salve com o nome `<espécie>_<classe>_sheet.png`, por exemplo `humano_guerreiro_sheet.png`.

## 5. Prompt base (cole em todas as solicitações)

Em inglês, porque o modelo responde melhor. Substitua só `[ESPÉCIE]`, `[EQUIPAMENTO]` e a descrição do sexo quando a espécie pedir.

```
Use the two attached reference images as the exact character design reference for the [ESPÉCIE] species: the man and the woman keep identical faces, hairstyles, body proportions, skin or surface finish, clothing, colors, and painting style from the references. Do not redesign the clothing.

Create one image with two full-body figures standing side by side on a flat, solid, pure green (#00FF00) chroma key background: the man on the left and the woman on the right, both facing right, same scale, same pose style, same lighting. Head to feet fully visible, no cropping.

The only change is the class equipment, added to the existing outfit: [EQUIPAMENTO]. Equipment must be the same on both figures, adapted to each body. Keep the same outfit colors and materials.

No shadow on the ground, no gradient, no border, no frame, no text, no logo, no watermark, no extra characters.
```

## 6. Equipamento por classe

Cole no lugar de `[EQUIPAMENTO]`. A roupa não muda; só se acrescenta o que está descrito.

| Classe (id) | [EQUIPAMENTO] |
|---|---|
| Guerreiro (`guerreiro`) | a long sword sheathed at the hip, a round iron shield strapped to the back, and a simple breastplate of riveted plates over the outfit |
| Clérigo (`clerigo`) | a brass holy symbol medallion on the chest, a small prayer book tied to the belt, and a short staff topped with a small brass gear ornament |
| Ladino (`ladino`) | two short daggers at the belt, a dark scarf around the neck, and a leather pouch bandolier across the chest |
| Mago-Engenheiro (`mago_engenheiro`) | a staff with a glowing crystal lens at the tip, aviator goggles pushed up on the forehead, gear-decorated gloves, and a belt with small tools and a tube-shaped pouch |
| Atirador Arcano (`atirador_arcano`) | a long crystal-core rifle slung across the back, a bandolier with brass cartridges, and a small optical scope on the rifle |
| Piromante (`piromante`) | a small fuel flask on the belt, a short fire-lance held at the side, fire-scorched leather gloves, and a cloth over the mouth and nose |
| Bardo (`bardo`) | a wooden lute strapped to the back, a wide-brimmed hat with a feather, and a bright colored scarf |
| Paladino (`paladino`) | a heavy war hammer with a gold-trimmed head resting on the shoulder, a gold oath symbol medallion on the chest, and a breastplate with gold ornaments; no shield and no sword |
| Bárbaro (`barbaro`) | a large two-handed axe over the shoulder, a studded leather chest strap, and cloth wraps on both forearms |
| Mecânico de Campo (`mecanico_de_campo`) | a large wrench in the belt, a backpack with metal tubes, an apron full of tool pockets, and a magnifying lens strapped to the forehead |
| Monge (`monge`) | cloth wraps on both hands, a short staff on the back, and no weapons on the belt |
| Bruxo (`bruxo`) | a metal pact talisman hanging from the neck, a bound pact book at the belt, and a thin crystal ribbon tied to the wrist |

## 7. Espécies: o que muda no prompt

Use sempre o prompt base da seção 5. Só troque `[ESPÉCIE]`:

- **Humanos (`humano`):** `human`.
- **Autômatos (`automato`):** `automaton`. Mantenha a superfície metálica e as juntas aparentes da referência.
- **Mestiços (`mestico`):** `mixed-heritage`. Mantenha os traços da referência, sem mudar a pele nem o rosto.

Se a referência de uma espécie tiver um detalhe que não está no texto do prompt, a referência prevalece.

## 8. Entrega

Ao terminar a espécie inteira:

1. Crie a pasta `Downloads\sprites-classes-<espécie>\` no computador do usuário e coloque os 12 arquivos `_sheet.png` nela.
2. Envie os 12 arquivos ao usuário e liste o que foi gerado.
3. Liste as classes que falharam (se houver) e quantas tentativas cada uma teve.
4. Pare. Não comece a próxima espécie até o usuário confirmar.

Não recorte nem redimensione as folhas. O recorte (corpo inteiro por sexo e busto para o retrato) é feito depois, a partir da folha original.
