extends Control
## Menu frontal do login: chapa com rebite e dois botões de letras (Entrar e Opções).
## O fundo vem de scenes/ui/login_background.tscn. Sem usuário e senha por enquanto.

const PROFILE_SCENE := "res://scenes/profile_select.tscn"
const OPTIONS_SCENE := "res://scenes/options.tscn"
const MAP_SCENE := "res://scenes/mapa.tscn"


func _ready() -> void:
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	var chapa := UiKit.chapa(Vector2(440, 400))
	centro.add_child(chapa)
	var caixa := UiKit.miolo(chapa)
	caixa.add_theme_constant_override("separation", 22)

	var entrar := UiKit.botao(UiText.t("entrar"), 48.0, Vector2(240, 64))
	entrar.pressed.connect(func() -> void: get_tree().change_scene_to_file(PROFILE_SCENE))
	caixa.add_child(entrar)

	var mapa := UiKit.botao(UiText.t("mapa"), 48.0, Vector2(240, 64))
	mapa.pressed.connect(func() -> void: get_tree().change_scene_to_file(MAP_SCENE))
	caixa.add_child(mapa)

	var opcoes := UiKit.botao(UiText.t("opcoes"), 48.0, Vector2(240, 64))
	opcoes.pressed.connect(func() -> void: get_tree().change_scene_to_file(OPTIONS_SCENE))
	caixa.add_child(opcoes)
