extends Control
## Seleção de perfil após Entrar. Até GameConfig.PROFILE_SLOTS_MAX perfis.
## Nesta etapa a criação pede só o nome; raça e classe ficam "não definido".

const LOGIN_SCENE := "res://scenes/login.tscn"
const SLOT_SIZE := Vector2(260, 320)

var _slots: Array = []
var _creating_slot: int = -1
var _titulo: Label
var _grade: HBoxContainer
var _voltar: Button


func _ready() -> void:
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 24)
	centro.add_child(caixa)

	_titulo = _label("", 32)
	caixa.add_child(_titulo)

	_grade = HBoxContainer.new()
	_grade.add_theme_constant_override("separation", 24)
	caixa.add_child(_grade)

	_voltar = Button.new()
	_voltar.custom_minimum_size = Vector2(200, 48)
	_voltar.pressed.connect(func() -> void: get_tree().change_scene_to_file(LOGIN_SCENE))
	caixa.add_child(_voltar)

	_slots = ProfileStore.load_slots(GameConfig.PROFILE_SLOTS_MAX)
	_render()


func _render() -> void:
	_titulo.text = UiText.t("perfis_titulo")
	_voltar.text = UiText.t("voltar")
	for filho in _grade.get_children():
		_grade.remove_child(filho)
		filho.queue_free()
	for i in range(_slots.size()):
		_grade.add_child(_build_slot(i))


func _build_slot(index: int) -> PanelContainer:
	var painel := PanelContainer.new()
	painel.custom_minimum_size = SLOT_SIZE
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 10)
	painel.add_child(caixa)

	var perfil: Variant = _slots[index]
	if perfil == null:
		if index == _creating_slot:
			_build_creator(caixa, index)
		else:
			caixa.add_child(_label(UiText.t("slot_vazio"), 18))
			var novo := Button.new()
			novo.text = UiText.t("novo_perfil")
			novo.pressed.connect(func() -> void: _start_creating(index))
			caixa.add_child(novo)
		return painel

	var dados: Dictionary = perfil
	var nivel := ProfileRules.level_for_profile(dados, GameConfig.MAX_LEVEL)
	caixa.add_child(_label(str(dados["name"]), 22))
	caixa.add_child(_label("%s: %s" % [UiText.t("raca"), _valor(dados["race"])], 16))
	caixa.add_child(_label("%s: %s" % [UiText.t("classe"), _valor(dados["class"])], 16))
	caixa.add_child(_label("%s: %d (%s %d)" % [UiText.t("nivel"), nivel, UiText.t("xp"), int(dados["xp"])], 16))
	caixa.add_child(_label("%s: %s" % [UiText.t("tempo_jogo"), _tempo(int(dados["play_time_s"]))], 16))
	var jogar := Button.new()
	jogar.text = UiText.t("jogar")
	jogar.disabled = true
	jogar.tooltip_text = UiText.t("em_breve")
	caixa.add_child(jogar)
	return painel


func _build_creator(caixa: VBoxContainer, index: int) -> void:
	var entrada := LineEdit.new()
	entrada.max_length = ProfileRules.NAME_MAX_LENGTH
	entrada.placeholder_text = UiText.t("nome_perfil")
	caixa.add_child(entrada)

	var erro := _label("", 14)
	erro.modulate = Color(1.0, 0.5, 0.4)
	caixa.add_child(erro)

	var criar := Button.new()
	criar.text = UiText.t("criar")
	criar.pressed.connect(func() -> void: _try_create(index, entrada.text, erro))
	entrada.text_submitted.connect(func(texto: String) -> void: _try_create(index, texto, erro))
	caixa.add_child(criar)

	var cancelar := Button.new()
	cancelar.text = UiText.t("cancelar")
	cancelar.pressed.connect(_cancel_creating)
	caixa.add_child(cancelar)
	entrada.grab_focus()


func _start_creating(index: int) -> void:
	_creating_slot = index
	_render()


func _cancel_creating() -> void:
	_creating_slot = -1
	_render()


func _try_create(index: int, texto: String, erro: Label) -> void:
	var codigo := ProfileRules.validate_name(texto)
	if codigo == ProfileRules.ERR_EMPTY:
		erro.text = UiText.t("erro_nome_vazio")
		return
	if codigo == ProfileRules.ERR_TOO_LONG:
		erro.text = UiText.t("erro_nome_longo")
		return
	ProfileStore.save_slot(index, ProfileRules.make_profile(texto))
	_slots = ProfileStore.load_slots(GameConfig.PROFILE_SLOTS_MAX)
	_creating_slot = -1
	_render()


func _valor(texto: Variant) -> String:
	var limpo := str(texto)
	return limpo if not limpo.is_empty() else UiText.t("nao_definido")


func _tempo(segundos: int) -> String:
	var partes := ProfileRules.play_time_parts(segundos)
	return "%d %s %02d %s" % [partes.x, UiText.t("h"), partes.y, UiText.t("min")]


func _label(texto: String, tamanho: int) -> Label:
	var label := Label.new()
	label.text = texto
	label.add_theme_font_size_override("font_size", tamanho)
	return label
