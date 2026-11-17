class_name MenuPausa
extends Control
## Menu de pausa: fundo escuro semitransparente e chapa central com
## Continuar, Inventário, Ficha, Opções e Sair para o menu.
## Uso: MenuPausa.abrir(pai). Quem abre decide se pausa a árvore.

const OPTIONS_SCENE := "res://scenes/options.tscn"
const LOGIN_SCENE := "res://scenes/login.tscn"
const COR_FUNDO := Color(0, 0, 0, 0.7)
const TAMANHO_CHAPA := Vector2(440, 520)
const TAMANHO_BOTAO := Vector2(280, 52)

## Perfil do personagem ativo (mesmo formato do ProfileStore). Vazio = nenhum ativo.
## Quem controla a sessão define isto antes de abrir o menu.
static var perfil_ativo: Dictionary = {}
## Inventário atual. Vazio por enquanto (sem sistema de itens ainda).
static var inventario_atual: Dictionary = {}

var _aviso: Label


## Cria o menu, adiciona como filho de `pai` e devolve a instância.
static func abrir(pai: Node) -> MenuPausa:
	var menu := MenuPausa.new()
	pai.add_child(menu)
	return menu


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS

	var fundo := ColorRect.new()
	fundo.color = COR_FUNDO
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	var chapa := UiKit.chapa(TAMANHO_CHAPA)
	centro.add_child(chapa)
	var miolo := UiKit.miolo(chapa)
	miolo.add_theme_constant_override("separation", 8)
	miolo.add_child(UiKit.titulo(UiText.t("menu_titulo"), 30))

	_adicionar_botao(miolo, "menu_continuar", queue_free)
	_adicionar_botao(miolo, "menu_inventario", _abrir_inventario)
	_adicionar_botao(miolo, "menu_ficha", _abrir_ficha)
	_adicionar_botao(miolo, "menu_opcoes", _abrir_opcoes)
	_adicionar_botao(miolo, "menu_sair", _sair_para_menu)

	_aviso = UiKit.texto("", 16, UiKit.COR_TEXTO_DESTAQUE)
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	miolo.add_child(_aviso)


func _adicionar_botao(caixa: VBoxContainer, chave: String, acao: Callable) -> void:
	var b := UiKit.botao(UiText.t(chave), 26.0, TAMANHO_BOTAO)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(acao)
	caixa.add_child(b)


func _abrir_inventario() -> void:
	var tela := InventarioView.new()
	tela.configurar(inventario_atual)
	add_child(tela)


func _abrir_ficha() -> void:
	if not FichaPersonagem.perfil_completo(perfil_ativo):
		_aviso.text = UiText.t("menu_sem_personagem")
		return
	_aviso.text = ""
	var tela := FichaPersonagem.new()
	tela.configurar(perfil_ativo)
	add_child(tela)


func _abrir_opcoes() -> void:
	_mudar_cena(OPTIONS_SCENE)


func _sair_para_menu() -> void:
	_mudar_cena(LOGIN_SCENE)


func _mudar_cena(caminho: String) -> void:
	# Garante que a árvore não fique pausada na outra cena.
	get_tree().paused = false
	get_tree().change_scene_to_file(caminho)
