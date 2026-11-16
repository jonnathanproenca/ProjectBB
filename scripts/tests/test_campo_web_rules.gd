extends SceneTree
## Teste headless. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_campo_web_rules.gd
## Sai com código 0 se tudo passar, 1 se alguma asserção falhar.

var _failures: int = 0


func _initialize() -> void:
	# Canvas 1280x720 exibido em 640x360 CSS, deslocado 10,20 na página.
	var r := CampoWebRules.rect_css(Rect2(100, 200, 168, 48), Vector2(1280, 720), Rect2(10, 20, 640, 360))
	_check(r.position == Vector2(60, 120), "posição convertida para CSS")
	_check(r.size == Vector2(84, 24), "tamanho convertido para CSS")
	_check(CampoWebRules.rect_css(Rect2(1, 1, 2, 2), Vector2.ZERO, Rect2(0, 0, 10, 10)) == Rect2(), "canvas inválido gera retângulo vazio")

	_check(CampoWebRules.limpar_texto("Ana\nMaria", 20) == "Ana Maria", "quebra de linha vira espaço")
	_check(CampoWebRules.limpar_texto("abcdefghij", 5) == "abcde", "limita ao tamanho máximo")
	_check(CampoWebRules.limpar_texto("", 5) == "", "vazio continua vazio")

	if _failures == 0:
		print("OK: testes do campo web passaram.")
	quit(1 if _failures > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_failures += 1
		push_error("FALHOU: " + msg)
