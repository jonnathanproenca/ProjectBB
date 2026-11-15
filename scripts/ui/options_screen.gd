extends Control
## Opções: idioma e brilho. Mudanças valem na hora e são salvas em user://settings.cfg.

const LOGIN_SCENE := "res://scenes/login.tscn"

var _titulo: Label
var _idioma_label: Label
var _idioma: OptionButton
var _brilho_label: Label
var _brilho: HSlider
var _brilho_valor: Label
var _voltar: Button


func _ready() -> void:
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	var caixa := VBoxContainer.new()
	caixa.custom_minimum_size = Vector2(420, 0)
	caixa.add_theme_constant_override("separation", 18)
	centro.add_child(caixa)

	_titulo = _label("", 32)
	caixa.add_child(_titulo)

	_idioma_label = _label("", 18)
	caixa.add_child(_idioma_label)
	_idioma = OptionButton.new()
	for i in range(SettingsRules.LOCALES.size()):
		_idioma.add_item(SettingsRules.LOCALE_LABELS[i], i)
	_idioma.select(SettingsRules.LOCALES.find(UserSettings.locale))
	_idioma.item_selected.connect(_on_idioma_selected)
	caixa.add_child(_idioma)

	_brilho_label = _label("", 18)
	caixa.add_child(_brilho_label)
	_brilho = HSlider.new()
	_brilho.min_value = SettingsRules.BRIGHTNESS_MIN
	_brilho.max_value = SettingsRules.BRIGHTNESS_MAX
	_brilho.step = 0.05
	_brilho.value = UserSettings.brightness
	_brilho.value_changed.connect(_on_brilho_changed)
	caixa.add_child(_brilho)
	_brilho_valor = _label("", 16)
	caixa.add_child(_brilho_valor)

	_voltar = Button.new()
	_voltar.custom_minimum_size = Vector2(200, 48)
	_voltar.pressed.connect(func() -> void: get_tree().change_scene_to_file(LOGIN_SCENE))
	caixa.add_child(_voltar)

	_atualizar_textos()


func _atualizar_textos() -> void:
	_titulo.text = UiText.t("opcoes_titulo")
	_idioma_label.text = UiText.t("idioma")
	_brilho_label.text = UiText.t("brilho")
	_brilho_valor.text = "%d%%" % roundi(_brilho.value * 100.0)
	_voltar.text = UiText.t("voltar")


func _on_idioma_selected(index: int) -> void:
	UserSettings.set_locale(SettingsRules.LOCALES[index])
	_atualizar_textos()


func _on_brilho_changed(value: float) -> void:
	UserSettings.set_brightness(value)
	_atualizar_textos()


func _label(texto: String, tamanho: int) -> Label:
	var label := Label.new()
	label.text = texto
	label.add_theme_font_size_override("font_size", tamanho)
	return label
