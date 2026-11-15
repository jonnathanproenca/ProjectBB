extends Control
## Opções: idioma e brilho, sobre a chapa com rebite. Mudanças valem na hora e
## são salvas em user://settings.cfg. Ao trocar o idioma, a tela é montada de novo.

const LOGIN_SCENE := "res://scenes/login.tscn"

var _centro: CenterContainer
var _valor_brilho: LetterText
var _slider_brilho: HSlider
const LARGURA_CONTROLE: float = 300.0
const TAM_SETA: float = 40.0


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
	caixa.add_child(_linha_idioma())

	caixa.add_child(UiKit.letras(UiText.t("brilho"), 26.0, 408.0))
	caixa.add_child(_linha_brilho())
	caixa.add_child(_linha_valor_brilho())
	_atualizar_valor_brilho()

	var voltar := UiKit.botao(UiText.t("voltar"), 40.0, Vector2(220, 56))
	voltar.pressed.connect(func() -> void: get_tree().change_scene_to_file(LOGIN_SCENE))
	caixa.add_child(voltar)


func _linha_idioma() -> HBoxContainer:
	var linha := _linha()
	var atual := SettingsRules.LOCALES.find(UserSettings.locale)
	var esquerda := UiKit.seta(true, TAM_SETA)
	esquerda.pressed.connect(func() -> void: _trocar_idioma(-1))
	linha.add_child(esquerda)

	var caixa_nome := CenterContainer.new()
	caixa_nome.custom_minimum_size = Vector2(LARGURA_CONTROLE - TAM_SETA * 2.0, 40.0)
	caixa_nome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caixa_nome.add_child(UiKit.letras(SettingsRules.LOCALE_LABELS[atual], 30.0, LARGURA_CONTROLE - TAM_SETA * 2.0 - 12.0))
	linha.add_child(caixa_nome)

	var direita := UiKit.seta(false, TAM_SETA)
	direita.pressed.connect(func() -> void: _trocar_idioma(1))
	linha.add_child(direita)
	return linha


func _linha_brilho() -> HBoxContainer:
	var linha := _linha()
	var esquerda := UiKit.seta(true, TAM_SETA)
	esquerda.pressed.connect(func() -> void: _ajustar_brilho(-0.05))
	linha.add_child(esquerda)

	_slider_brilho = HSlider.new()
	_slider_brilho.min_value = SettingsRules.BRIGHTNESS_MIN
	_slider_brilho.max_value = SettingsRules.BRIGHTNESS_MAX
	_slider_brilho.step = 0.05
	_slider_brilho.value = UserSettings.brightness
	_slider_brilho.custom_minimum_size = Vector2(LARGURA_CONTROLE - TAM_SETA * 2.0, 28.0)
	_slider_brilho.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_slider_brilho.add_theme_stylebox_override("slider", _estilo_trilho())
	_slider_brilho.add_theme_stylebox_override("grabber_area", _estilo_preenchido())
	_slider_brilho.add_theme_stylebox_override("grabber_area_highlight", _estilo_preenchido())
	_slider_brilho.add_theme_icon_override("grabber", _bolinha())
	_slider_brilho.add_theme_icon_override("grabber_highlight", _bolinha())
	_slider_brilho.value_changed.connect(_on_brilho_changed)
	linha.add_child(_slider_brilho)

	var direita := UiKit.seta(false, TAM_SETA)
	direita.pressed.connect(func() -> void: _ajustar_brilho(0.05))
	linha.add_child(direita)
	return linha


## Linha horizontal centralizada dentro da chapa.
func _linha() -> HBoxContainer:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 10)
	linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return linha


func _trocar_idioma(passo: int) -> void:
	var total := SettingsRules.LOCALES.size()
	var atual := SettingsRules.LOCALES.find(UserSettings.locale)
	var novo := posmod(atual + passo, total)
	UserSettings.set_locale(SettingsRules.LOCALES[novo])
	_montar()


func _ajustar_brilho(passo: float) -> void:
	var novo := clampf(snappedf(UserSettings.brightness + passo, 0.05), SettingsRules.BRIGHTNESS_MIN, SettingsRules.BRIGHTNESS_MAX)
	_slider_brilho.value = novo
	_on_brilho_changed(novo)


func _on_brilho_changed(value: float) -> void:
	UserSettings.set_brightness(value)
	_atualizar_valor_brilho()


func _linha_valor_brilho() -> CenterContainer:
	var caixa := CenterContainer.new()
	caixa.custom_minimum_size = Vector2(LARGURA_CONTROLE, 36.0)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_valor_brilho = UiKit.letras("", 26.0)
	caixa.add_child(_valor_brilho)
	return caixa


func _atualizar_valor_brilho() -> void:
	_valor_brilho.set_text_letters("%d%%" % roundi(UserSettings.brightness * 100.0), 26.0)


func _estilo_trilho() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("2a1c16")
	estilo.set_corner_radius_all(3)
	estilo.content_margin_top = 4.0
	estilo.content_margin_bottom = 4.0
	return estilo


func _estilo_preenchido() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("f2d28a")
	estilo.set_corner_radius_all(3)
	estilo.content_margin_top = 4.0
	estilo.content_margin_bottom = 4.0
	return estilo


## Bolinha dourada com contorno escuro para o cursor do slider.
func _bolinha() -> ImageTexture:
	var tam := 22
	var imagem := Image.create(tam, tam, false, Image.FORMAT_RGBA8)
	var centro := Vector2(tam / 2.0, tam / 2.0)
	for y in range(tam):
		for x in range(tam):
			var d := Vector2(x + 0.5, y + 0.5).distance_to(centro)
			if d <= tam / 2.0 - 1.0:
				imagem.set_pixel(x, y, Color("f2d28a"))
			elif d <= tam / 2.0:
				imagem.set_pixel(x, y, Color("2a0c08"))
	return ImageTexture.create_from_image(imagem)
