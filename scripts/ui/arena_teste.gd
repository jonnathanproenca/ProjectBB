class_name ArenaTeste
extends Control
## Tela de teste das arenas procedurais. N ou Espaço gera outro mapa; + e - mudam o agrupamento de campo; Esc volta ao mundo.
## Regra: scripts/rules/arena_generator.gd. Assets: manifesto gerado por tools/gerar_manifesto_arenas.py.

const MUNDO_SCENE: String = "res://scenes/mundo.tscn"
const TIPO: String = "estrada"
const TAM_HEX: Vector2 = Vector2(64, 54)
const TAM_PROP: Vector2 = Vector2(64, 64)
const PASSO_X: int = 48
const PASSO_Y: int = 54
const DESLOCAMENTO_IMPAR: int = 27
const SOBE_PROP: int = 26
const COR_FUNDO: Color = Color(0.07, 0.07, 0.09)
const COR_FALTA: Color = Color(1.0, 0.0, 1.0, 0.5)
const HISTORICO_LIMITE: int = 20
const TENTATIVAS_SEMENTE: int = 10

var _catalogo: Dictionary = {}
var _layout: Dictionary = {}
var _historico: Array = []
var _semente: int = 0
var _texturas: Dictionary = {}
var _rotulo: Label = null
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _agrupamento: int = GameConfig.ARENA_AGRUPAMENTO_PADRAO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	focus_mode = Control.FOCUS_ALL
	_rng.randomize()
	_catalogo = ArenaCatalogo.carregar(_caminho_manifesto())
	_rotulo = Label.new()
	_rotulo.position = Vector2(12, 8)
	_rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rotulo)
	grab_focus()
	_nova_arena()


## Manifesto lido pela tela. A V2 (arena_teste_v2) sobrescreve para usar os assets do Blender.
func _caminho_manifesto() -> String:
	return ArenaCatalogo.CAMINHO_PADRAO


func _nova_arena() -> void:
	if _catalogo.is_empty():
		_rotulo.text = "Sem manifesto. Rode: python tools/gerar_manifesto_arenas.py"
		queue_redraw()
		return
	var layout: Dictionary = {}
	var tentativas := 0
	while layout.is_empty() and tentativas < TENTATIVAS_SEMENTE:
		_semente = _rng.randi() & 0x7fffffff
		layout = ArenaGenerator.gerar(_catalogo, TIPO, _semente, _historico, _agrupamento)
		tentativas += 1
	if layout.is_empty():
		_rotulo.text = "Não gerou nenhum mapa. Confira o manifesto: falta tile ou cobertura de algum papel."
		queue_redraw()
		return
	_layout = layout
	_historico = ArenaGenerator.registrar(_historico, layout, HISTORICO_LIMITE)
	_rotulo.text = "Semente %d  |  Agrupamento %d (+/-)  |  N ou Espaço: outra arena  |  Esc: voltar" % [_semente, _agrupamento]
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var tecla := event as InputEventKey
	if tecla.keycode == KEY_N or tecla.keycode == KEY_SPACE:
		_nova_arena()
		get_viewport().set_input_as_handled()
	elif tecla.keycode == KEY_EQUAL or tecla.keycode == KEY_PLUS or tecla.keycode == KEY_KP_ADD:
		_agrupamento = mini(_agrupamento + 1, GameConfig.ARENA_AGRUPAMENTO_MAX)
		_nova_arena()
		get_viewport().set_input_as_handled()
	elif tecla.keycode == KEY_MINUS or tecla.keycode == KEY_KP_SUBTRACT:
		_agrupamento = maxi(_agrupamento - 1, 1)
		_nova_arena()
		get_viewport().set_input_as_handled()
	elif tecla.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(MUNDO_SCENE)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COR_FUNDO)
	if _layout.is_empty():
		return
	var largura_unidade: float = (ArenaGenerator.LARGURA - 1) * PASSO_X + TAM_HEX.x
	var altura_unidade: float = (ArenaGenerator.ALTURA - 1) * PASSO_Y + DESLOCAMENTO_IMPAR + TAM_HEX.y
	var escala: float = minf(size.x / largura_unidade, size.y / altura_unidade) * 0.92
	var origem: Vector2 = ((size - Vector2(largura_unidade, altura_unidade) * escala) / 2.0).floor()

	var tiles: Array = _layout["tiles"]
	for y in range(ArenaGenerator.ALTURA):
		for x in range(ArenaGenerator.LARGURA):
			var caminho: String = tiles[y * ArenaGenerator.LARGURA + x]
			_desenhar(caminho, origem + _posicao(x, y) * escala, TAM_HEX * escala)

	var props: Array = (_layout["props"] as Array).duplicate()
	props.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["y"] < b["y"] or (a["y"] == b["y"] and a["x"] < b["x"]))
	for p in props:
		var topo: Vector2 = _posicao(p["x"], p["y"]) + Vector2(0, -SOBE_PROP)
		_desenhar(p["arquivo"], origem + topo * escala, TAM_PROP * escala)


## Posição do canto superior esquerdo do hex, em unidades de tela antes da escala.
func _posicao(x: int, y: int) -> Vector2:
	var deslocamento: int = DESLOCAMENTO_IMPAR if x % 2 == 1 else 0
	return Vector2(x * PASSO_X, y * PASSO_Y + deslocamento)


func _desenhar(caminho: String, pos: Vector2, tamanho: Vector2) -> void:
	var textura: Texture2D = _textura(caminho)
	if textura == null:
		draw_rect(Rect2(pos, tamanho), COR_FALTA)
		return
	draw_texture_rect(textura, Rect2(pos, tamanho), false)


func _textura(caminho: String) -> Texture2D:
	if not _texturas.has(caminho):
		_texturas[caminho] = load(caminho) if ResourceLoader.exists(caminho) else null
	return _texturas[caminho]
