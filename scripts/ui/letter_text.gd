class_name LetterText
extends HBoxContainer
## Texto montado com as letras recortadas do alfabeto (assets/ui/alfabeto).
## Caracteres sem letra (acentos, números, pontuação) saem como texto comum.

const DIR_MAIUSCULAS := "res://assets/ui/alfabeto/maiusculas/"
const DIR_MINUSCULAS := "res://assets/ui/alfabeto/minusculas/"
const ESPACO: float = 0.45
const FOLGA: float = 0.08


## Monta o texto com altura de letra "altura". Se "largura_max" > 0, reduz a altura até caber.
func set_text_letters(texto: String, altura: float, largura_max: float = 0.0) -> void:
	var h := altura
	if largura_max > 0.0:
		while h > 10.0 and _largura(texto, h) > largura_max:
			h -= 1.0
	for filho in get_children():
		remove_child(filho)
		filho.queue_free()
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", int(h * FOLGA))
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for ch in texto:
		if ch == " ":
			add_child(_espaco(h))
			continue
		var caminho := _caminho(ch)
		if caminho.is_empty() or not ResourceLoader.exists(caminho):
			add_child(_texto_comum(ch, h))
			continue
		var tex: Texture2D = load(caminho)
		var tr := TextureRect.new()
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(h * tex.get_width() / float(tex.get_height()), h)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(tr)


func _largura(texto: String, h: float) -> float:
	var total := 0.0
	for ch in texto:
		if ch == " ":
			total += h * ESPACO
			continue
		var caminho := _caminho(ch)
		if caminho.is_empty() or not ResourceLoader.exists(caminho):
			total += h * 0.5
			continue
		var tex: Texture2D = load(caminho)
		total += h * tex.get_width() / float(tex.get_height()) + h * FOLGA
	return total


func _espaco(h: float) -> Control:
	var vazio := Control.new()
	vazio.custom_minimum_size = Vector2(h * ESPACO, h)
	vazio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return vazio


func _texto_comum(ch: String, h: float) -> Label:
	var label := Label.new()
	label.text = ch
	label.add_theme_font_size_override("font_size", int(h * 0.8))
	label.add_theme_color_override("font_color", Color("f2d28a"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


static func _caminho(ch: String) -> String:
	if ch >= "A" and ch <= "Z":
		return DIR_MAIUSCULAS + ch + ".png"
	if ch >= "a" and ch <= "z":
		return DIR_MINUSCULAS + ch + ".png"
	return ""
