class_name CasaVila
extends Node3D
## Casa de vila montada com peças do kit Medieval Village MegaKit (Quaternius, CC0).
## Peças em metros (1 unidade = 1 m), eixo Y para cima. Cada peça tem o próprio pivô.
## Posições validadas no Blender (eixo Y do glTF = profundidade no Blender). Ver ADR-072 e ADR-073.
## Telhado de duas águas: cada peça tem a borda alta no cume (z = 0) e a borda baixa no topo da parede (y = 3,12).

const PASTA: String = "res://assets/vila_3d/"

## Casa de 8 x 3 m (24 m²) com dois cômodos: passagem central na divisória, porta na fachada frontal.
## "escala" estica peças de parede e o chão (eixo X = comprimento da peça, Z = profundidade do chão).
const PECAS: Array = [
	{"arquivo": "Floor_WoodDark", "posicao": Vector3(0.0, 0.0, 0.0), "rotacao_y": 0.0, "escala": Vector3(4.0, 1.0, 1.5)},
	{"arquivo": "Wall_Plaster_Door_Flat", "posicao": Vector3(-3.0, 0.0, -1.5), "rotacao_y": 0.0, "escala": Vector3.ONE},
	{"arquivo": "Door_1_Flat", "posicao": Vector3(-3.51, 0.0, -1.61), "rotacao_y": 0.0, "escala": Vector3.ONE},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(-1.0, 0.0, -1.5), "rotacao_y": 0.0, "escala": Vector3.ONE},
	{"arquivo": "Wall_Plaster_Window_Wide_Flat", "posicao": Vector3(1.0, 0.0, -1.5), "rotacao_y": 0.0, "escala": Vector3.ONE},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(3.0, 0.0, -1.5), "rotacao_y": 0.0, "escala": Vector3.ONE},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(-3.0, 0.0, 1.5), "rotacao_y": 180.0, "escala": Vector3.ONE},
	{"arquivo": "Wall_Plaster_Window_Wide_Flat", "posicao": Vector3(-1.0, 0.0, 1.5), "rotacao_y": 180.0, "escala": Vector3.ONE},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(1.0, 0.0, 1.5), "rotacao_y": 180.0, "escala": Vector3.ONE},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(3.0, 0.0, 1.5), "rotacao_y": 180.0, "escala": Vector3.ONE},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(-4.0, 0.0, -0.75), "rotacao_y": -90.0, "escala": Vector3(0.75, 1.0, 1.0)},
	{"arquivo": "Wall_Plaster_Window_Wide_Flat", "posicao": Vector3(-4.0, 0.0, 0.75), "rotacao_y": -90.0, "escala": Vector3(0.75, 1.0, 1.0)},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(4.0, 0.0, -0.75), "rotacao_y": 90.0, "escala": Vector3(0.75, 1.0, 1.0)},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(4.0, 0.0, 0.75), "rotacao_y": 90.0, "escala": Vector3(0.75, 1.0, 1.0)},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(0.0, 0.0, -1.0), "rotacao_y": 90.0, "escala": Vector3(0.5, 1.0, 1.0)},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(0.0, 0.0, 1.0), "rotacao_y": 90.0, "escala": Vector3(0.5, 1.0, 1.0)},
	{"arquivo": "Prop_Crate", "posicao": Vector3(5.2, 0.0, -1.8), "rotacao_y": -20.0, "escala": Vector3.ONE},
]


func _ready() -> void:
	_configurar_luz_e_camera()
	add_child(criar_telhado())
	for peca in PECAS:
		var caminho: String = PASTA + str(peca["arquivo"]) + ".gltf"
		var cena: PackedScene = load(caminho) as PackedScene
		if cena == null:
			push_warning("Peça da vila não encontrada: %s" % caminho)
			continue
		var no: Node3D = cena.instantiate() as Node3D
		no.position = peca["posicao"]
		no.rotation_degrees = Vector3(0.0, float(peca["rotacao_y"]), 0.0)
		no.scale = peca["escala"]
		add_child(no)


## Telhado de duas águas como uma malha única (sem emendas), com empenas nas duas pontas.
## Beiral em y = 3,12 sobre as paredes; cumeeira em y = 4,12. Sobra de 0,4 m nas pontas e nas laterais.
static func criar_telhado() -> MeshInstance3D:
	var meia_x: float = 4.4
	var meia_z: float = 1.9
	var beiral: float = 3.12
	var cumeeira: float = 4.12
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var normal_frente: Vector3 = Vector3(0.0, 1.0, -0.5).normalized()
	var normal_fundo: Vector3 = Vector3(0.0, 1.0, 0.5).normalized()
	var a: Vector3 = Vector3(-meia_x, beiral, -meia_z)
	var b: Vector3 = Vector3(meia_x, beiral, -meia_z)
	var c: Vector3 = Vector3(meia_x, cumeeira, 0.0)
	var d: Vector3 = Vector3(-meia_x, cumeeira, 0.0)
	var e: Vector3 = Vector3(meia_x, beiral, meia_z)
	var f: Vector3 = Vector3(-meia_x, beiral, meia_z)
	for v in [a, b, c, a, c, d]:
		_vertice_telhado(st, v, normal_frente)
	for v in [d, c, e, d, e, f]:
		_vertice_telhado(st, v, normal_fundo)
	for v in [a, f, d, b, c, e]:
		var normal_empena: Vector3 = Vector3(-1.0, 0.0, 0.0) if v.x < 0.0 else Vector3(1.0, 0.0, 0.0)
		_vertice_telhado(st, v, normal_empena)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = load("res://assets/vila_3d/T_WoodTrim_BaseColor.png") as Texture2D
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 0.9
	var telhado: MeshInstance3D = MeshInstance3D.new()
	telhado.mesh = st.commit()
	telhado.material_override = material
	telhado.name = "Telhado"
	return telhado


static func _vertice_telhado(st: SurfaceTool, v: Vector3, normal: Vector3) -> void:
	st.set_normal(normal)
	st.set_uv(Vector2(v.x, v.z) * 0.5)
	st.add_vertex(v)


func _configurar_luz_e_camera() -> void:
	var ambiente := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.07, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 1.0, 1.0)
	env.ambient_light_energy = 0.8
	ambiente.environment = env
	add_child(ambiente)

	var sol := DirectionalLight3D.new()
	sol.rotation_degrees = Vector3(-50.0, -30.0, 0.0)
	add_child(sol)

	var camera := Camera3D.new()
	camera.position = Vector3(11.0, 8.0, 10.0)
	add_child(camera)
	camera.current = true
	camera.look_at(Vector3(0.0, 1.4, 0.0), Vector3.UP)
