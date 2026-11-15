extends Control
## Seleção de perfil após Entrar, em chapas com rebite. Até GameConfig.PROFILE_SLOTS_MAX perfis.
## Nesta etapa a criação pede só o nome; raça e classe ficam "não definido".

const LOGIN_SCENE := "res://scenes/login.tscn"
const SLOT_SIZE := Vector2(380, 440)
const LARGURA_TEXTO: float = 228.0
## Campo do nome e botões: 20 px da borda da chapa de cada lado (miolo começa em 86 px da borda).
const LARGURA_CAMPO: float = 208.0

var _slots: Array = []
var _creating_slot: int = -1
var _centro: CenterContainer


func _ready() -> void:
	_centro = CenterContainer.new()
	_centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_centro)
	_slots = ProfileStore.load_slots(GameConfig.PROFILE_SLOTS_MAX)
	_montar()


func _montar() -> void:
	for filho in _centro.get_children():
		_centro.remove_child(filho)
		filho.queue_free()

	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 24)
	caixa.alignment = BoxContainer.ALIGNMENT_CENTER
	_centro.add_child(caixa)
	var grade := HBoxContainer.new()
	grade.add_theme_constant_override("separation", 22)
	caixa.add_child(grade)
	for i in range(_slots.size()):
		grade.add_child(_build_slot(i))

	var voltar := UiKit.botao(UiText.t("voltar"), 40.0, Vector2(220, 56))
	voltar.pressed.connect(func() -> void: get_tree().change_scene_to_file(LOGIN_SCENE))
	caixa.add_child(voltar)


func _build_slot(index: int) -> Control:
	var chapa := UiKit.chapa(SLOT_SIZE)
	var caixa := UiKit.miolo(chapa)
	caixa.add_theme_constant_override("separation", 10)

	var perfil: Variant = _slots[index]
	if perfil == null:
		if index == _creating_slot:
			_build_creator(caixa, index)
		else:
			caixa.add_child(UiKit.letras(UiText.t("slot_vazio"), 30.0, LARGURA_TEXTO))
			var novo := UiKit.botao(UiText.t("novo_perfil"), 26.0, Vector2(220, 56))
			novo.pressed.connect(func() -> void: _start_creating(index))
			caixa.add_child(novo)
		return chapa

	var dados: Dictionary = perfil
	var nivel := ProfileRules.level_for_profile(dados, GameConfig.MAX_LEVEL)
	caixa.add_child(UiKit.letras(str(dados["name"]), 34.0, LARGURA_TEXTO))
	caixa.add_child(UiKit.letras("%s: %s" % [UiText.t("raca"), _valor(dados["race"])], 22.0, LARGURA_TEXTO))
	caixa.add_child(UiKit.letras("%s: %s" % [UiText.t("classe"), _valor(dados["class"])], 22.0, LARGURA_TEXTO))
	caixa.add_child(UiKit.letras("%s %d  %s %d" % [UiText.t("nivel"), nivel, UiText.t("xp"), int(dados["xp"])], 22.0, LARGURA_TEXTO))
	caixa.add_child(UiKit.letras("%s: %s" % [UiText.t("tempo_jogo"), _tempo(int(dados["play_time_s"]))], 22.0, LARGURA_TEXTO))
	var jogar := UiKit.botao(UiText.t("jogar"), 26.0, Vector2(LARGURA_CAMPO, 52))
	jogar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	jogar.disabled = true
	jogar.tooltip_text = UiText.t("em_breve")
	caixa.add_child(jogar)
	return chapa


func _build_creator(caixa: VBoxContainer, index: int) -> void:
	var area := Control.new()
	area.custom_minimum_size = Vector2(LARGURA_CAMPO, 48)
	area.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caixa.add_child(area)

	# Campo de digitação transparente; o nome aparece por cima com as letras recortadas.
	var entrada := LineEdit.new()
	entrada.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	entrada.custom_minimum_size = Vector2(LARGURA_CAMPO, 48)
	entrada.clip_contents = true
	entrada.max_length = ProfileRules.NAME_MAX_LENGTH
	entrada.alignment = HORIZONTAL_ALIGNMENT_CENTER
	entrada.add_theme_color_override("font_color", Color(0, 0, 0, 0))
	entrada.add_theme_color_override("font_placeholder_color", Color(0, 0, 0, 0))
	entrada.add_theme_color_override("caret_color", Color("f2d28a"))
	area.add_child(entrada)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(centro)
	var nome_letras := UiKit.letras("", 30.0, LARGURA_CAMPO - 16.0)
	centro.add_child(nome_letras)
	# Dica só aparece com o campo vazio e sem foco; com texto, mostra o nome.
	var atualizar := func() -> void:
		if entrada.text == "":
			nome_letras.set_text_letters(UiText.t("nome_perfil"), 30.0, LARGURA_CAMPO - 16.0)
			nome_letras.modulate = Color(1, 1, 1, 0.45)
			nome_letras.visible = not entrada.has_focus()
		else:
			nome_letras.set_text_letters(entrada.text, 30.0, LARGURA_CAMPO - 16.0)
			nome_letras.modulate = Color.WHITE
			nome_letras.visible = true
	entrada.text_changed.connect(func(_texto: String) -> void: atualizar.call())
	entrada.focus_entered.connect(func() -> void: atualizar.call())
	entrada.focus_exited.connect(func() -> void: atualizar.call())
	atualizar.call()

	var erro := Label.new()
	erro.add_theme_font_size_override("font_size", 14)
	erro.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
	caixa.add_child(erro)

	var criar := UiKit.botao(UiText.t("criar"), 26.0, Vector2(LARGURA_CAMPO, 52))
	criar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	criar.pressed.connect(func() -> void: _try_create(index, entrada.text, erro))
	entrada.text_submitted.connect(func(texto: String) -> void: _try_create(index, texto, erro))
	caixa.add_child(criar)

	var cancelar := UiKit.botao(UiText.t("cancelar"), 26.0, Vector2(LARGURA_CAMPO, 52))
	cancelar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cancelar.pressed.connect(_cancel_creating)
	caixa.add_child(cancelar)
	entrada.grab_focus()


func _start_creating(index: int) -> void:
	_creating_slot = index
	_montar()


func _cancel_creating() -> void:
	_creating_slot = -1
	_montar()


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
	_montar()


func _valor(texto: Variant) -> String:
	var limpo := str(texto)
	return limpo if not limpo.is_empty() else UiText.t("nao_definido")


func _tempo(segundos: int) -> String:
	var partes := ProfileRules.play_time_parts(segundos)
	return "%d %s %02d %s" % [partes.x, UiText.t("h"), partes.y, UiText.t("min")]
