class_name UiKit
extends RefCounted
## Peças do menu: chapa com rebite, texto com letras recortadas e botão de letras.

const CHAPA := "res://assets/ui/chapa/chapa_menu.png"


## Painel com a chapa com rebite. Os cantos e bordas ficam fixos; o miolo estica.
static func chapa(tamanho: Vector2) -> NinePatchRect:
	var painel := NinePatchRect.new()
	painel.texture = load(CHAPA)
	painel.patch_margin_left = 66
	painel.patch_margin_right = 66
	painel.patch_margin_top = 40
	painel.patch_margin_bottom = 50
	painel.custom_minimum_size = tamanho
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return painel


## Caixa vertical dentro da área útil da chapa (fora da moldura).
static func miolo(painel: Control) -> VBoxContainer:
	var caixa := VBoxContainer.new()
	caixa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caixa.offset_left = 76.0
	caixa.offset_top = 60.0
	caixa.offset_right = -76.0
	caixa.offset_bottom = -66.0
	caixa.alignment = BoxContainer.ALIGNMENT_CENTER
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_child(caixa)
	return caixa


static func letras(texto: String, altura: float, largura_max: float = 0.0) -> LetterText:
	var txt := LetterText.new()
	txt.set_text_letters(texto, altura, largura_max)
	return txt


## Seta em triângulo dourado com contorno escuro (esquerda ou direita). Passa o mouse e muda o tom.
static func seta(apontando_esquerda: bool, tamanho: float) -> Button:
	var b := Button.new()
	b.flat = true
	b.custom_minimum_size = Vector2(tamanho, tamanho)
	var desenho := Control.new()
	desenho.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desenho.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(desenho)
	desenho.draw.connect(func() -> void:
		var s := desenho.size
		var pontos := PackedVector2Array()
		if apontando_esquerda:
			pontos = PackedVector2Array([Vector2(s.x * 0.70, s.y * 0.22), Vector2(s.x * 0.30, s.y * 0.5), Vector2(s.x * 0.70, s.y * 0.78)])
		else:
			pontos = PackedVector2Array([Vector2(s.x * 0.30, s.y * 0.22), Vector2(s.x * 0.70, s.y * 0.5), Vector2(s.x * 0.30, s.y * 0.78)])
		desenho.draw_colored_polygon(pontos, Color("f2d28a"))
		desenho.draw_polyline(PackedVector2Array([pontos[0], pontos[1], pontos[2], pontos[0]]), Color("2a0c08"), 3.0)
	)
	b.mouse_entered.connect(func() -> void: desenho.modulate = Color(1.25, 1.15, 0.9))
	b.mouse_exited.connect(func() -> void: desenho.modulate = Color.WHITE)
	return b


## Botão sem fundo: o texto é só as letras. Passa o mouse e muda o tom.
static func botao(texto: String, altura: float, tamanho: Vector2) -> Button:
	var b := Button.new()
	b.flat = true
	b.custom_minimum_size = tamanho
	var txt := letras(texto, altura, tamanho.x - 16.0)
	txt.alignment = BoxContainer.ALIGNMENT_CENTER
	txt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	b.add_child(txt)
	b.mouse_entered.connect(func() -> void: txt.modulate = Color(1.25, 1.15, 0.9))
	b.mouse_exited.connect(func() -> void: txt.modulate = Color.WHITE)
	return b
