class_name CasaVila
extends Node3D
## Casa de vila montada com peças do kit Medieval Village MegaKit (Quaternius, CC0).
## Peças em metros (1 unidade = 1 m), eixo Y para cima. Cada peça tem o próprio pivô.
## Posições validadas no Blender (eixo Y do glTF = profundidade no Blender). Ver ADR-072.
## Pendência: o telhado ainda não fecha no cume; revisar antes de usar em arena.

const PASTA: String = "res://assets/vila_3d/"

const PECAS: Array = [
	{"arquivo": "Floor_WoodDark", "posicao": Vector3(0.0, 0.0, 0.0), "rotacao_y": 0.0},
	{"arquivo": "Wall_Plaster_Door_Flat", "posicao": Vector3(0.0, 0.0, -0.91), "rotacao_y": 0.0},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(0.0, 0.0, 0.91), "rotacao_y": 180.0},
	{"arquivo": "Wall_Plaster_Window_Wide_Flat", "posicao": Vector3(-0.91, 0.0, 0.0), "rotacao_y": -90.0},
	{"arquivo": "Wall_Plaster_Straight", "posicao": Vector3(0.91, 0.0, 0.0), "rotacao_y": 90.0},
	{"arquivo": "Roof_Wooden_2x1", "posicao": Vector3(0.0, 3.0, -0.78), "rotacao_y": 0.0},
	{"arquivo": "Roof_Wooden_2x1", "posicao": Vector3(0.0, 3.0, 0.78), "rotacao_y": 180.0},
	{"arquivo": "Prop_Crate", "posicao": Vector3(1.9, 0.0, -1.3), "rotacao_y": -20.0},
]


func _ready() -> void:
	_configurar_luz_e_camera()
	for peca in PECAS:
		var caminho: String = PASTA + str(peca["arquivo"]) + ".gltf"
		var cena: PackedScene = load(caminho) as PackedScene
		if cena == null:
			push_warning("Peça da vila não encontrada: %s" % caminho)
			continue
		var no: Node3D = cena.instantiate() as Node3D
		no.position = peca["posicao"]
		no.rotation_degrees = Vector3(0.0, float(peca["rotacao_y"]), 0.0)
		add_child(no)


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
	camera.position = Vector3(7.0, 6.0, 7.0)
	add_child(camera)
	camera.current = true
	camera.look_at(Vector3(0.0, 1.4, 0.0), Vector3.UP)
