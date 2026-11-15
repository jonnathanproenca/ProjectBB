extends Node
## Autoload "UserSettings": idioma e brilho, salvos em user://settings.cfg.
## Aplica o idioma (TranslationServer) e o brilho (véu sobre a tela) ao iniciar e a cada mudança.

const PATH: String = "user://settings.cfg"
const SECTION: String = "geral"

var locale: String = SettingsRules.DEFAULT_LOCALE
var brightness: float = SettingsRules.BRIGHTNESS_DEFAULT

var _veil: ColorRect


func _ready() -> void:
	_load()
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_veil = ColorRect.new()
	_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_veil)
	apply()


func apply() -> void:
	TranslationServer.set_locale(locale)
	_veil.color = SettingsRules.brightness_overlay_color(brightness)


func set_locale(code: String) -> void:
	locale = SettingsRules.sanitize_locale(code)
	apply()
	_save()


func set_brightness(value: float) -> void:
	brightness = SettingsRules.clamp_brightness(value)
	apply()
	_save()


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	locale = SettingsRules.sanitize_locale(str(cfg.get_value(SECTION, "idioma", locale)))
	brightness = SettingsRules.clamp_brightness(float(cfg.get_value(SECTION, "brilho", brightness)))


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, "idioma", locale)
	cfg.set_value(SECTION, "brilho", brightness)
	cfg.save(PATH)
