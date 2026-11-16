class_name CharacterCreator
extends Control
## Criação de personagem em etapas: espécie, classe, origem, aparência e revisão.
## Overlay sobre a seleção de perfil. Emite concluido(escolhas) ou cancelado e se remove sozinho.
## Imagens opcionais em assets/ui/criacao/ (fundo.png, especie_<id>.png, classe_<id>.png): sem arquivo, usa cor sólida.

signal concluido(escolhas: Dictionary)
signal cancelado

const PASTA_IMAGENS := "res://assets/ui/criacao/"
const IMAGEM_FUNDO := "res://assets/ui/criacao/fundo.png"
const COR_FUNDO := Color("16181f")
const COR_SELECIONADO := Color("f2d28a")
const COR_NORMAL := Color.WHITE
const LARGURA_OPCAO: float = 300.0
const ALTURA_OPCAO: float = 52.0
const TAMANHO_QUADRO := Vector2(200, 260)
const LARGURA_TEXTO: float = 420.0
const PASSOS: Array[String] = ["especie", "classe", "origem", "aparencia", "revisao"]
const APARENCIAS: int = 3

## Escolhas do jogador. "aparencia" fica em -1 até escolher um preset.
var _nome: String = ""
var _passo: int = 0
var _escolhas: Dictionary = {"especie": "", "classe": "", "origem": "", "aparencia": -1}
var _conteudo: VBoxContainer


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

	_conteudo = VBoxContainer.new()
	_conteudo.alignment = BoxContainer.ALIGNMENT_CENTER
	_conteudo.add_theme_constant_override("separation", 18)
	_conteudo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(_conteudo)
	_montar_passo()


## Define o nome do perfil (já validado pela tela de seleção) e mostra a primeira etapa.
func configurar(nome: String) -> void:
	_nome = nome


func _montar_passo() -> void:
	for filho in _conteudo.get_children():
		_conteudo.remove_child(filho)
		filho.queue_free()

	var chave: String = PASSOS[_passo]
	_conteudo.add_child(UiKit.letras(UiText.t("passo_" + chave), 40.0, LARGURA_TEXTO))
	_conteudo.add_child(UiKit.letras("%d / %d" % [_passo + 1, PASSOS.size()], 22.0))
	if chave == "revisao":
		_conteudo.add_child(_montar_revisao())
	else:
		_conteudo.add_child(_montar_escolha(chave))
	_conteudo.add_child(_montar_navegacao())


## Etapa de escolha: quadro com a imagem da opção selecionada, lista de opções e resumo.
func _montar_escolha(chave: String) -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 40)

	var selecionado: String = str(_escolhas.get(chave, ""))
	var quadro := Control.new()
	quadro.custom_minimum_size = TAMANHO_QUADRO
	quadro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if selecionado != "" and _caminho_imagem(chave, selecionado) != "":
		var imagem := _textura(_caminho_imagem(chave, selecionado))
		if imagem != null:
			imagem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			quadro.add_child(imagem)
	linha.add_child(quadro)

	var lista := VBoxContainer.new()
	lista.add_theme_constant_override("separation", 10)
	lista.alignment = BoxContainer.ALIGNMENT_CENTER
	for valor in _opcoes(chave):
		var b := UiKit.botao(_rotulo(chave, valor), 26.0, Vector2(LARGURA_OPCAO, ALTURA_OPCAO))
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		b.modulate = COR_SELECIONADO if _eh_selecionado(chave, valor) else COR_NORMAL
		b.pressed.connect(_escolher.bind(chave, valor))
		lista.add_child(b)
	var resumo := _resumo_opcao(chave, selecionado)
	if resumo != "":
		lista.add_child(UiKit.letras(resumo, 20.0, LARGURA_OPCAO))
	linha.add_child(lista)
	return linha


## Revisão: nome, escolhas, atributos finais e pontos de vida no nível 1.
func _montar_revisao() -> Control:
	var caixa := VBoxContainer.new()
	caixa.alignment = BoxContainer.ALIGNMENT_CENTER
	caixa.add_theme_constant_override("separation", 10)
	var especie: String = str(_escolhas["especie"])
	var classe: String = str(_escolhas["classe"])
	var finais := CharacterRules.atributos_finais(especie, classe)

	caixa.add_child(UiKit.letras(_nome, 34.0, LARGURA_TEXTO))
	caixa.add_child(UiKit.letras("%s: %s" % [UiText.t("raca"), UiText.t("especie_" + especie)], 22.0, LARGURA_TEXTO))
	caixa.add_child(UiKit.letras("%s: %s" % [UiText.t("classe"), UiText.t("classe_" + classe)], 22.0, LARGURA_TEXTO))
	caixa.add_child(UiKit.letras("%s: %s" % [UiText.t("origem"), UiText.t("origem_" + str(_escolhas["origem"]))], 22.0, LARGURA_TEXTO))
	var atributos := PackedStringArray()
	for atributo in CharacterRules.ATRIBUTOS:
		atributos.append("%s %d" % [UiText.t("attr_" + atributo), int(finais[atributo])])
	caixa.add_child(UiKit.letras("  ".join(atributos), 22.0, LARGURA_TEXTO))
	var pv := CharacterRules.pv_nivel_1(classe, int(finais["con"]))
	caixa.add_child(UiKit.letras("%s: %d" % [UiText.t("pv"), pv], 22.0, LARGURA_TEXTO))
	return caixa


func _montar_navegacao() -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 40)

	var voltar := UiKit.botao(UiText.t("cancelar") if _passo == 0 else UiText.t("voltar"), 26.0, Vector2(200, 52))
	voltar.pressed.connect(_voltar)
	linha.add_child(voltar)

	var ultimo := _passo == PASSOS.size() - 1
	var avancar := UiKit.botao(UiText.t("concluir") if ultimo else UiText.t("avancar"), 26.0, Vector2(200, 52))
	var completo := _passo_completo()
	avancar.disabled = not completo
	avancar.modulate = COR_NORMAL if completo else Color(1, 1, 1, 0.35)
	avancar.pressed.connect(_avancar)
	linha.add_child(avancar)
	return linha


func _escolher(chave: String, valor: Variant) -> void:
	_escolhas[chave] = valor
	_montar_passo()


func _avancar() -> void:
	if _passo == PASSOS.size() - 1:
		concluido.emit(_escolhas.duplicate())
		queue_free()
		return
	_passo += 1
	_montar_passo()


func _voltar() -> void:
	if _passo == 0:
		cancelado.emit()
		queue_free()
		return
	_passo -= 1
	_montar_passo()


func _passo_completo() -> bool:
	var chave: String = PASSOS[_passo]
	if chave == "revisao":
		return true
	if chave == "aparencia":
		return int(_escolhas["aparencia"]) >= 0
	return str(_escolhas[chave]) != ""


func _opcoes(chave: String) -> Array:
	match chave:
		"especie":
			return CharacterRules.ESPECIES.keys()
		"classe":
			return CharacterRules.CLASSES.keys()
		"origem":
			return CharacterRules.ORIGENS.keys()
		_:
			var presets: Array = []
			for i in range(APARENCIAS):
				presets.append(i)
			return presets


func _eh_selecionado(chave: String, valor: Variant) -> bool:
	return _escolhas[chave] == valor


func _rotulo(chave: String, valor: Variant) -> String:
	if chave == "aparencia":
		return UiText.t("aparencia_%d" % int(valor))
	return UiText.t(_prefixo(chave) + "_" + str(valor))


func _prefixo(chave: String) -> String:
	match chave:
		"especie":
			return "especie"
		"classe":
			return "classe"
		_:
			return "origem"


## Texto de apoio da opção escolhida: bônus da espécie ou dado de vida da classe.
func _resumo_opcao(chave: String, valor: String) -> String:
	if valor == "":
		return ""
	if chave == "especie":
		var partes := PackedStringArray()
		var bonus: Dictionary = (CharacterRules.ESPECIES[valor] as Dictionary)["bonus"]
		for atributo in CharacterRules.ATRIBUTOS:
			if bonus.has(atributo):
				partes.append("%s +%d" % [UiText.t("attr_" + atributo), int(bonus[atributo])])
		return "  ".join(partes)
	if chave == "classe":
		var dado: int = int((CharacterRules.CLASSES[valor] as Dictionary)["dado_vida"])
		return "%s: d%d" % [UiText.t("dado_vida"), dado]
	return ""


## Imagem da opção, se existir em assets/ui/criacao/. Vazio quando não há arquivo.
func _caminho_imagem(chave: String, valor: String) -> String:
	if chave != "especie" and chave != "classe":
		return ""
	var caminho := "%s%s_%s.png" % [PASTA_IMAGENS, chave, valor]
	return caminho if ResourceLoader.exists(caminho) else ""


func _textura(caminho: String) -> TextureRect:
	if not ResourceLoader.exists(caminho):
		return null
	var tr := TextureRect.new()
	tr.texture = load(caminho)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr
