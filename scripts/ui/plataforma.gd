class_name Plataforma
extends RefCounted
## Detecta se o jogo roda em celular/tablet: navegador mobile (web), app instalado (PWA) ou build nativa.
## Usado para trocar a digitação de texto, porque o teclado do iOS só abre a partir de um toque direto.

const JS_EH_MOBILE := "(/Android|iPhone|iPad|iPod/i.test(navigator.userAgent) || (navigator.maxTouchPoints > 1 && /Macintosh/.test(navigator.userAgent)))"
const JS_EH_INSTALADO := "(window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true)"

static var _mobile_cache: int = -1
static var _instalado_cache: int = -1


static func e_mobile() -> bool:
	if _mobile_cache == -1:
		_mobile_cache = 1 if _detectar_mobile() else 0
	return _mobile_cache == 1


## Verdadeiro quando o jogo está instalado como app (tela inicial do celular ou PWA).
static func e_app_instalado() -> bool:
	if _instalado_cache == -1:
		_instalado_cache = 1 if (OS.has_feature("web") and JavaScriptBridge.eval(JS_EH_INSTALADO, true) == true) else 0
	return _instalado_cache == 1


static func _detectar_mobile() -> bool:
	if OS.has_feature("android") or OS.has_feature("ios"):
		return true
	if OS.has_feature("web"):
		return JavaScriptBridge.eval(JS_EH_MOBILE, true) == true
	return false
