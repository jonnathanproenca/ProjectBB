class_name GrupoLista
extends Control
## Lista dos personagens jogáveis do grupo. Hoje o grupo são os perfis com criação completa
## (ainda não há definição de party além de GameConfig.PARTY_MAX_SIZE). Cada linha mostra nome,
## espécie, classe, nível, PV (nível 1) e o botão Ficha. Overlay que se remove ao voltar.

const COR_FUNDO := Color("16181f")
const COR_PAINEL := Color(0, 0, 0, 0.72)
const RAIO_PAINEL: int = 14
const MARGEM_PAINEL: int = 22
const LARGURA_PAINEL: float = 900.0
const TAMANHO_BOTAO := Vector2(200, 52)
const TAMANHO_BOTAO_FICHA := Vector2(140, 44)

var _slots: Array = []


## Recebe os slots como vêm de ProfileStore.load_slots. Chamar antes de add_child.
func configurar(slots: Array) -> void:
	_slots = slots


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var cor := ColorRect.new()
	cor.color = COR_FUNDO
	cor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cor)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	var raiz := VBoxContainer.new()
	raiz.alignment = BoxContainer.ALIGNMENT_CENTER
	raiz.add_theme_constant_override("separation", 18)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(raiz)

	raiz.add_child(UiKit.letras(UiText.t("grupo"), 40.0, LARGURA_PAINEL))
	raiz.add_child(_montar_painel())

	var voltar := UiKit.botao(UiText.t("voltar"), 26.0, TAMANHO_BOTAO)
	voltar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	voltar.pressed.connect(queue_free)
	raiz.add_child(voltar)


func _montar_painel() -> Control:
	var painel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = COR_PAINEL
	estilo.set_corner_radius_all(RAIO_PAINEL)
	estilo.set_content_margin_all(MARGEM_PAINEL)
	painel.add_theme_stylebox_override("panel", estilo)
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 10)
	caixa.custom_minimum_size = Vector2(LARGURA_PAINEL, 0)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_child(caixa)

	var membros := 0
	for perfil in _slots:
		if not FichaPersonagem.perfil_completo(perfil):
			continue
		if membros >= GameConfig.PARTY_MAX_SIZE:
			break
		membros += 1
		caixa.add_child(_linha(perfil as Dictionary))
	if membros == 0:
		caixa.add_child(UiKit.letras(UiText.t("grupo_vazio"), 26.0, LARGURA_PAINEL))
	return painel


func _linha(perfil: Dictionary) -> Control:
	var especie: String = str(perfil["race"])
	var classe: String = str(perfil["class"])
	var finais := CharacterRules.atributos_finais(especie, classe)
	var pv := CharacterRules.pv_nivel_1(classe, int(finais["con"]))
	var nivel := ProfileRules.level_for_profile(perfil, GameConfig.MAX_LEVEL)

	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 14)
	linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	linha.add_child(UiKit.letras(str(perfil["name"]), 26.0, 220.0))
	linha.add_child(UiKit.letras(UiText.t("especie_" + especie), 22.0, 150.0))
	linha.add_child(UiKit.letras(UiText.t("classe_" + classe), 22.0, 190.0))
	linha.add_child(UiKit.letras("%s %d" % [UiText.t("nivel"), nivel], 22.0, 90.0))
	linha.add_child(UiKit.letras("%s %d" % [UiText.t("pv"), pv], 22.0, 80.0))
	var ficha := UiKit.botao(UiText.t("ficha"), 24.0, TAMANHO_BOTAO_FICHA)
	ficha.pressed.connect(func() -> void:
		var tela := FichaPersonagem.new()
		tela.configurar(perfil)
		add_child(tela))
	linha.add_child(ficha)
	return linha
