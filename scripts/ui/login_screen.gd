extends Control
## Menu frontal do login: Entrar e Opções. O fundo vem de scenes/ui/login_background.tscn.
## Sem usuário e senha por enquanto. Entrar vai à seleção de perfil.

const PROFILE_SCENE := "res://scenes/profile_select.tscn"
const OPTIONS_SCENE := "res://scenes/options.tscn"
const HOVER_TINT := Color(1.25, 1.15, 0.9)

@onready var _entrar: Button = $Menu/Entrar
@onready var _opcoes: Button = $Menu/Opcoes


func _ready() -> void:
	_entrar.text = UiText.t("entrar")
	_opcoes.text = UiText.t("opcoes")
	_entrar.pressed.connect(func() -> void: get_tree().change_scene_to_file(PROFILE_SCENE))
	_opcoes.pressed.connect(func() -> void: get_tree().change_scene_to_file(OPTIONS_SCENE))
	for botao: Button in [_entrar, _opcoes]:
		botao.mouse_entered.connect(func() -> void: botao.modulate = HOVER_TINT)
		botao.mouse_exited.connect(func() -> void: botao.modulate = Color.WHITE)
