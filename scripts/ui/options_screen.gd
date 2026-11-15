extends Control
## Opções: idioma e brilho, sobre a chapa com rebite. Mudanças valem na hora e
## são salvas em user://settings.cfg. Ao trocar o idioma, a tela é montada de novo.

const LOGIN_SCENE := "res://scenes/login.tscn"

var _centro: CenterContainer
var _valor_brilho: Label


func _ready() -> void:
	_centro = CenterContainer.new()
	_centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_centro)
	_montar()


func _montar() -> void:
	for filho in _centro.get_children():
		_centro.remove_child(filho)
		filho.queue_free()

	var chapa := UiKit.chapa(Vector2(560, 480))
	_centro.add_child(chapa)
	var caixa := UiKit.miolo(chapa)
	caixa.add_theme_constant_override("separation", 12)

	caixa.add_child(UiKit.letras(UiText.t("opcoes_titulo"), 46.0, 408.0))
	caixa.add_child(UiKit.letras(UiText.t("idioma"), 26.0, 408.0))
	var idioma := OptionButton.new()
	for i in range(SettingsRules.LOCALES.size()):
		idioma.add_item(SettingsRules.LOCALE_LABELS[i], i)
	idioma.select(SettingsRules.LOCALES.find(UserSettings.locale))
	idioma.item_selected.connect(_on_idioma_selected)
	caixa.add_child(idioma)

	caixa.add_child(UiKit.letras(UiText.t("brilho"), 26.0, 408.0))
	var brilho := HSlider.new()
	brilho.min_value = SettingsRules.BRIGHTNESS_MIN
	brilho.max_value = SettingsRules.BRIGHTNESS_MAX
	brilho.step = 0.05
	brilho.value = UserSettings.brightness
	brilho.value_changed.connect(_on_brilho_changed)
	caixa.add_child(brilho)
	_valor_brilho = Label.new()
	_valor_brilho.text = "%d%%" % roundi(UserSettings.brightness * 100.0)
	_valor_brilho.add_theme_font_size_override("font_size", 18)
	_valor_brilho.add_theme_color_override("font_color", Color("e8d5b0"))
	caixa.add_child(_valor_brilho)

	var voltar := UiKit.botao(UiText.t("voltar"), 40.0, Vector2(220, 56))
	voltar.pressed.connect(func() -> void: get_tree().change_scene_to_file(LOGIN_SCENE))
	caixa.add_child(voltar)


func _on_idioma_selected(index: int) -> void:
	UserSettings.set_locale(SettingsRules.LOCALES[index])
	_montar()


func _on_brilho_changed(value: float) -> void:
	UserSettings.set_brightness(value)
	_valor_brilho.text = "%d%%" % roundi(UserSettings.brightness * 100.0)
