class_name MapaModal
extends Control
## Modal do mapa-múndi de Aurel, aberto a partir da tela de teste (main.tscn).
## Cada pin leva ao mapa da cidade com transição suave. A seta no canto superior esquerdo
## volta ao mundo; no mundo, fecha o modal.

const MAPA_MUNDO := "res://assets/ui/mapa/mapa_mundo_aurel.jpg"
const PASTA_CIDADES := "res://assets/ui/mapa/cidades/"
const TAMANHO_ORIGINAL := Vector2(1376, 768)
const LARGURA_AREA: float = 800.0
const TAM_PIN: float = 30.0
const TAM_SETA: float = 40.0
const DURACAO: float = 0.45
const ZOOM: float = 0.08

## Posições dos pins em pixels da imagem original (1376 x 768).
const CIDADES := [
	{"nome": "Fundaferro", "arquivo": "fundaferro.jpg", "pos": Vector2(755, 255)},
	{"nome": "Alto Nimbo", "arquivo": "alto_nimbo.jpg", "pos": Vector2(965, 160)},
	{"nome": "Brumafunda", "arquivo": "brumafunda.jpg", "pos": Vector2(400, 330)},
	{"nome": "Fontes Rubras", "arquivo": "fontes_rubras.jpg", "pos": Vector2(1075, 395)},
	{"nome": "Carvamar", "arquivo": "carvamar.jpg", "pos": Vector2(235, 535)},
	{"nome": "Cais das Correntes", "arquivo": "cais_das_correntes.jpg", "pos": Vector2(700, 650)},
	{"nome": "Vardélia", "arquivo": "vardelia.jpg", "pos": Vector2(775, 470)},
	{"nome": "Lumeira", "arquivo": "lumeira.jpg", "pos": Vector2(250, 255)},
	{"nome": "Ponte Baixa", "arquivo": "ponte_baixa.jpg", "pos": Vector2(765, 355)},
	{"nome": "Salmoura", "arquivo": "salmoura.jpg", "pos": Vector2(1220, 285)},
	{"nome": "Roda Serena", "arquivo": "roda_serena.jpg", "pos": Vector2(500, 390)},
	{"nome": "Vigia do Dente", "arquivo": "vigia_do_dente.jpg", "pos": Vector2(640, 55)},
]

var _escala: float
var _altura_area: float
var _titulo: LetterText
var _area: Control
var _camada_mundo: Control
var _camada_cidade: Control
var _imagem_cidade: TextureRect
var _no_mundo: bool = true
var _tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_escala = LARGURA_AREA / TAMANHO_ORIGINAL.x
	_altura_area = TAMANHO_ORIGINAL.y * _escala

	var veu := ColorRect.new()
	veu.color = Color(0.0, 0.0, 0.0, 0.7)
	veu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veu)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	var chapa := UiKit.chapa(Vector2(960, _altura_area + 270.0))
	centro.add_child(chapa)
	var caixa := UiKit.miolo(chapa)
	caixa.add_theme_constant_override("separation", 10)

	var topo := HBoxContainer.new()
	caixa.add_child(topo)
	var seta := UiKit.seta(true, TAM_SETA)
	seta.pressed.connect(_ao_voltar)
	topo.add_child(seta)
	var espaco := Control.new()
	espaco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	espaco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	topo.add_child(espaco)

	_titulo = UiKit.letras(UiText.t("mapa"), 40.0, 600.0)
	_titulo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caixa.add_child(_titulo)

	_area = Control.new()
	_area.custom_minimum_size = Vector2(LARGURA_AREA, _altura_area)
	_area.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_area.clip_contents = true
	caixa.add_child(_area)

	_camada_mundo = _criar_camada(MAPA_MUNDO)
	_area.add_child(_camada_mundo)
	for cidade in CIDADES:
		_camada_mundo.add_child(_criar_pin(cidade))

	_camada_cidade = _criar_camada("")
	_imagem_cidade = _camada_cidade.get_child(0) as TextureRect
	_camada_cidade.visible = false
	_camada_cidade.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_area.add_child(_camada_cidade)


func _criar_camada(caminho_imagem: String) -> Control:
	var camada := Control.new()
	camada.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	camada.pivot_offset = Vector2(LARGURA_AREA, _altura_area) * 0.5
	camada.mouse_filter = Control.MOUSE_FILTER_PASS
	var imagem := TextureRect.new()
	imagem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_SCALE
	imagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if caminho_imagem != "":
		imagem.texture = load(caminho_imagem)
	camada.add_child(imagem)
	return camada


func _criar_pin(cidade: Dictionary) -> Button:
	var pin := Button.new()
	pin.flat = true
	pin.custom_minimum_size = Vector2(TAM_PIN, TAM_PIN)
	pin.size = Vector2(TAM_PIN, TAM_PIN)
	# Ponta inferior do pin encostada no topo do ícone da cidade.
	pin.position = (cidade["pos"] as Vector2) * _escala - Vector2(TAM_PIN * 0.5, TAM_PIN + 6.0)
	pin.tooltip_text = cidade["nome"]

	var desenho := Control.new()
	desenho.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desenho.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pin.add_child(desenho)
	desenho.draw.connect(func() -> void:
		var s := desenho.size
		var cabeca := Vector2(s.x * 0.5, s.y * 0.36)
		var raio := s.x * 0.26
		var ponta := Vector2(s.x * 0.5, s.y * 0.98)
		var cauda := PackedVector2Array([
			cabeca + Vector2(-raio * 0.85, raio * 0.35),
			ponta,
			cabeca + Vector2(raio * 0.85, raio * 0.35),
		])
		desenho.draw_colored_polygon(cauda, Color("2a0c08"))
		desenho.draw_circle(cabeca, raio + 2.0, Color("2a0c08"))
		var cauda_clara := PackedVector2Array([
			cabeca + Vector2(-raio * 0.7, raio * 0.3),
			ponta - Vector2(0.0, s.y * 0.04),
			cabeca + Vector2(raio * 0.7, raio * 0.3),
		])
		desenho.draw_colored_polygon(cauda_clara, Color("f2d28a"))
		desenho.draw_circle(cabeca, raio, Color("f2d28a"))
		desenho.draw_circle(cabeca, raio * 0.35, Color("2a0c08"))
	)
	pin.mouse_entered.connect(func() -> void: desenho.modulate = Color(1.25, 1.15, 0.9))
	pin.mouse_exited.connect(func() -> void: desenho.modulate = Color.WHITE)
	pin.pressed.connect(_mostrar_cidade.bind(cidade))
	return pin


func _mostrar_cidade(cidade: Dictionary) -> void:
	if _tween and _tween.is_valid() and _tween.is_running():
		return
	_no_mundo = false
	_titulo.set_text_letters(cidade["nome"], 40.0, 600.0)
	_imagem_cidade.texture = load(PASTA_CIDADES + cidade["arquivo"])
	_trocar(_camada_mundo, _camada_cidade, 1.0 + ZOOM, 1.0 - ZOOM)


func _voltar_mundo() -> void:
	if _tween and _tween.is_valid() and _tween.is_running():
		return
	_no_mundo = true
	_titulo.set_text_letters(UiText.t("mapa"), 40.0, 600.0)
	_trocar(_camada_cidade, _camada_mundo, 1.0 - ZOOM, 1.0 + ZOOM)


func _trocar(saindo: Control, entrando: Control, zoom_saida: float, zoom_entrada: float) -> void:
	entrando.visible = true
	entrando.modulate = Color(1.0, 1.0, 1.0, 0.0)
	entrando.scale = Vector2.ONE * zoom_entrada
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(saindo, "modulate:a", 0.0, DURACAO)
	_tween.tween_property(saindo, "scale", Vector2.ONE * zoom_saida, DURACAO)
	_tween.tween_property(entrando, "modulate:a", 1.0, DURACAO)
	_tween.tween_property(entrando, "scale", Vector2.ONE, DURACAO)
	_tween.chain().tween_callback(func() -> void: saindo.visible = false)


func _ao_voltar() -> void:
	if _no_mundo:
		queue_free()
	else:
		_voltar_mundo()
