class_name SettingsRules
extends RefCounted
## Regras puras de configuração: idioma e brilho. Sem nós de cena, para teste headless.

const LOCALES = ["pt_BR", "en", "es"]
const LOCALE_LABELS = ["Português", "English", "Español"]
const DEFAULT_LOCALE: String = "pt_BR"

const BRIGHTNESS_MIN: float = 0.5
const BRIGHTNESS_MAX: float = 1.5
const BRIGHTNESS_DEFAULT: float = 1.0


static func sanitize_locale(code: String) -> String:
	return code if LOCALES.has(code) else DEFAULT_LOCALE


static func clamp_brightness(value: float) -> float:
	return clampf(value, BRIGHTNESS_MIN, BRIGHTNESS_MAX)


## Cor do véu sobre a tela. Abaixo de 1.0 escurece com preto; acima clareia com branco.
static func brightness_overlay_color(brightness: float) -> Color:
	var b := clamp_brightness(brightness)
	if b < 1.0:
		return Color(0.0, 0.0, 0.0, 1.0 - b)
	if b > 1.0:
		return Color(1.0, 1.0, 1.0, (b - 1.0) * 0.5)
	return Color(0.0, 0.0, 0.0, 0.0)
