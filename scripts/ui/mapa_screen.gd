extends Control
## Tela de mapa: mostra o mapa-múndi de Aurel dentro da chapa com rebite. Acessada pelo menu de entrada.

const LOGIN_SCENE := "res://scenes/login.tscn"
const MAPA := "res://assets/ui/mapa/mapa_mundo_aurel.jpg"
const LARGURA_MAPA: float = 600.0


func _ready() -> void:
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	var chapa := UiKit.chapa(Vector2(800, 640))
	centro.add_child(chapa)
	var caixa := UiKit.miolo(chapa)
	caixa.add_theme_constant_override("separation", 14)

	caixa.add_child(UiKit.letras(UiText.t("mapa"), 40.0, 600.0))

	var imagem := TextureRect.new()
	imagem.texture = load(MAPA)
	imagem.custom_minimum_size = Vector2(LARGURA_MAPA, LARGURA_MAPA * 768.0 / 1376.0)
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagem.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caixa.add_child(imagem)

	var voltar := UiKit.botao(UiText.t("voltar"), 40.0, Vector2(220, 52))
	voltar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	voltar.pressed.connect(func() -> void: get_tree().change_scene_to_file(LOGIN_SCENE))
	caixa.add_child(voltar)
