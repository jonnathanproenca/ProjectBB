class_name FichaPersonagem
extends Control
## Ficha do personagem, no estilo da tela de resumo do Baldur's Gate 3: espécie em corpo inteiro
## à esquerda e, à direita, um painel escuro com nome, espécie, classe, origem, atributos, PV e perícias.
## Overlay sobre a tela atual; lê só o perfil salvo (race, class, origin, identity, appearance, name)
## e se remove sozinho ao voltar. Imagem opcional (sem arquivo, mostra cor sólida):
##   assets/ui/criacao/especie_<especie>_<identidade>.png

const PASTA_IMAGENS := "res://assets/ui/criacao/"
const IMAGEM_FUNDO := "res://assets/ui/criacao/fundo.png"
const COR_FUNDO := Color("16181f")
const COR_RETRATO := Color("4a2416")
const COR_PAINEL := Color(0, 0, 0, 0.72)
const RAIO_PAINEL: int = 14
const MARGEM_PAINEL: int = 22
const TAMANHO_RETRATO := Vector2(300, 520)
const LARGURA_PAINEL: float = 460.0
const TAMANHO_BOTAO := Vector2(200, 52)

var _perfil: Dictionary = {}


## Perfil com criação completa: espécie, classe e origem existem nas regras do MVP.
## Usado também pelas telas que decidem se mostram o botão "Ficha".
static func perfil_completo(perfil: Variant) -> bool:
	if not perfil is Dictionary:
		return false
	var dados: Dictionary = perfil
	if str(dados.get("race", "")).is_empty():
		return false
	return CharacterRules.validar(str(dados.get("race", "")), str(dados.get("origin", "")), str(dados.get("class", ""))) == CharacterRules.ERR_NONE


## Define o perfil mostrado. Chamar antes de add_child.
func configurar(perfil: Dictionary) -> void:
	_perfil = perfil


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

	var raiz := VBoxContainer.new()
	raiz.alignment = BoxContainer.ALIGNMENT_CENTER
	raiz.add_theme_constant_override("separation", 18)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(raiz)

	if not perfil_completo(_perfil):
		# Não deveria acontecer (a entrada só aparece com criação completa); sai sem quebrar.
		raiz.add_child(UiKit.letras(UiText.t("nao_definido"), 30.0, LARGURA_PAINEL))
	else:
		var meio := HBoxContainer.new()
		meio.alignment = BoxContainer.ALIGNMENT_CENTER
		meio.add_theme_constant_override("separation", 36)
		meio.mouse_filter = Control.MOUSE_FILTER_IGNORE
		meio.add_child(_montar_retrato())
		meio.add_child(_montar_painel())
		raiz.add_child(meio)

	var voltar := UiKit.botao(UiText.t("voltar"), 26.0, TAMANHO_BOTAO)
	voltar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	voltar.pressed.connect(queue_free)
	raiz.add_child(voltar)


## Espécie em corpo inteiro, sobre cor sólida (a imagem tem fundo transparente).
func _montar_retrato() -> Control:
	var quadro := Control.new()
	quadro.custom_minimum_size = TAMANHO_RETRATO
	quadro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caminho := "%sespecie_%s_%s.png" % [PASTA_IMAGENS, str(_perfil["race"]), str(_perfil.get("identity", ""))]
	var imagem := _textura(caminho)
	if imagem == null:
		var cor := ColorRect.new()
		cor.color = COR_RETRATO
		cor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cor.mouse_filter = Control.MOUSE_FILTER_IGNORE
		quadro.add_child(cor)
	else:
		imagem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		quadro.add_child(imagem)
	return quadro


## Painel escuro (preto com alfa) para o texto ficar legível sobre qualquer fundo.
func _montar_painel() -> Control:
	var painel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = COR_PAINEL
	estilo.set_corner_radius_all(RAIO_PAINEL)
	estilo.set_content_margin_all(MARGEM_PAINEL)
	painel.add_theme_stylebox_override("panel", estilo)
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var especie: String = str(_perfil["race"])
	var classe: String = str(_perfil["class"])
	var origem: String = str(_perfil["origin"])
	var finais := CharacterRules.atributos_finais(especie, classe)

	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 6)
	caixa.custom_minimum_size = Vector2(LARGURA_PAINEL, 0)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_child(caixa)

	caixa.add_child(UiKit.titulo(str(_perfil.get("name", "")), 34, LARGURA_PAINEL))
	caixa.add_child(UiKit.titulo("%s  %s" % [UiText.t("especie_" + especie), UiText.t("classe_" + classe)], 24, LARGURA_PAINEL))
	caixa.add_child(UiKit.titulo(UiText.t("origem_" + origem), 22, LARGURA_PAINEL))
	caixa.add_child(UiKit.texto("%s %d" % [UiText.t("aparencia"), int(_perfil.get("appearance", 0)) + 1], 17, UiKit.COR_TEXTO, LARGURA_PAINEL))
	caixa.add_child(_espaco(8.0))

	caixa.add_child(UiKit.texto(UiText.t("atributos"), 19, UiKit.COR_TEXTO_DESTAQUE, LARGURA_PAINEL))
	for atributo in CharacterRules.ATRIBUTOS:
		var valor: int = int(finais[atributo])
		caixa.add_child(UiKit.linha_atributo(UiText.t("attr_" + atributo), valor, DndRules.ability_modifier(valor), 18))
	caixa.add_child(_espaco(8.0))

	var pv := CharacterRules.pv_nivel_1(classe, int(finais["con"]))
	caixa.add_child(UiKit.texto("%s (%s 1): %d" % [UiText.t("pv"), UiText.t("nivel"), pv], 18, UiKit.COR_TEXTO, LARGURA_PAINEL))
	caixa.add_child(_espaco(8.0))

	caixa.add_child(UiKit.texto(UiText.t("pericias"), 19, UiKit.COR_TEXTO_DESTAQUE, LARGURA_PAINEL))
	for pericia in CharacterRules.pericias_finais(classe, origem):
		caixa.add_child(UiKit.texto(_texto_pericia(str(pericia)), 17, UiKit.COR_TEXTO, LARGURA_PAINEL))
	return painel


## "Atletismo  FOR": nome da perícia e atributo dela. Sem texto traduzido, cai no id.
func _texto_pericia(id: String) -> String:
	var chave := "pericia_" + id
	var nome := UiText.t(chave)
	if nome == chave:
		nome = id.replace("_", " ").capitalize()
	var dados: Dictionary = CharacterRules.PERICIAS.get(id, {})
	var atributo: String = str(dados.get("atributo", ""))
	if atributo.is_empty():
		return nome
	return "%s  %s" % [nome, UiText.t("attr_" + atributo)]


func _espaco(altura: float) -> Control:
	var vazio := Control.new()
	vazio.custom_minimum_size = Vector2(0, altura)
	vazio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return vazio


func _textura(caminho: String) -> TextureRect:
	if not ResourceLoader.exists(caminho):
		return null
	var tr := TextureRect.new()
	tr.texture = load(caminho) as Texture2D
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr
