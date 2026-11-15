extends Control
## Tela de login do Project BB, sem usuário e senha por enquanto:
## o jogo roda local ou no navegador, sem banco centralizado.
## Entrar abre o teste de regras; Opções ainda não tem tela.

const MAIN_SCENE := "res://scenes/main.tscn"
const HOVER_TINT := Color(1.25, 1.15, 0.9)

@onready var _entrar: Button = $Frame/Art/Entrar
@onready var _opcoes: Button = $Frame/Art/Opcoes

var _aviso: Label


func _ready() -> void:
	_entrar.pressed.connect(_on_entrar)
	_opcoes.pressed.connect(_on_opcoes)
	for botao: Button in [_entrar, _opcoes]:
		botao.mouse_entered.connect(func() -> void: botao.modulate = HOVER_TINT)
		botao.mouse_exited.connect(func() -> void: botao.modulate = Color.WHITE)

	_aviso = Label.new()
	_aviso.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_aviso.offset_top = -48.0
	_aviso.offset_bottom = -16.0
	_aviso.add_theme_font_size_override("font_size", 18)
	_aviso.visible = false
	add_child(_aviso)


func _on_entrar() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE)


func _on_opcoes() -> void:
	_aviso.text = "Opções: em breve."
	_aviso.visible = true
