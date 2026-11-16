class_name CharacterCreator
extends Control
## Criação de personagem em etapas, no estilo do Baldur's Gate 3: abas no topo, seletores com setas,
## retrato no centro, resumo à direita. Overlay sobre a seleção de perfil.
## Emite concluido(escolhas) ou cancelado e se remove sozinho.
## Imagens opcionais em assets/ui/criacao/ (sem arquivo, mostra cor sólida e texto):
##   fundo.png, especie_<id>_<masculino|feminino>.png, icone_<id>.png, classe_<id>.png

signal concluido(escolhas: Dictionary)
signal cancelado

const PASTA_IMAGENS := "res://assets/ui/criacao/"
const IMAGEM_FUNDO := "res://assets/ui/criacao/fundo.png"
const COR_FUNDO := Color("16181f")
const COR_SELECIONADO := Color("f2d28a")
const COR_NORMAL := Color.WHITE
const COR_APAGADO := Color(1, 1, 1, 0.45)
const PASSOS: Array[String] = ["especie", "classe", "origem", "aparencia", "revisao"]
const IDENTIDADES: Array[String] = ["masculino", "feminino"]
const APARENCIAS: int = 3
const LARGURA_PAINEL: float = 340.0
const TAMANHO_RETRATO := Vector2(260, 360)
const TAMANHO_ICONE := Vector2(64, 64)
const LARGURA_RESUMO: float = 260.0
const TAMANHO_BOTAO_NAV := Vector2(200, 52)
const TAMANHO_ABA := Vector2(170, 44)

## Escolhas iniciais: o personagem já é válido, como no BG3 (o jogador só troca o que quiser).
var _passo: int = 0
var _escolhas: Dictionary = {"especie": "humano", "identidade": "masculino", "classe": "guerreiro", "origem": "soldado", "aparencia": 0}
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
	_raiz.add_child(_montar_abas())

	var meio := HBoxContainer.new()
	meio.alignment = BoxContainer.ALIGNMENT_CENTER
	meio.add_theme_constant_override("separation", 40)
	meio.add_child(_montar_painel())
	meio.add_child(_montar_retrato())
	meio.add_child(_montar_resumo())
	_raiz.add_child(meio)

	_raiz.add_child(_montar_navegacao())


## Abas no topo, como no BG3: a etapa atual fica dourada e as outras podem ser abertas direto.
func _montar_abas() -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 24)
	for i in range(PASSOS.size()):
		var aba := UiKit.botao(UiText.t("passo_" + PASSOS[i]), 26.0, TAMANHO_ABA)
		aba.modulate = COR_SELECIONADO if i == _passo else COR_NORMAL
		aba.pressed.connect(_ir_para.bind(i))
		linha.add_child(aba)
	return linha


## Painel da esquerda: seletores da etapa atual.
func _montar_painel() -> Control:
	var caixa := VBoxContainer.new()
	caixa.alignment = BoxContainer.ALIGNMENT_CENTER
	caixa.add_theme_constant_override("separation", 18)
	caixa.custom_minimum_size = Vector2(LARGURA_PAINEL, 0)
	match PASSOS[_passo]:
		"especie":
			caixa.add_child(_linha_icones())
			caixa.add_child(_seletor("especie"))
			caixa.add_child(_seletor("identidade"))
			caixa.add_child(UiKit.letras(_resumo_especie(), 20.0, LARGURA_PAINEL))
		"classe":
			caixa.add_child(_seletor("classe"))
			caixa.add_child(UiKit.letras(_resumo_classe(), 22.0, LARGURA_PAINEL))
		"origem":
			caixa.add_child(_seletor("origem"))
		"aparencia":
			caixa.add_child(_seletor("aparencia"))
		_:
			caixa.add_child(UiKit.letras(_nome, 36.0, LARGURA_PAINEL))
	return caixa


## Retrato do centro: sempre a espécie (masculino ou feminino); na etapa de classe, a classe.
func _montar_retrato() -> Control:
	var quadro := Control.new()
	quadro.custom_minimum_size = TAMANHO_RETRATO
	quadro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caminho := _caminho_classe() if PASSOS[_passo] == "classe" else _caminho_especie()
	var imagem := _textura(caminho)
	if imagem != null:
		# Preenche o quadro alto e corta as laterais (as imagens do Flow vêm em 16:9).
		imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		imagem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		quadro.add_child(imagem)
	return quadro


## Resumo à direita: atributos finais e PV, atualizados a cada escolha.
func _montar_resumo() -> Control:
	var caixa := VBoxContainer.new()
	caixa.alignment = BoxContainer.ALIGNMENT_CENTER
	caixa.add_theme_constant_override("separation", 6)
	caixa.custom_minimum_size = Vector2(LARGURA_RESUMO, 0)
	var especie: String = str(_escolhas["especie"])
	var classe: String = str(_escolhas["classe"])
	var finais := CharacterRules.atributos_finais(especie, classe)

	caixa.add_child(UiKit.letras(UiText.t("especie_" + especie), 28.0, LARGURA_RESUMO))
	caixa.add_child(UiKit.letras(UiText.t("classe_" + classe), 24.0, LARGURA_RESUMO))
	caixa.add_child(UiKit.letras(UiText.t("origem_" + str(_escolhas["origem"])), 24.0, LARGURA_RESUMO))
	caixa.add_child(_espaco(12.0))
	for atributo in CharacterRules.ATRIBUTOS:
		var linha := HBoxContainer.new()
		linha.add_child(UiKit.letras(UiText.t("attr_" + atributo), 22.0, 90.0))
		linha.add_child(UiKit.letras(str(int(finais[atributo])), 22.0, 60.0))
		caixa.add_child(linha)
	caixa.add_child(_espaco(12.0))
	var pv := CharacterRules.pv_nivel_1(classe, int(finais["con"]))
	caixa.add_child(UiKit.letras("%s: %d" % [UiText.t("pv"), pv], 24.0, LARGURA_RESUMO))
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
	linha.add_child(UiKit.letras(_rotulo(chave, opcoes[atual]), 30.0, LARGURA_PAINEL - 110.0))
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
		var textura := _carregar("%sicone_%s.png" % [PASTA_IMAGENS, especie])
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


func _resumo_classe() -> String:
	var dado: int = int((CharacterRules.CLASSES[str(_escolhas["classe"])] as Dictionary)["dado_vida"])
	return "%s: d%d" % [UiText.t("dado_vida"), dado]


func _espaco(altura: float) -> Control:
	var vazio := Control.new()
	vazio.custom_minimum_size = Vector2(0, altura)
	return vazio


func _caminho_especie() -> String:
	return "%sespecie_%s_%s.png" % [PASTA_IMAGENS, _escolhas["especie"], _escolhas["identidade"]]


func _caminho_classe() -> String:
	return "%sclasse_%s.png" % [PASTA_IMAGENS, _escolhas["classe"]]


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
