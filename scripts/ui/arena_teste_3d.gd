class_name ArenaTeste3D
extends Node3D
## Protótipo 3D da arena (ADR-072): mesmo gerador e mesmo manifesto da tela 2D.
## Tiles viram hexágonos 3D com a textura atual; props são sprites em pé até chegarem os modelos 3D.
## Câmera inclinada em 3/4, sem rotação. Controles: N ou Espaço nova arena; M troca o estilo (V1 ou V2);
## + e - mudam o agrupamento de campo; Esc volta ao mundo.
## Regra: scripts/rules/arena_generator.gd (não muda com o 3D). Assets: manifestos gerados em tools/.

const MUNDO_SCENE: String = "res://scenes/mundo.tscn"
const TIPO: String = "estrada"
const TAM_HEX_X: float = 64.0
const TAM_HEX_Y: float = 54.0
const PASSO_X: float = 48.0
const PASSO_Y: float = 54.0
const DESLOCAMENTO_IMPAR: float = 27.0
const ESCALA: float = 1.0 / 32.0          # 1 metro = 32 px da arte
const ALTURA_PROP_PX: float = 64.0
const CAMERA_DESLOCAMENTO: Vector3 = Vector3(0.0, 13.0, 11.0)
const CAMERA_FOV: float = 40.0
const COR_FUNDO: Color = Color(0.07, 0.07, 0.09)
const MANIFESTOS: Array[String] = [ArenaCatalogo.CAMINHO_PADRAO, "res://assets/arenas/manifesto_v2.json"]
const NOMES_ESTILOS: Array[String] = ["V1 (Flow)", "V2 (Blender)"]
const HISTORICO_LIMITE: int = 20
const TENTATIVAS_SEMENTE: int = 10

var _estilo: int = 0
var _catalogo: Dictionary = {}
var _layout: Dictionary = {}
var _historico: Array = []
var _semente: int = 0
var _agrupamento: int = GameConfig.ARENA_AGRUPAMENTO_PADRAO
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _raiz_arena: Node3D = null
var _camera: Camera3D = null
var _rotulo: Label = null
var _texturas: Dictionary = {}


func _ready() -> void:
	_rng.randomize()
	_configurar_cena()
	_recarregar_catalogo()
	_nova_arena()


func _configurar_cena() -> void:
	var ambiente := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = COR_FUNDO
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 1.0, 1.0)
	env.ambient_light_energy = 0.8
	ambiente.environment = env
	add_child(ambiente)

	var sol := DirectionalLight3D.new()
	sol.rotation_degrees = Vector3(-55.0, -30.0, 0.0)
	add_child(sol)

	_camera = Camera3D.new()
	_camera.fov = CAMERA_FOV
	add_child(_camera)
	_camera.current = true

	_raiz_arena = Node3D.new()
	add_child(_raiz_arena)

	var camada := CanvasLayer.new()
	add_child(camada)
	_rotulo = Label.new()
	_rotulo.position = Vector2(12, 8)
	camada.add_child(_rotulo)


func _recarregar_catalogo() -> void:
	_catalogo = ArenaCatalogo.carregar(MANIFESTOS[_estilo])


func _nova_arena() -> void:
	if _catalogo.is_empty():
		_rotulo.text = "Sem manifesto para %s. Rode o gerador de manifesto." % NOMES_ESTILOS[_estilo]
		return
	var layout: Dictionary = {}
	var tentativas := 0
	while layout.is_empty() and tentativas < TENTATIVAS_SEMENTE:
		_semente = _rng.randi() & 0x7fffffff
		layout = ArenaGenerator.gerar(_catalogo, TIPO, _semente, _historico, _agrupamento)
		tentativas += 1
	if layout.is_empty():
		_rotulo.text = "Não gerou nenhum mapa. Confira o manifesto: falta tile ou cobertura de algum papel."
		return
	_layout = layout
	_historico = ArenaGenerator.registrar(_historico, layout, HISTORICO_LIMITE)
	_rotulo.text = "3D | %s  |  Semente %d  |  Agrupamento %d (+/-)  |  N ou Espaço: outra arena  |  M: trocar estilo  |  Esc: voltar" % [NOMES_ESTILOS[_estilo], _semente, _agrupamento]
	_montar_arena()


func _montar_arena() -> void:
	for filho in _raiz_arena.get_children():
		_raiz_arena.remove_child(filho)
		filho.queue_free()

	var tiles: Array = _layout["tiles"]
	for y in range(ArenaGenerator.ALTURA):
		for x in range(ArenaGenerator.LARGURA):
			var caminho: String = tiles[y * ArenaGenerator.LARGURA + x]
			_raiz_arena.add_child(_criar_hex(caminho, _centro_hex(x, y)))

	for p in _layout["props"]:
		_raiz_arena.add_child(_criar_prop(p["arquivo"], _centro_hex(p["x"], p["y"])))

	var centro := _centro_hex(ArenaGenerator.LARGURA / 2, ArenaGenerator.ALTURA / 2)
	_camera.position = centro + CAMERA_DESLOCAMENTO
	_camera.look_at(centro, Vector3.UP)


## Centro do hex em metros. Mesma grade da tela 2D: colunas ímpares descem meio hex.
func _centro_hex(x: int, y: int) -> Vector3:
	var deslocamento: float = DESLOCAMENTO_IMPAR if x % 2 == 1 else 0.0
	var cx: float = x * PASSO_X + TAM_HEX_X / 2.0
	var cz: float = y * PASSO_Y + deslocamento + TAM_HEX_Y / 2.0
	return Vector3(cx * ESCALA, 0.0, cz * ESCALA)


## Hexágono flat-top de 64x54 px com a textura do tile por cima (UV cobre a caixa do hex).
func _criar_hex(caminho: String, centro: Vector3) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pontos: Array[Vector3] = []
	var uvs: Array[Vector2] = []
	var achatamento: float = (TAM_HEX_Y / 2.0) / ((TAM_HEX_X / 2.0) * sin(deg_to_rad(60.0)))
	for i in range(6):
		var ang: float = deg_to_rad(60.0 * i)
		var px: float = (TAM_HEX_X / 2.0) * cos(ang)
		var pz: float = (TAM_HEX_X / 2.0) * sin(ang) * achatamento
		pontos.append(Vector3(px * ESCALA, 0.0, pz * ESCALA))
		uvs.append(Vector2(px / TAM_HEX_X + 0.5, pz / TAM_HEX_Y + 0.5))
	for i in range(6):
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.5, 0.5))
		st.add_vertex(Vector3.ZERO)
		st.set_normal(Vector3.UP)
		st.set_uv(uvs[i])
		st.add_vertex(pontos[i])
		st.set_normal(Vector3.UP)
		st.set_uv(uvs[(i + 1) % 6])
		st.add_vertex(pontos[(i + 1) % 6])
	var malha := st.commit()

	var mat := StandardMaterial3D.new()
	mat.albedo_texture = _textura(caminho)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	malha.surface_set_material(0, mat)

	var mi := MeshInstance3D.new()
	mi.mesh = malha
	mi.position = centro
	return mi


## Prop em pé: sprite que gira só em Y, com a base encostada no centro do hex.
func _criar_prop(caminho: String, centro: Vector3) -> Sprite3D:
	var s := Sprite3D.new()
	s.texture = _textura(caminho)
	s.pixel_size = ESCALA
	s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.position = centro + Vector3(0.0, (ALTURA_PROP_PX / 2.0) * ESCALA, 0.0)
	return s


func _textura(caminho: String) -> Texture2D:
	if not _texturas.has(caminho):
		_texturas[caminho] = load(caminho) if ResourceLoader.exists(caminho) else null
	return _texturas[caminho]


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
	elif tecla.keycode == KEY_M:
		_estilo = (_estilo + 1) % MANIFESTOS.size()
		_recarregar_catalogo()
		_historico.clear()
		_nova_arena()
		get_viewport().set_input_as_handled()
	elif tecla.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(MUNDO_SCENE)
