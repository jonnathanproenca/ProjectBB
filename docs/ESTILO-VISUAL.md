# Guia de estilo visual — Pós-guerra decadente

Versão 0.1. Base para o briefing de qualquer gerador de arte (IA ou manual). Paleta em
`assets/palette/paleta.json`, amostra em `assets/palette/paleta_swatches.png`.

## 1. Definição do mundo (visual)

- **Época:** depois de uma guerra que não deu certo. A tecnologia avançada existe só como
  restos: máquinas que ninguém sabe mais produzir, remendadas com peças de outras eras.
- **Tecnologia:** mistura de arcano e mecânica. Armas de fogo foram convertidas em focos
  arcanos: o disparo lança magia no lugar de bala. Cada arma tem um cristal de canalização
  (ciano ou roxo) no lugar do cartucho.
- **Tom:** trágico e político. Cidades divididas, facções disputando restos, pobreza visível,
  marcas da guerra presentes em tudo. Sem heroísmo de cartaz.
- **Sensação:** frio, cinza e úmido, com pontos de luz arcana que ainda funcionam. A luz é o
  que restou de poder; quem controla a luz controla a cidade.

## 2. Pilares visuais

1. **Decadência com uso.** Tudo é remendado, não destruído do zero. Peças diferentes de épocas
   diferentes convivem no mesmo objeto.
2. **Ferrugem e latão.** Metal oxidado e latão polido aparecem juntos. O latão é o que ainda
   é cuidado; a ferrugem é o que foi abandonado.
3. **Luz arcana rara.** Ciano e roxo são as únicas cores saturadas. Usados com economia, eles
   guiam o olhar.
4. **Musgo onde ninguém ainda limpou.** Verde musgo só em ruínas e interiores abandonados,
   sinal de que a natureza voltou.

## 3. Paleta (resumo)

| Papel | Cor | Hex |
|---|---|---|
| Contorno | Preto azulado | `#0d0f14` |
| Pedra e concreto | Cinza frio | `#3b3f4a` · `#4b4f5a` · `#5b6172` · `#9aa3b5` |
| Metal | Aço escuro a brilho | `#2a2e3a` · `#5b6172` · `#9aa3b5` · `#cdd3df` |
| Ferrugem | Marrom avermelhado | `#4a2416` · `#7a3b22` · `#a4582f` |
| Latão | Ocre dourado | `#6b4a1f` · `#b8893a` · `#e0b860` |
| Madeira e couro | Marrom escuro | `#2b1d14` · `#5a3a22` · `#4a2f2a` |
| Pele | Bege quente | `#e0a77a` |
| Musgo | Verde apagado | `#3a5434` · `#5a8048` |
| Arcano ciano | Ciano elétrico | `#1f7f99` · `#3fe0ff` · `#d2faff` |
| Arcano roxo | Roxo | `#4a2a8a` · `#8a4dff` |
| Alerta | Vermelho | `#8c1f1f` · `#d13b3b` |
| Fundo (noite) | Azul-grafite | `#16181f` · `#22262f` |

**Regras de uso**
- Sombras puxam para azul ou roxo; luzes puxam para amarelo ou laranja. Nunca sombra só escura.
- Não usar preto puro (`#000000`) nem branco puro (`#ffffff`).
- Ciano e roxo: no máximo 5% dos pixels de uma cena.
- Vermelho de alerta: só para perigo imediato ou dano.
- Musgo: só em ruínas e interiores abandonados.

## 4. Regras de pixel art

| Item | Padrão |
|---|---|
| Tile de chão e parede | 32 × 32 px |
| Personagem | 32 × 48 px (altura da cabeça ≈ 1/4) |
| Item de inventário | 32 × 32 px |
| Ícone de UI | 16 × 16 px ou 24 × 24 px |
| Escala na tela | Inteira (2x, 3x, 4x). Filtro *nearest*, sem suavização |
| Contorno | 1 px em `#0d0f14` para personagens e itens. Tiles sem contorno |
| Silhueta | Personagem e inimigo legíveis em preto e branco |
| Luz | Uma fonte de luz principal por cena. Sombra sempre na mesma direção |
| Paleta por cena | Máximo 16 cores fora da paleta base |

## 5. Arte de personagens e itens

- Roupas são de couro, lã e tecido grosso, com remendos e costuras visíveis.
- Armas são sempre híbridas: uma parte mecânica (metal, madeira ou latão) e um cristal arcano.
- Óculos, luvas e cintos de latão são acessórios recorrentes da classe técnica.
- Cicatrizes, faltas (um braço mecânico, um olho de vidro) são permitidas. Não há
  personagem "limpo" de guerra.

## 6. Ambientes

- Cidade: prédios de concreto com janelas tapadas, placas de metal, fios expostos, lixo
  empilhado, postes com luz arcana.
- Ruínas: escombros, veículos enferrujados, musgo em juntas de pedra.
- Interiores: fumaça, luz de lâmpada arcana, mesas e bancadas remendadas.

## 7. O que não fazer

- Neon futurista limpo, sem desgaste. Isso é outro gênero.
- Fantasia medieval limpa, com castelos e armaduras intactas.
- Identidade visual de outras franquias pós-apocalípticas: nomes, interfaces e símbolos
  próprios não podem ser copiados.
- Personagens perfeitos ou bonitos demais. O mundo é pesado.

## 8. Briefing para gerador de imagem (copiar e colar)

```
Pixel art, estilo RPG de turnos, post-war decadent world with arcane-mechanical technology.
Muted cold palette: grey stone (#4b4f5a), rust (#7a3b22), brass (#b8893a), dark leather.
Only saturated accents: cyan (#3fe0ff) and purple (#8a4dff), used sparingly.
Sprite size 32x48 for characters, 32x32 for items and tiles. Hard pixels, no anti-aliasing,
1px dark outline (#0d0f14), no pure black or white. Light from upper left, shadows bluish.
Weapons are firearms converted into arcane foci with a glowing crystal in place of the cartridge.
Mood: tragic, political, worn, repaired with mismatched parts.
```

## 9. Pendências

- Paleta de cada facção (ainda não definidas).
- Estilo de UI e fonte (a definir depois do primeiro protótipo de tela).
- Nome do mundo e da cidade (com a história, depois).
