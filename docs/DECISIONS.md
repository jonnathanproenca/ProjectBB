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
| ADR-025 | Primeira versão de armas (30) e equipamentos por categoria (armaduras, luvas, calças, sapatos, elmos, capas, anéis, amuletos), dados D&D/SRD com efeitos propostos | Pedido do time | Aceita (efeitos: propostas) |
| ADR-026 | Fluxo de entrada: login (Entrar, Opções) sobre fundo separado, seleção de perfil com até 3 slots (criação só com nome nesta etapa), Opções com idioma (pt-BR, en, es) e brilho salvos em user:// | Pedido do time | Aceita |
| ADR-027 | Carregamento web e splash com a marca Mann Systems no lugar do Godot; favicon do jogo (engrenagem com cristal) | Pedido do time | Aceita |
| ADR-028 | Menus com chapa com rebite (NinePatch) e texto montado com letras recortadas do alfabeto dourado (maiúsculas e minúsculas); acentos, números e pontuação saem como texto comum até haver folha própria | Pedido do time | Aceita (acentos e números: pendentes) |
| ADR-029 | Lacuna LAC-02 (moeda): sem moeda comum agora; formas locais e termos genéricos, sem cotação canônica | Decisão do time; evita inventar sistema monetário | Aceita |
| ADR-030 | Lacuna LAC-03 (procedimentos): piso mínimo comum (autoridade local, registro, acesso das partes, recurso local, limite à emergência); sem tribunal continental | Decisão do time; mantém previsibilidade sem criar tribunal | Aceita |
| ADR-031 | Lacuna LAC-04 (provas de ecos e ritos): custódia e consentimento; cópias não autorizadas não são autenticadas; ecos só corroboram | Decisão do time; protege contra coerção | Aceita |
| ADR-032 | Lacuna LAC-05 (servidão e tráfico): regra comum proíbe propriedade de pessoas e dívida hereditária; mapeamento provisório: Carvamar permite, Pacto da Bacia e Juramento dos Poços sob submundo, demais proíbem | Decisão do time (resposta própria, não as opções propostas); mapeamento por potência é provisório | Aceita (mapeamento: provisório) |
| ADR-033 | Propostas linguísticas LAC-08 a LAC-26 não canonizadas; descrições atuais permanecem, sem novas regras fonológicas, afixos ou nomes de língua | Decisão do time; as propostas do Manus não foram aceitas | Aceita |
| ADR-034 | Grade com 1 casa = 1,5 m (5 pés do SRD) | Decisão do time sobre a grade do combate | Aceita |
| ADR-035 | Ordem de iniciativa fixa definida no início do combate, pelos atributos de cada personagem | Decisão do time; sem rolagem por rodada | Aceita |
| ADR-036 | K = 20 na redução de dano por defesa (defesa 20 reduz o dano pela metade); padrão do código atualizado | Decisão do time; escala parecida com a Classe de Armadura do SRD | Aceita |
| ADR-037 | Vida dos inimigos pela tabela de monstros do SRD por nível; balanceamento de saúde depois | Decisão do time; alvo de golpes definido no GDD seção 5 | Aceita (valores finais: balanceamento) |
| ADR-038 | Disparo comum do rifle (catalisador): 1d8 + modificador de atributo | Decisão do time; base para as armas-foco evoluírem | Aceita |
| ADR-039 | Movimento: 9 m = 6 casas por turno; diagonal conta como 1 casa | Decisão do time; regra simples de grade | Aceita |
| ADR-040 | Armas-foco do rifle evoluem para 1d10 e 2d6 no catalisador | Decisão do time; valores propostos no documento de combate | Aceita |
| ADR-041 | Ordem de marcos: personagem, mundo, diálogo e quests, UI de menu, combate por último; vertical slice depois | Pedido do time: combate só depois de definidos os demais sistemas | Aceita |
| ADR-042 | Criação de personagem no MVP: 3 espécies (Humanos, Autômatos, Mestiços) e 5 origens (Soldado, Órfão, Nobre, Criminoso, Eremita) | Decisão do time; bônus e perícias das espécies e origens são padrão | Aceita (bônus e perícias: padrão) |
| ADR-043 | Aparência no MVP: presets de rosto, corpo e cor; sem personalização completa | Decisão do time; reduz trabalho de arte | Aceita |
| ADR-044 | Atributos no MVP: valores padrão por classe, sem compra de pontos nem rolagem | Decisão do time | Aceita |
| ADR-045 | Regras de criação em `scripts/rules/character_rules.gd`, com teste em `scripts/tests/test_character_rules.gd` | Mesmo padrão das demais regras puras | Aceita |
| ADR-046 | Espécies de início: Humanos, Autômatos e Mestiços, cada uma com variante masculino e feminino, sem tipo de corpo | Decisão do time; detalha ADR-042 (3 espécies) com a variação por sexo; os presets de corpo da ADR-043 seguem na aparência | Aceita (presets de corpo: a confirmar) |
| ADR-047 | Criação de personagem em estilo Baldur's Gate 3: abas no topo (Espécie, Classe, Origem, Aparência, Revisão), seletores com setas, retrato central e resumo à direita | Pedido do time; referência de BG3 | Aceita |
| ADR-048 | Imagens de espécie: corpo inteiro (fundo transparente, centralizado no retrato) e ícones em busto com fundo ferrugem (#4a2416) dentro de moldura redonda steampunk; arquivos em `assets/ui/criacao/`: `especie_<id>_<sexo>.png`, `busto_<id>_<sexo>.png`, `icone_<id>_<sexo>.png` e `moldura_steampunk.png` | Decisão do time; nomes fixos para a arte e o código carregarem os mesmos arquivos | Aceita |
| ADR-049 | Nome no celular: detecção de plataforma em `scripts/ui/plataforma.gd`; no celular o nome é pedido pelo diálogo nativo do navegador ao tocar no campo | Decisão do time; digitação no celular pela web passa pelo diálogo do navegador | Aceita |
| ADR-050 | Abas da criação em ordem Origem, Raça, Classe, Background, Habilidades, Perícias, Aparência; a aba Revisão foi removida | Decisão do time; substitui a lista de abas da ADR-047 (a espécie passa a se chamar Raça na tela; o id de código segue `especie`) | Aceita |
| ADR-051 | A aba Origem escolhe o personagem: no MVP só "personalizado" (`CharacterRules.PERSONAGENS`); as antigas origens (Soldado, Órfão, Nobre, Criminoso, Eremita) viram a aba Background | Decisão do time; abre espaço para personagens prontos depois, sem mudar `ORIGENS` | Aceita |
| ADR-052 | Habilidades (atributos) são fixas pela classe, sem compra de pontos nem rolagem; a aba só mostra os valores, já com o bônus da raça | Decisão do time; reforça a ADR-044 | Aceita |
| ADR-053 | Perícias vêm da classe e do background, sem escolha no MVP: `CharacterRules.pericias_finais(classe, origem)` une as duas listas, sem repetir e em ordem alfabética; perícia repetida não é compensada com outra | Decisão do time; mantém a tela simples e o cálculo testável | Aceita |
| ADR-054 | Proficiências escolhidas: background usa as perícias já definidas em `docs/CRIACAO.md` (padrão, ADR-042). Classes não tinham perícias no doc: Guerreiro (Atletismo, Percepção), Clérigo (Medicina, Religião), Ladino (Enganação, Furtividade, Percepção, Prestidigitação), Mago-Engenheiro (Arcanismo, Investigação), Atirador Arcano (Furtividade, Percepção). Guerreiro, Clérigo, Ladino e Mago saem das listas de classe do SRD 5.2 (escolhendo fixo o que a lista permite, com 4 perícias no Ladino); Atirador Arcano é classe nova sem equivalente no SRD, então segue a lista do Patrulheiro (Des/Sab) | Decisão provisória do agente, sujeita a revisão do time; sem escolha no MVP (ADR-053) | Aceita (valores das classes: padrão) |
| ADR-055 | A aparência (presets de rosto, corpo e cor) sai do MVP e fica para a versão 3.0; a aba Aparência é removida e Concluir passa para a aba Perícias. O campo `appearance` do perfil segue salvo com 0, sem mudar o formato | Decisão do usuário; substitui a ADR-043 nessa parte (a ADR-043 e a lista de abas da ADR-050 ficam como histórico) | Aceita |
| ADR-056 | Jogar guarda o perfil escolhido em `MenuPausa.perfil_ativo` antes de abrir o mundo, para a ficha do menu de pausa | Decisão do time; sessão de jogo sem save global ainda | Aceita |
| ADR-057 | Quest "entregar_carta" começa com a flag `nao_iniciada` no mundo; a opção de aceitar só aparece nesse estado, para não reabrir a quest depois de concluída | Decisão do time (revisão do M3) | Aceita |
| ADR-058 | Escolhas do diálogo recebem o foco do teclado (primeira opção), para setas e Enter funcionarem | Decisão do time (revisão do M3) | Aceita |
| ADR-059 | Grade de combate hexagonal flat-top (topo e base retos, colunas verticais), no lugar da grade quadrada; distância é o número de passos entre hexes, sem diagonal; 1 hex = 1,5 m | Pedido do usuário: hex fica mais parecido com RPG de mesa e miniaturas; quadrado lembra tabuleiro de xadrez. Substitui a parte "grade quadrada" da ADR-034 e a regra de diagonal da ADR-039 (9 m = 6 casas segue) | Aceita |
| ADR-060 | Câmera do combate em 3/4 diagonal fixa, entre a visão de cima e a de lado, sem rotação; o combate segue por turnos; personagens são sprites em pé com escala pela profundidade da linha | Pedido do usuário: referência de Final Fantasy clássico e Baldur's Gate 3; não é visão isométrica de cima | Aceita |
| ADR-061 | Arte separada da regra: a imagem da arena é só visual; terreno, bloqueio, cobertura e altura vêm de dados por hex; cada arena tem um calibrador (origem e transformação de perspectiva) para a grade cair sobre a arte | Decisão do agente; permite gerar arte sem mudar a regra | Aceita |
| ADR-062 | Linha de visão e alcance por linha de hexes; hex bloqueado corta a visão; cobertura meia dá +2 de CA e três quartos dá +5 de CA, como no SRD 5.2 | Decisão do agente; alinhado ao SRD 5.2 | Aceita (valores: padrão) |
| ADR-063 | Arenas: 10 tipos (caverna, estrada, acampamento, taverna, casa abandonada, poço, ruína de igreja, ruína antiga, floresta, beco urbano), 3 variantes cada (30 fundos); variante muda layout e iluminação; primeira leva: estrada, taverna e ruína de igreja; geração no Google Flow com um prompt por tipo | Tipos e variantes: decisão do usuário; ordem da primeira leva: decisão do agente, a confirmar | Aceita (ordem: a confirmar) |
| ADR-064 | Retrato da criação: humanos trocam o retrato pelo sprite da classe (`assets/ui/classes/humano_<classe>_<sexo>.png`, fundo transparente, 480x760, pés alinhados); ao trocar a imagem, a antiga some de cima para baixo com borda de latão e vapor (shader + partículas, 0,7 s); autômatos e mestiços seguem com o sprite da espécie até existirem as versões de classe. Folhas originais em `assets/ui/classes/sheets/humano_<classe>_sheet.png` | Pedido do usuário: trocar a figura ao trocar a classe, com transição visual em vez de corte seco | Aceita |
