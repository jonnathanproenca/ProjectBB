class_name CenariosTeste
extends Node3D
## Três opções de cenário para comparar: casa da vila + cemitério + árvores.
## Cenário 3 tem muro de pedra com a peça EA03_Fence_Cobble_01a (CC0, itch.io). Troque com o botão ou com a tecla N; Esc volta à arena.
## Câmera livre: WASD anda, Q/E sobe e desce, Shift acelera, botão direito arrasta para girar, roda do mouse aproxima/afasta.
## Coordenadas em metros, Y para cima. Posições convertidas do teste no Blender (Godot z = -Blender y).
## Modelos de lápides e árvores: pacotes CC0 (polyy.ai), copiados para assets/cenario_teste/.

const PASTA_CENARIO: String = "res://assets/cenario_teste/"
const PASTA_VILA: String = "res://assets/vila_3d/"
const TAMANHO_CHAO: float = 60.0
const TOTAL_CENARIOS: int = 3
const ARENA_SCENE: String = "res://scenes/arena_teste.tscn"
const PASTA_MURO: String = "res://assets/cenario_teste/muro_pedra/"
const VELOCIDADE_CAMERA: float = 12.0
const SENSIBILIDADE_MOUSE: float = 0.005
const PASSO_ZOOM: float = 2.0
const PITCH_MINIMO: float = -1.4
const PITCH_MAXIMO: float = 0.2
const LARGURA_CAMINHO: float = 1.4
const QUANTIDADE_TUFOS: int = 2400
const CANDIDATOS_TUFOS: int = 9000
## Caminho de terra do portão do cemitério até a frente da casa, contornando a casa pelo lado leste (x, z).
const PONTOS_CAMINHO: Array[Vector2] = [
	Vector2(0.0, 13.0), Vector2(0.0, 8.0), Vector2(0.5, 4.5), Vector2(3.5, 3.2), Vector2(6.5, 2.0),
	Vector2(6.5, -3.2), Vector2(2.0, -4.2), Vector2(-3.0, -4.0), Vector2(-3.0, -2.6),
]

var _camera: Camera3D
var _botao: Button
var _raiz_cenario: Node3D = null
var _indice: int = 0
var _yaw: float = 0.0
var _pitch: float = 0.0


func _ready() -> void:
	_configurar_ambiente()
	_criar_interface()
	_mostrar(0)


func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventKey:
		var tecla: InputEventKey = evento as InputEventKey
		if tecla.pressed and not tecla.echo:
			if tecla.keycode == KEY_N:
				_proximo()
			elif tecla.keycode == KEY_ESCAPE:
				get_tree().change_scene_to_file(ARENA_SCENE)
	elif evento is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			var movimento: InputEventMouseMotion = evento as InputEventMouseMotion
			_yaw -= movimento.relative.x * SENSIBILIDADE_MOUSE
			_pitch = clampf(_pitch - movimento.relative.y * SENSIBILIDADE_MOUSE, PITCH_MINIMO, PITCH_MAXIMO)
			_camera.rotation = Vector3(_pitch, _yaw, 0.0)
	elif evento is InputEventMouseButton:
		var botao: InputEventMouseButton = evento as InputEventMouseButton
		if botao.pressed:
			if botao.button_index == MOUSE_BUTTON_WHEEL_UP:
				_camera.position += -_camera.global_basis.z * PASSO_ZOOM
			elif botao.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_camera.position -= -_camera.global_basis.z * PASSO_ZOOM


## Movimento livre da câmera: WASD anda no plano, Q/E sobe e desce, Shift acelera.
func _process(delta: float) -> void:
	var frente: Vector3 = Vector3(-sin(_yaw), 0.0, -cos(_yaw))
	var direita: Vector3 = Vector3(cos(_yaw), 0.0, -sin(_yaw))
	var mov: Vector3 = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		mov += frente
	if Input.is_key_pressed(KEY_S):
		mov -= frente
	if Input.is_key_pressed(KEY_D):
		mov += direita
	if Input.is_key_pressed(KEY_A):
		mov -= direita
	if Input.is_key_pressed(KEY_E):
		mov += Vector3.UP
	if Input.is_key_pressed(KEY_Q):
		mov -= Vector3.UP
	if mov != Vector3.ZERO:
		var velocidade: float = VELOCIDADE_CAMERA * (2.5 if Input.is_key_pressed(KEY_SHIFT) else 1.0)
		_camera.position += mov.normalized() * velocidade * delta


func _proximo() -> void:
	_mostrar((_indice + 1) % TOTAL_CENARIOS)


func _mostrar(i: int) -> void:
	_indice = i
	if _raiz_cenario != null:
		_raiz_cenario.queue_free()
	_raiz_cenario = Node3D.new()
	_raiz_cenario.name = "Cenario"
	add_child(_raiz_cenario)

	_montar_casa(_raiz_cenario)
	var itens: Array = _itens(i)
	for item in itens:
		var dados: Dictionary = item
		var caminho: String = PASTA_CENARIO + str(dados["arquivo"]) + ".glb"
		var pos: Vector3 = dados["pos"]
		var rot: float = float(dados["rot"])
		var altura: float = float(dados["altura"])
		_colocar_peca(_raiz_cenario, caminho, pos, rot, Vector3.ONE, altura)
	if i == 2:
		_montar_muro(_raiz_cenario)

	_aplicar_camera(i)
	_botao.text = "Cenário %d de %d (clique ou N para trocar)" % [i + 1, TOTAL_CENARIOS]


func _itens(i: int) -> Array:
	if i == 0:
		return _itens_cenario_1()
	if i == 1:
		return _itens_cenario_2()
	return _itens_cenario_3()


## Cenário 1: casa na frente, cemitério atrás, árvores em volta.
func _itens_cenario_1() -> Array:
	var lista: Array = []
	lista.append(_item("grave_01_classic_rounded_granite", Vector3(-5.0, 0.0, 4.0), -11.5, 1.4))
	lista.append(_item("grave_03_tapering_obelisk", Vector3(-2.5, 0.0, 4.2), 0.0, 2.2))
	lista.append(_item("grave_13_wooden_plank_cross", Vector3(0.0, 0.0, 4.0), 5.7, 1.5))
	lista.append(_item("grave_14_rusted_iron_cross", Vector3(2.5, 0.0, 4.2), -5.7, 1.6))
	lista.append(_item("grave_22_lidded_sarcophagus", Vector3(5.0, 0.0, 4.0), 0.0, 0.9))
	lista.append(_item("grave_06_sunken_ledger_slab", Vector3(-3.8, 0.0, 6.0), 0.0, 0.5))
	lista.append(_item("grave_01_classic_rounded_granite", Vector3(-0.8, 0.0, 6.2), 11.5, 1.3))
	lista.append(_item("grave_13_wooden_plank_cross", Vector3(1.8, 0.0, 6.4), -14.3, 1.4))
	lista.append(_item("grave_14_rusted_iron_cross", Vector3(4.8, 0.0, 6.6), 0.0, 1.5))
	lista.append(_item("tree_12_oak_green", Vector3(-8.0, 0.0, -1.5), 0.0, 5.5))
	lista.append(_item("tree_10_red_maple", Vector3(8.5, 0.0, -1.5), 0.0, 5.0))
	lista.append(_item("tree_09_round_green", Vector3(-9.0, 0.0, 4.0), 0.0, 5.2))
	lista.append(_item("tree_13_italian_cypress", Vector3(7.5, 0.0, 8.0), 0.0, 7.5))
	lista.append(_item("tree_18_scots_pine", Vector3(-3.0, 0.0, 10.0), 0.0, 7.0))
	lista.append(_item("tree_02_autumn_orange", Vector3(1.0, 0.0, 10.5), 0.0, 5.5))
	return lista


## Cenário 2: pátio com árvores em volta e três túmulos atrás da casa.
func _itens_cenario_2() -> Array:
	var lista: Array = []
	lista.append(_item("tree_12_oak_green", Vector3(-7.0, 0.0, -4.0), 0.0, 6.0))
	lista.append(_item("tree_09_round_green", Vector3(7.5, 0.0, -4.5), 0.0, 5.5))
	lista.append(_item("tree_02_autumn_orange", Vector3(9.0, 0.0, 2.0), 0.0, 5.0))
	lista.append(_item("tree_10_red_maple", Vector3(-8.5, 0.0, 2.0), 0.0, 5.2))
	lista.append(_item("tree_18_scots_pine", Vector3(4.0, 0.0, -8.0), 0.0, 7.0))
	lista.append(_item("grave_03_tapering_obelisk", Vector3(-2.0, 0.0, 4.0), 0.0, 2.0))
	lista.append(_item("grave_22_lidded_sarcophagus", Vector3(1.5, 0.0, 4.2), 0.0, 0.9))
	lista.append(_item("grave_06_sunken_ledger_slab", Vector3(4.0, 0.0, 3.8), -5.7, 0.5))
	return lista


## Cenário 3: cemitério grande atrás da casa, cercado por muro de pedra; coníferas do lado de fora.
func _itens_cenario_3() -> Array:
	var lista: Array = []
	var modelos: Array = [
		"grave_01_classic_rounded_granite", "grave_03_tapering_obelisk", "grave_06_sunken_ledger_slab",
		"grave_13_wooden_plank_cross", "grave_14_rusted_iron_cross", "grave_22_lidded_sarcophagus",
	]
	var posicoes: Array[Vector2] = []
	for x in [-8.0, -4.0, 0.0, 4.0, 8.0]:
		posicoes.append(Vector2(x, 3.5))
	for x in [-6.0, -2.0, 2.0, 6.0]:
		posicoes.append(Vector2(x, 6.5))
	for x in [-8.0, -4.0, 0.0, 4.0, 8.0]:
		posicoes.append(Vector2(x, 9.5))
	for k in range(posicoes.size()):
		var p: Vector2 = posicoes[k]
		var rot: float = -rad_to_deg(0.15 * float((k % 3) - 1))
		var modelo: String = modelos[k % modelos.size()]
		lista.append(_item(modelo, Vector3(p.x, 0.0, p.y), rot, 1.0 + 0.3 * float(k % 4)))
	lista.append(_item("tree_13_italian_cypress", Vector3(-10.0, 0.0, 13.0), 0.0, 8.0))
	lista.append(_item("tree_18_scots_pine", Vector3(-3.0, 0.0, 14.0), 0.0, 7.5))
	lista.append(_item("tree_13_italian_cypress", Vector3(5.0, 0.0, 13.5), 0.0, 8.5))
	lista.append(_item("tree_18_scots_pine", Vector3(11.0, 0.0, 12.0), 0.0, 7.0))
	return lista


func _item(arquivo: String, pos: Vector3, rot: float, altura: float) -> Dictionary:
	return {"arquivo": arquivo, "pos": pos, "rot": rot, "altura": altura}


## Casa de 8 x 3 m, mesma lista de peças da cena casa_vila_teste.
func _montar_casa(raiz: Node3D) -> void:
	for peca in CasaVila.PECAS:
		var dados: Dictionary = peca
		var caminho: String = PASTA_VILA + str(dados["arquivo"]) + ".gltf"
		var pos: Vector3 = dados["posicao"]
		var rot: float = float(dados["rotacao_y"])
		var escala: Vector3 = dados["escala"]
		_colocar_peca(raiz, caminho, pos, rot, escala, 0.0)


## Coloca um modelo. Se altura > 0, escala o modelo para essa altura e apoia a base no chão.
func _colocar_peca(pai: Node3D, caminho: String, pos: Vector3, rot: float, escala: Vector3, altura: float) -> Node3D:
	var cena: PackedScene = load(caminho) as PackedScene
	if cena == null:
		push_warning("Modelo não encontrado: %s" % caminho)
		return null
	var no: Node3D = cena.instantiate() as Node3D
	var fator: float = 1.0
	var deslocamento_y: float = 0.0
	if altura > 0.0:
		var caixa: AABB = _aabb_de(no)
		fator = altura / maxf(caixa.size.y, 0.001)
		deslocamento_y = -caixa.position.y * fator
	no.scale = escala * fator
	no.rotation_degrees = Vector3(0.0, rot, 0.0)
	no.position = pos + Vector3(0.0, deslocamento_y, 0.0)
	pai.add_child(no)
	return no


## AABB do conjunto de malhas, no referencial do nó raiz (sem contar a transformação do próprio nó).
func _aabb_de(no: Node3D) -> AABB:
	var resultado: AABB = AABB()
	var primeiro: bool = true
	var pilha: Array = [[no, Transform3D.IDENTITY]]
	while not pilha.is_empty():
		var item: Array = pilha.pop_back()
		var atual: Node = item[0]
		var transf: Transform3D = item[1]
		if atual is Node3D and atual != no:
			transf = transf * (atual as Node3D).transform
		if atual is MeshInstance3D:
			var caixa: AABB = transf * (atual as MeshInstance3D).get_aabb()
			if primeiro:
				resultado = caixa
				primeiro = false
			else:
				resultado = resultado.merge(caixa)
		for filho in atual.get_children():
			pilha.append([filho, transf])
	return resultado


## Muro de pedra na borda do cemitério (z = 11.5), com vão de 2 m no meio como portão.
## Peça EA03_Fence_Cobble_01a (2,36 m de comprimento e 1,2 m de altura, pacote FbxLODS, CC0),
## esticada para 2 m de comprimento e 1,3 m de altura. O FBX não traz textura: o material de pedra é aplicado aqui.
func _montar_muro(raiz: Node3D) -> void:
	var material: StandardMaterial3D = _material_pedra()
	var caminho: String = PASTA_MURO + "EA03_Fence_Cobble_01a.fbx"
	var altura_muro: float = 1.3
	var comprimento_peca: float = 2.36
	var comprimento_segmento: float = 2.0
	var escala_x: float = comprimento_segmento / comprimento_peca / (altura_muro / 1.2)
	var trechos: Array = [[-12.0, -2.0], [2.0, 12.0]]
	for trecho in trechos:
		var inicio: float = trecho[0]
		var fim: float = trecho[1]
		var x: float = inicio
		while x < fim - 0.01:
			var no: Node3D = _colocar_peca(raiz, caminho, Vector3(x + comprimento_segmento / 2.0, 0.0, 11.5), 0.0, Vector3(escala_x, 1.0, 1.0), altura_muro)
			if no != null:
				_aplicar_material(no, material)
			x += comprimento_segmento


## Aplica um material a todas as malhas de um nó e dos seus filhos.
func _aplicar_material(no: Node, material: Material) -> void:
	if no is MeshInstance3D:
		(no as MeshInstance3D).material_override = material
	for filho in no.get_children():
		_aplicar_material(filho, material)


## Pedra procedural: ruído fractal suave como cor e relevo leve. Triplanar, para não esticar sobre o FBX.
func _material_pedra() -> StandardMaterial3D:
	var ruido: FastNoiseLite = _ruido_fractal(0.06, 4)
	var cor: NoiseTexture2D = _textura_ruido(ruido, Color(0.40, 0.38, 0.35), Color(0.68, 0.65, 0.60))
	var relevo: NoiseTexture2D = NoiseTexture2D.new()
	relevo.noise = ruido
	relevo.width = 256
	relevo.height = 256
	relevo.seamless = true
	relevo.as_normal_map = true
	relevo.bump_strength = 2.0

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = cor
	material.normal_enabled = true
	material.normal_texture = relevo
	material.roughness = 0.95
	material.uv1_triplanar = true
	material.uv1_scale = Vector3(0.4, 0.4, 0.4)
	return material


func _ruido_fractal(frequencia: float, oitavas: int) -> FastNoiseLite:
	var ruido: FastNoiseLite = FastNoiseLite.new()
	ruido.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	ruido.fractal_type = FastNoiseLite.FRACTAL_FBM
	ruido.fractal_octaves = oitavas
	ruido.frequency = frequencia
	return ruido


## Textura seamless em tons entre duas cores, gerada do ruído.
func _textura_ruido(ruido: FastNoiseLite, cor_escura: Color, cor_clara: Color) -> NoiseTexture2D:
	var degrade: Gradient = Gradient.new()
	degrade.set_color(0, cor_escura)
	degrade.set_color(1, cor_clara)
	var textura: NoiseTexture2D = NoiseTexture2D.new()
	textura.noise = ruido
	textura.color_ramp = degrade
	textura.width = 256
	textura.height = 256
	textura.seamless = true
	return textura


func _material_grama() -> StandardMaterial3D:
	var textura: NoiseTexture2D = _textura_ruido(_ruido_fractal(0.035, 5), Color(0.20, 0.34, 0.13), Color(0.38, 0.56, 0.22))
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = textura
	material.roughness = 1.0
	material.uv1_scale = Vector3(12.0, 12.0, 1.0)
	return material


func _material_caminho() -> StandardMaterial3D:
	var textura: NoiseTexture2D = _textura_ruido(_ruido_fractal(0.12, 3), Color(0.34, 0.25, 0.16), Color(0.52, 0.41, 0.28))
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = textura
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _material_tufo() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 1.0
	return material


## Chão: grama, caminho de terra batida e tufos de grama espalhados fora do caminho e da casa.
func _montar_chao() -> void:
	var chao: MeshInstance3D = MeshInstance3D.new()
	var plano: PlaneMesh = PlaneMesh.new()
	plano.size = Vector2(TAMANHO_CHAO, TAMANHO_CHAO)
	chao.mesh = plano
	chao.material_override = _material_grama()
	add_child(chao)

	var caminho: MeshInstance3D = MeshInstance3D.new()
	caminho.mesh = _malha_caminho()
	caminho.material_override = _material_caminho()
	add_child(caminho)

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	var pontos: Array[Vector3] = []
	var tentativas: int = 0
	while pontos.size() < QUANTIDADE_TUFOS and tentativas < CANDIDATOS_TUFOS:
		tentativas += 1
		var p: Vector2 = Vector2(rng.randf_range(-TAMANHO_CHAO / 2.0, TAMANHO_CHAO / 2.0), rng.randf_range(-TAMANHO_CHAO / 2.0, TAMANHO_CHAO / 2.0))
		if _bloqueado_tufo(p):
			continue
		pontos.append(Vector3(p.x, 0.0, p.y))

	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = _malha_tufo()
	mm.instance_count = pontos.size()
	for i in range(pontos.size()):
		var base: Basis = Basis.from_euler(Vector3(0.0, rng.randf() * TAU, 0.0)).scaled(Vector3.ONE * rng.randf_range(0.8, 1.4))
		mm.set_instance_transform(i, Transform3D(base, pontos[i]))
		var tom: float = rng.randf_range(0.85, 1.1)
		mm.set_instance_color(i, Color(tom, tom, tom))

	var tufos: MultiMeshInstance3D = MultiMeshInstance3D.new()
	tufos.multimesh = mm
	tufos.material_override = _material_tufo()
	add_child(tufos)


## Faixa de terra batida ao longo dos pontos do caminho, com disco em cada curva para não ter buraco.
func _malha_caminho() -> ArrayMesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var meia: float = LARGURA_CAMINHO / 2.0
	for k in range(PONTOS_CAMINHO.size() - 1):
		var a: Vector2 = PONTOS_CAMINHO[k]
		var b: Vector2 = PONTOS_CAMINHO[k + 1]
		var d: Vector2 = (b - a).normalized()
		var p: Vector2 = Vector2(-d.y, d.x) * meia
		_vertice_caminho(st, a - p)
		_vertice_caminho(st, a + p)
		_vertice_caminho(st, b + p)
		_vertice_caminho(st, a - p)
		_vertice_caminho(st, b + p)
		_vertice_caminho(st, b - p)
	for c in PONTOS_CAMINHO:
		for s in range(12):
			var ang0: float = TAU * float(s) / 12.0
			var ang1: float = TAU * float(s + 1) / 12.0
			_vertice_caminho(st, c)
			_vertice_caminho(st, c + Vector2(cos(ang0), sin(ang0)) * meia)
			_vertice_caminho(st, c + Vector2(cos(ang1), sin(ang1)) * meia)
	st.generate_normals()
	return st.commit()


func _vertice_caminho(st: SurfaceTool, v: Vector2) -> void:
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(v.x / 3.0, v.y / 3.0))
	st.add_vertex(Vector3(v.x, 0.02, v.y))


## Cinco lâminas em forma de V por tufo, mais escuras na base e mais claras na ponta.
func _malha_tufo() -> ArrayMesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	var cor_base: Color = Color(0.16, 0.30, 0.10)
	var cor_ponta: Color = Color(0.46, 0.66, 0.24)
	for k in range(5):
		var ang: float = TAU * float(k) / 5.0 + rng.randf_range(-0.3, 0.3)
		var altura: float = rng.randf_range(0.28, 0.46)
		var direcao: Vector3 = Vector3(sin(ang), 0.0, cos(ang))
		var lateral: Vector3 = Vector3(cos(ang), 0.0, -sin(ang)) * 0.035
		var ponta: Vector3 = direcao * 0.12 + Vector3(0.0, altura, 0.0)
		st.set_color(cor_base)
		st.add_vertex(-lateral)
		st.set_color(cor_base)
		st.add_vertex(lateral)
		st.set_color(cor_ponta)
		st.add_vertex(ponta)
	st.generate_normals()
	return st.commit()


func _distancia_segmento(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab: Vector2 = b - a
	var t: float = clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
	return p.distance_to(a + ab * t)


func _distancia_caminho(p: Vector2) -> float:
	var menor: float = INF
	for k in range(PONTOS_CAMINHO.size() - 1):
		menor = minf(menor, _distancia_segmento(p, PONTOS_CAMINHO[k], PONTOS_CAMINHO[k + 1]))
	return menor


## Fica fora dos tufos: o caminho, a área da casa e um pequeno afastamento.
func _bloqueado_tufo(p: Vector2) -> bool:
	if _distancia_caminho(p) < LARGURA_CAMINHO / 2.0 + 0.3:
		return true
	return absf(p.x) < 4.5 and absf(p.y) < 2.0


func _aplicar_camera(i: int) -> void:
	var posicoes: Array[Vector3] = [Vector3(10.0, 8.0, -14.0), Vector3(-13.0, 8.0, -9.0), Vector3(-4.0, 9.0, 34.0)]
	var alvos: Array[Vector3] = [Vector3(0.0, 1.5, 3.0), Vector3(0.0, 1.5, 0.0), Vector3(0.0, 1.0, 8.0)]
	var campos: Array[float] = [40.0, 40.0, 45.0]
	_camera.position = posicoes[i]
	_camera.fov = campos[i]
	_camera.look_at(alvos[i], Vector3.UP)
	_yaw = _camera.rotation.y
	_pitch = _camera.rotation.x


func _configurar_ambiente() -> void:
	var ambiente: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.62, 0.75, 0.88)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 1.0, 1.0)
	env.ambient_light_energy = 0.9
	ambiente.environment = env
	add_child(ambiente)

	var sol: DirectionalLight3D = DirectionalLight3D.new()
	sol.rotation_degrees = Vector3(-50.0, -30.0, 0.0)
	add_child(sol)

	_montar_chao()

	_camera = Camera3D.new()
	add_child(_camera)
	_camera.current = true


func _criar_interface() -> void:
	var camada: CanvasLayer = CanvasLayer.new()
	add_child(camada)
	_botao = Button.new()
	_botao.position = Vector2(16.0, 16.0)
	_botao.custom_minimum_size = Vector2(380.0, 44.0)
	_botao.pressed.connect(_proximo)
	camada.add_child(_botao)
