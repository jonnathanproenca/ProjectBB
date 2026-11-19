class_name CenariosTeste
extends Node3D
## Três opções de cenário para comparar: casa da vila + cemitério + árvores.
## Cenário 3 tem muro de pedra procedural (sem textura externa). Troque com o botão ou com a tecla N.
## Coordenadas em metros, Y para cima. Posições convertidas do teste no Blender (Godot z = -Blender y).
## Modelos de lápides e árvores: pacotes CC0 (polyy.ai), copiados para assets/cenario_teste/.

const PASTA_CENARIO: String = "res://assets/cenario_teste/"
const PASTA_VILA: String = "res://assets/vila_3d/"
const TAMANHO_CHAO: float = 60.0
const TOTAL_CENARIOS: int = 3
const ARENA_SCENE: String = "res://scenes/arena_teste.tscn"

var _camera: Camera3D
var _botao: Button
var _raiz_cenario: Node3D = null
var _indice: int = 0


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
func _colocar_peca(pai: Node3D, caminho: String, pos: Vector3, rot: float, escala: Vector3, altura: float) -> void:
	var cena: PackedScene = load(caminho) as PackedScene
	if cena == null:
		push_warning("Modelo não encontrado: %s" % caminho)
		return
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
func _montar_muro(raiz: Node3D) -> void:
	var material: StandardMaterial3D = _material_pedra()
	var trechos: Array = [[-12.0, -2.0], [2.0, 12.0]]
	for trecho in trechos:
		var inicio: float = trecho[0]
		var fim: float = trecho[1]
		var x: float = inicio
		while x < fim - 0.01:
			var comp: float = minf(2.0, fim - x)
			var h: float = 1.3 + 0.3 * absf(sin(x * 1.7))
			var caixa: BoxMesh = BoxMesh.new()
			caixa.size = Vector3(comp, h, 0.5)
			var bloco: MeshInstance3D = MeshInstance3D.new()
			bloco.mesh = caixa
			bloco.material_override = material
			bloco.position = Vector3(x + comp / 2.0, h / 2.0, 11.5)
			raiz.add_child(bloco)
			x += comp


## Pedra procedural: ruído celular como cor e como relevo (normal map). Sem download.
func _material_pedra() -> StandardMaterial3D:
	var ruido: FastNoiseLite = FastNoiseLite.new()
	ruido.noise_type = FastNoiseLite.TYPE_CELLULAR
	ruido.frequency = 0.08

	var cor: NoiseTexture2D = NoiseTexture2D.new()
	cor.noise = ruido
	cor.width = 256
	cor.height = 256
	cor.seamless = true

	var relevo: NoiseTexture2D = NoiseTexture2D.new()
	relevo.noise = ruido
	relevo.width = 256
	relevo.height = 256
	relevo.seamless = true
	relevo.as_normal_map = true
	relevo.bump_strength = 6.0

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.56, 0.54, 0.5)
	material.albedo_texture = cor
	material.normal_enabled = true
	material.normal_texture = relevo
	material.roughness = 0.95
	material.uv1_scale = Vector3(2.0, 1.0, 2.0)
	return material


func _aplicar_camera(i: int) -> void:
	var posicoes: Array[Vector3] = [Vector3(10.0, 8.0, -14.0), Vector3(-13.0, 8.0, -9.0), Vector3(-4.0, 9.0, 34.0)]
	var alvos: Array[Vector3] = [Vector3(0.0, 1.5, 3.0), Vector3(0.0, 1.5, 0.0), Vector3(0.0, 1.0, 8.0)]
	var campos: Array[float] = [40.0, 40.0, 45.0]
	_camera.position = posicoes[i]
	_camera.fov = campos[i]
	_camera.look_at(alvos[i], Vector3.UP)


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

	var chao: MeshInstance3D = MeshInstance3D.new()
	var plano: PlaneMesh = PlaneMesh.new()
	plano.size = Vector2(TAMANHO_CHAO, TAMANHO_CHAO)
	chao.mesh = plano
	var material_chao: StandardMaterial3D = StandardMaterial3D.new()
	material_chao.albedo_color = Color(0.3, 0.45, 0.25)
	chao.material_override = material_chao
	add_child(chao)

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
