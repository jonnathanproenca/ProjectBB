class_name CampoWebRules
extends RefCounted
## Regras puras para o campo de texto HTML sobreposto ao canvas (iOS Safari). Sem nós de cena.


## Converte um retângulo em pixels do canvas para pixels CSS da página.
## canvas_px: tamanho interno do canvas; canvas_css: retângulo do canvas na página (x, y, largura, altura).
## Devolve Rect2 em pixels CSS. Com tamanho de canvas inválido, devolve o retângulo vazio.
static func rect_css(rect_canvas: Rect2, canvas_px: Vector2, canvas_css: Rect2) -> Rect2:
	if canvas_px.x <= 0.0 or canvas_px.y <= 0.0:
		return Rect2()
	var escala := Vector2(canvas_css.size.x / canvas_px.x, canvas_css.size.y / canvas_px.y)
	return Rect2(
		canvas_css.position + rect_canvas.position * escala,
		rect_canvas.size * escala)


## Limpa o texto vindo do navegador: sem quebras de linha e limitado ao tamanho máximo.
static func limpar_texto(texto: String, max_len: int) -> String:
	var limpo := texto.replace("\n", " ").replace("\r", " ").replace("\t", " ")
	return limpo.left(max_len)
