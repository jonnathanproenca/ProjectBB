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
