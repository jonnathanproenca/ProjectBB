class_name CharacterCreator
extends Control
## Criação de personagem em etapas, no estilo do Baldur's Gate 3: abas no topo, seletores com setas,
## retrato da espécie no centro e ficha à direita, com blocos de texto sobre painel escuro.
## Overlay sobre a seleção de perfil.
## Emite concluido(escolhas) ou cancelado e se remove sozinho.
## Imagens opcionais em assets/ui/criacao/ (sem arquivo, mostra cor sólida e texto):
##   fundo.png, especie_<id>_<masculino|feminino>.png (corpo inteiro, fundo transparente),
##   icone_<id>_<masculino|feminino>.png (busto com moldura redonda).
## As imagens classe_<id>.png continuam nos assets, mas o retrato não as usa mais.

signal concluido(escolhas: Dictionary)
signal cancelado

const PASTA_IMAGENS := "res://assets/ui/criacao/"
const IMAGEM_FUNDO := "res://assets/ui/criacao/fundo.png"
const COR_FUNDO := Color("16181f")
const COR_SELECIONADO := Color("f2d28a")
const COR_NORMAL := Color.WHITE
const COR_APAGADO := Color(1, 1, 1, 0.45)
const COR_PAINEL := Color(0, 0, 0, 0.72)
const COR_BORDA_PAINEL := Color(0.95, 0.82, 0.54, 0.35)
const COR_TEXTO_CORRIDO := Color("f0e6d2")
const PASSOS: Array[String] = ["origem", "especie", "classe", "background", "habilidades", "pericias", "aparencia"]
const IDENTIDADES: Array[String] = ["masculino", "feminino"]
const APARENCIAS: int = 3
const LARGURA_PAINEL: float = 340.0
const MARGEM_PAINEL: float = 16.0
## Layout fixo (coordenadas de 1280x720): nada cresce nem encolhe ao trocar de classe.
## Altura: abas 60 + 22 + meio 492 + 22 + navegação 52 = 648 px, cabe em 720.
const ALTURA_CONTEUDO: float = 460.0
const LARGURA_ROLAGEM: float = 14.0
const TAMANHO_RETRATO := Vector2(260, 492)
const TAMANHO_ICONE := Vector2(84, 84)
const LARGURA_RESUMO: float = 260.0
const LARGURA_ABAS: float = 972.0
const TAMANHO_BOTAO_NAV := Vector2(200, 52)
## 7 abas: 7 x 132 + 6 x 8 = 972 px, cabe com folga na largura de 1280 (e em 1210 da captura).
const TAMANHO_ABA := Vector2(132, 44)
const ALTURA_LETRA_ABA: float = 22.0

## Escolhas iniciais: o personagem já é válido, como no BG3 (o jogador só troca o que quiser).
## "origem" guarda o Background (nome mantido para não quebrar o salvamento); "personagem" é só de exibição.
var _passo: int = 0
var _escolhas: Dictionary = {"especie": "humano", "identidade": "masculino", "classe": "guerreiro", "origem": "soldado", "aparencia": 0, "personagem": "personalizado"}
var _nome: String = ""
var _raiz: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var cor := ColorRect.new()
	cor.color = COR_FUNDO
	cor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cor)

	var fundo := _textura(IMAGEM_FUNDO)
	if fundo != null:
		fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fundo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(fundo)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	_raiz = VBoxContainer.new()
	_raiz.alignment = BoxContainer.ALIGNMENT_CENTER
	_raiz.add_theme_constant_override("separation", 22)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(_raiz)
	_montar()


## Define o nome do perfil (já validado pela tela de seleção).
func configurar(nome: String) -> void:
	_nome = nome


func _montar() -> void:
	for filho in _raiz.get_children():
		_raiz.remove_child(filho)
		filho.queue_free()
	var painel_abas := _painel_escuro(_montar_abas(), 8.0)
	painel_abas.custom_minimum_size = Vector2(LARGURA_ABAS + 16.0, TAMANHO_ABA.y + 16.0)
	painel_abas.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	painel_abas.clip_contents = true
	_raiz.add_child(painel_abas)

	var meio := HBoxContainer.new()
	meio.alignment = BoxContainer.ALIGNMENT_CENTER
	meio.add_theme_constant_override("separation", 40)
	meio.add_child(_painel_fixo(_montar_painel(), LARGURA_PAINEL))
	meio.add_child(_montar_retrato())
	meio.add_child(_painel_fixo(_montar_resumo(), LARGURA_RESUMO))
	_raiz.add_child(meio)

	_raiz.add_child(_montar_navegacao())


## Abas no topo, como no BG3: a etapa atual fica dourada e as outras podem ser abertas direto.
func _montar_abas() -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 8)
	for i in range(PASSOS.size()):
		var aba := UiKit.botao(UiText.t("passo_" + PASSOS[i]), ALTURA_LETRA_ABA, TAMANHO_ABA)
		aba.modulate = COR_SELECIONADO if i == _passo else COR_NORMAL
		aba.pressed.connect(_ir_para.bind(i))
		linha.add_child(aba)
	return linha


## Painel da esquerda: seletores e textos da etapa atual.
func _montar_painel() -> Control:
	var caixa := VBoxContainer.new()
	caixa.alignment = BoxContainer.ALIGNMENT_CENTER
	caixa.add_theme_constant_override("separation", 14)
	caixa.custom_minimum_size = Vector2(LARGURA_PAINEL - LARGURA_ROLAGEM, 0)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var classe: String = str(_escolhas["classe"])
	var origem: String = str(_escolhas["origem"])
	var largura: float = LARGURA_PAINEL - LARGURA_ROLAGEM
	match PASSOS[_passo]:
		"origem":
			caixa.add_child(_seletor("personagem"))
			caixa.add_child(_paragrafo(UiText.t("personagem_desc_" + str(_escolhas["personagem"]))))
		"especie":
			caixa.add_child(_linha_icones())
			caixa.add_child(_seletor("especie"))
			caixa.add_child(_seletor("identidade"))
			caixa.add_child(UiKit.texto(_resumo_especie(), 18, UiKit.COR_TEXTO_DESTAQUE, largura))
		"classe":
			caixa.add_child(_seletor("classe"))
			caixa.add_child(UiKit.texto(_resumo_classe(), 18, UiKit.COR_TEXTO_DESTAQUE, largura))
			caixa.add_child(_paragrafo(UiText.t("classe_desc_" + classe)))
			caixa.add_child(UiKit.texto(UiText.t("pericias"), 19, UiKit.COR_TEXTO_DESTAQUE, largura))
			caixa.add_child(_paragrafo(_lista_pericias(classe, origem, false)))
		"background":
			caixa.add_child(_seletor("origem"))
			caixa.add_child(_paragrafo(UiText.t("background_desc_" + origem)))
		"habilidades":
			caixa.add_child(_paragrafo(UiText.t("habilidades_desc")))
			var finais := CharacterRules.atributos_finais(str(_escolhas["especie"]), classe)
			for atributo in CharacterRules.ATRIBUTOS:
				var valor: int = int(finais[atributo])
				caixa.add_child(UiKit.linha_atributo(UiText.t("attr_" + str(atributo)), valor, DndRules.ability_modifier(valor), 19))
		"pericias":
			caixa.add_child(_paragrafo(UiText.t("pericias_desc")))
			caixa.add_child(_paragrafo(_lista_pericias(classe, origem, true)))
		_:
			caixa.add_child(_seletor("aparencia"))
	return caixa


## Retrato do centro: sempre a imagem da espécie (corpo inteiro, fundo transparente), em todas as etapas.
func _montar_retrato() -> Control:
	var quadro := Control.new()
	quadro.custom_minimum_size = TAMANHO_RETRATO
	quadro.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	quadro.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	quadro.clip_contents = true
	quadro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var imagem := _textura(_caminho_especie())
	if imagem != null:
		imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		imagem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		quadro.add_child(imagem)
	return quadro


## Ficha à direita, no estilo do BG3: nome, espécie, classe, background, atributos, PV e perícias.
## Reconstruída a cada escolha.
func _montar_resumo() -> Control:
	var caixa := VBoxContainer.new()
	caixa.alignment = BoxContainer.ALIGNMENT_CENTER
	caixa.add_theme_constant_override("separation", 4)
	caixa.custom_minimum_size = Vector2(LARGURA_RESUMO - LARGURA_ROLAGEM, 0)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var largura: float = LARGURA_RESUMO - LARGURA_ROLAGEM
	var especie: String = str(_escolhas["especie"])
	var classe: String = str(_escolhas["classe"])
	var origem: String = str(_escolhas["origem"])
	var finais := CharacterRules.atributos_finais(especie, classe)

	# Título em letras pixel; detalhes em texto corrido (fonte padrão do Godot).
	if not _nome.is_empty():
		caixa.add_child(UiKit.letras(_nome, 28.0, largura))
	caixa.add_child(UiKit.letras(UiText.t("especie_" + especie), 22.0, largura))
	caixa.add_child(UiKit.letras(UiText.t("classe_" + classe), 22.0, largura))
	caixa.add_child(UiKit.letras(UiText.t("origem_" + origem), 22.0, largura))
	caixa.add_child(_espaco(6.0))
	for atributo in CharacterRules.ATRIBUTOS:
		var valor: int = int(finais[atributo])
		caixa.add_child(UiKit.linha_atributo(UiText.t("attr_" + str(atributo)), valor, DndRules.ability_modifier(valor), 17))
	caixa.add_child(_espaco(6.0))
	var pv := CharacterRules.pv_nivel_1(classe, int(finais["con"]))
	caixa.add_child(UiKit.texto("%s: %d" % [UiText.t("pv"), pv], 18, UiKit.COR_TEXTO, largura))
	caixa.add_child(_espaco(6.0))
	caixa.add_child(UiKit.texto(UiText.t("pericias"), 18, UiKit.COR_TEXTO_DESTAQUE, largura))
	for pericia in CharacterRules.pericias_finais(classe, origem):
		caixa.add_child(UiKit.texto(_nome_pericia(str(pericia)), 16, UiKit.COR_TEXTO, largura))
	return caixa


func _montar_navegacao() -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 40)
	var voltar := UiKit.botao(UiText.t("cancelar") if _passo == 0 else UiText.t("voltar"), 26.0, TAMANHO_BOTAO_NAV)
	voltar.pressed.connect(_voltar)
	linha.add_child(voltar)
	var ultimo := _passo == PASSOS.size() - 1
	var avancar := UiKit.botao(UiText.t("concluir") if ultimo else UiText.t("avancar"), 26.0, TAMANHO_BOTAO_NAV)
	avancar.pressed.connect(_avancar)
	linha.add_child(avancar)
	return linha


## Seletor no estilo BG3: seta, nome da opção e seta. Dá a volta nas pontas.
func _seletor(chave: String) -> Control:
	var opcoes: Array = _opcoes(chave)
	var atual := maxi(opcoes.find(_escolhas[chave]), 0)
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 14)
	var esquerda := UiKit.seta(true, 34.0)
	esquerda.pressed.connect(_girar.bind(chave, -1))
	linha.add_child(esquerda)
	linha.add_child(UiKit.letras(_rotulo(chave, opcoes[atual]), 30.0, LARGURA_PAINEL - LARGURA_ROLAGEM - 110.0))
	var direita := UiKit.seta(false, 34.0)
	direita.pressed.connect(_girar.bind(chave, 1))
	linha.add_child(direita)
	return linha


## Linha de ícones das espécies (um por raça). Sem arquivo, mostra o nome curto.
func _linha_icones() -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 18)
	for especie in _opcoes("especie"):
		var icone := Button.new()
		icone.flat = true
		icone.custom_minimum_size = TAMANHO_ICONE
		icone.tooltip_text = UiText.t("especie_" + str(especie))
		var textura := _carregar("%sicone_%s_%s.png" % [PASTA_IMAGENS, especie, _escolhas["identidade"]])
		if textura != null:
			icone.icon = textura
			icone.expand_icon = true
		else:
			icone.text = UiText.t("especie_" + str(especie)).substr(0, 3)
		icone.modulate = COR_SELECIONADO if especie == _escolhas["especie"] else COR_APAGADO
		icone.pressed.connect(_escolher.bind("especie", especie))
		linha.add_child(icone)
	return linha


func _girar(chave: String, passo: int) -> void:
	var opcoes: Array = _opcoes(chave)
	var atual := maxi(opcoes.find(_escolhas[chave]), 0)
	_escolhas[chave] = opcoes[posmod(atual + passo, opcoes.size())]
	_montar()


func _escolher(chave: String, valor: Variant) -> void:
	_escolhas[chave] = valor
	_montar()


func _ir_para(indice: int) -> void:
	_passo = indice
	_montar()


func _avancar() -> void:
	if _passo == PASSOS.size() - 1:
		var escolhas := _escolhas.duplicate()
		escolhas["nome"] = _nome
		concluido.emit(escolhas)
		queue_free()
		return
	_passo += 1
	_montar()


func _voltar() -> void:
	if _passo == 0:
		cancelado.emit()
		queue_free()
		return
	_passo -= 1
	_montar()


func _opcoes(chave: String) -> Array:
	match chave:
		"especie":
			return CharacterRules.ESPECIES.keys()
		"identidade":
			return IDENTIDADES.duplicate()
		"classe":
			return CharacterRules.CLASSES.keys()
		"origem":
			return CharacterRules.ORIGENS.keys()
		"personagem":
			return _chaves(CharacterRules.PERSONAGENS)
		_:
			var presets: Array = []
			for i in range(APARENCIAS):
				presets.append(i)
			return presets


## Texto do seletor: "<prefixo>_<valor>" nos textos da interface.
func _rotulo(chave: String, valor: Variant) -> String:
	return UiText.t(chave + "_" + str(valor))


## Resumo de bônus da espécie escolhida (ex.: "CON +1  CAR +1").
func _resumo_especie() -> String:
	var especie: String = str(_escolhas["especie"])
	var bonus: Dictionary = (CharacterRules.ESPECIES[especie] as Dictionary)["bonus"]
	var partes := PackedStringArray()
	for atributo in CharacterRules.ATRIBUTOS:
		if bonus.has(atributo):
			partes.append("%s +%d" % [UiText.t("attr_" + atributo), int(bonus[atributo])])
	return "  ".join(partes)


## Dado de vida e PV no nível 1 da classe escolhida (muda ao trocar de classe).
func _resumo_classe() -> String:
	var classe: String = str(_escolhas["classe"])
	var dado: int = int((CharacterRules.CLASSES[classe] as Dictionary)["dado_vida"])
	var finais := CharacterRules.atributos_finais(str(_escolhas["especie"]), classe)
	var pv := CharacterRules.pv_nivel_1(classe, int(finais["con"]))
	return "%s: d%d   %s: %d" % [UiText.t("dado_vida"), dado, UiText.t("pv_nivel_1"), pv]


## Aceita Dictionary (usa as chaves) ou Array.
func _chaves(fonte: Variant) -> Array:
	if fonte is Dictionary:
		return (fonte as Dictionary).keys()
	return (fonte as Array).duplicate()


## Nome da perícia na interface; sem tradução, cai no id com a primeira letra maiúscula.
func _nome_pericia(id: String) -> String:
	var chave := "pericia_" + id
	var texto := UiText.t(chave)
	return id.capitalize() if texto == chave else texto


## Perícias finais, uma por linha. Com atributo, no formato "Atletismo (FOR)".
func _lista_pericias(classe: String, origem: String, com_atributo: bool) -> String:
	var linhas := PackedStringArray()
	for pericia in CharacterRules.pericias_finais(classe, origem):
		var linha := _nome_pericia(str(pericia))
		if com_atributo:
			var atributo: String = str((CharacterRules.PERICIAS[pericia] as Dictionary)["atributo"])
			linha += " (%s)" % UiText.t("attr_" + atributo)
		linhas.append(linha)
	return "\n".join(linhas)


## Painel escuro de tamanho fixo (largura x ALTURA_CONTEUDO) com rolagem vertical: se o texto passar da altura,
## rola dentro do painel e nunca empurra os outros elementos.
func _painel_fixo(conteudo: Control, largura: float) -> PanelContainer:
	conteudo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rolagem := ScrollContainer.new()
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	rolagem.custom_minimum_size = Vector2(largura, ALTURA_CONTEUDO)
	rolagem.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	rolagem.mouse_filter = Control.MOUSE_FILTER_PASS
	rolagem.add_child(conteudo)
	var painel := _painel_escuro(rolagem, MARGEM_PAINEL)
	painel.custom_minimum_size = Vector2(largura + 2.0 * MARGEM_PAINEL, ALTURA_CONTEUDO + 2.0 * MARGEM_PAINEL)
	painel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	painel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	painel.clip_contents = true
	return painel


## Painel escuro estilo BG3 (preto com alfa, cantos redondos e borda dourada discreta) atrás do conteúdo.
func _painel_escuro(conteudo: Control, margem: float) -> PanelContainer:
	var painel := PanelContainer.new()
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = COR_PAINEL
	estilo.set_corner_radius_all(10)
	estilo.set_border_width_all(2)
	estilo.border_color = COR_BORDA_PAINEL
	estilo.set_content_margin_all(margem)
	painel.add_theme_stylebox_override("panel", estilo)
	painel.add_child(conteudo)
	return painel


## Texto corrido com quebra de linha (as letras recortadas não quebram), claro sobre o painel escuro.
func _paragrafo(texto: String) -> Label:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.custom_minimum_size = Vector2(LARGURA_PAINEL - LARGURA_ROLAGEM, 0)
	rotulo.add_theme_font_size_override("font_size", 18)
	rotulo.add_theme_color_override("font_color", COR_TEXTO_CORRIDO)
	rotulo.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	rotulo.add_theme_constant_override("outline_size", 2)
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rotulo


func _espaco(altura: float) -> Control:
	var vazio := Control.new()
	vazio.custom_minimum_size = Vector2(0, altura)
	return vazio


func _caminho_especie() -> String:
	return "%sespecie_%s_%s.png" % [PASTA_IMAGENS, _escolhas["especie"], _escolhas["identidade"]]


func _carregar(caminho: String) -> Texture2D:
	return load(caminho) as Texture2D if ResourceLoader.exists(caminho) else null


func _textura(caminho: String) -> TextureRect:
	var imagem := _carregar(caminho)
	if imagem == null:
		return null
	var tr := TextureRect.new()
	tr.texture = imagem
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr
