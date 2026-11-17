class_name MundoView
extends Control
## Exploração do mapa em grade (M2). Desenha retângulos coloridos (sem tilesets),
## move o jogador com setas/WASD, interage com o NPC (E) e abre o menu de pausa (Esc).
## Regras: scripts/rules/exploracao_rules.gd. Dados: scripts/data/mapa_prologo.gd.

const COMBATE_SCENE: String = "res://scenes/combat.tscn"
const AMBIENTE_PATH: String = "res://assets/music/ambiente.ogg"
const CELULA: int = 48
const COR_CHAO: Color = Color(0.20, 0.27, 0.18)
const COR_PAREDE: Color = Color(0.33, 0.30, 0.28)
const COR_JOGADOR: Color = Color(0.25, 0.55, 0.95)
const COR_NPC: Color = Color(0.92, 0.72, 0.20)
const COR_FUNDO: Color = Color(0.07, 0.07, 0.09)

var _mapa: Dictionary = {}
var _jogador: Vector2i = Vector2i.ZERO
var _npc: Vector2i = Vector2i.ZERO
var _flags: Dictionary = {}
var _dialogo_aberto: bool = false
var _menu: MenuPausa = null
var _ambiente: AudioStreamPlayer = null
var _dica: Label = null


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	focus_mode = Control.FOCUS_ALL
	_mapa = MapaPrologo.mapa()
	_jogador = _mapa["inicio"]
	_npc = _mapa["npc"]
	_montar_interface()
	_iniciar_ambiente()
	grab_focus()


func _montar_interface() -> void:
	_dica = Label.new()
	_dica.text = "Setas/WASD: andar | E: falar | Esc: menu"
	_dica.position = Vector2(12, 8)
	_dica.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dica)
	var combate := Button.new()
	combate.text = "Combate"
	combate.position = Vector2(12, 40)
	combate.focus_mode = Control.FOCUS_NONE
	combate.pressed.connect(_ir_para_combate)
	add_child(combate)


## Gancho de ambiente sonoro: só toca se o arquivo existir (ainda não há áudio).
func _iniciar_ambiente() -> void:
	if not ResourceLoader.exists(AMBIENTE_PATH):
		return
	var fluxo: AudioStream = load(AMBIENTE_PATH) as AudioStream
	if fluxo == null:
		return
	if fluxo is AudioStreamOggVorbis:
		(fluxo as AudioStreamOggVorbis).loop = true
	_ambiente = AudioStreamPlayer.new()
	_ambiente.stream = fluxo
	add_child(_ambiente)
	_ambiente.play()


func _ir_para_combate() -> void:
	get_tree().change_scene_to_file(COMBATE_SCENE)


func _origem() -> Vector2:
	var largura: int = _mapa.get("largura", 0)
	var altura: int = _mapa.get("altura", 0)
	var total: Vector2 = Vector2(largura * CELULA, altura * CELULA)
	return ((size - total) / 2.0).floor()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COR_FUNDO)
	if _mapa.is_empty():
		return
	var origem: Vector2 = _origem()
	var largura: int = _mapa["largura"]
	var altura: int = _mapa["altura"]
	for y in range(altura):
		for x in range(largura):
			var cor: Color = COR_PAREDE if ExploracaoRules.eh_parede(_mapa, x, y) else COR_CHAO
			var retangulo := Rect2(origem + Vector2(x * CELULA, y * CELULA), Vector2(CELULA - 1, CELULA - 1))
			draw_rect(retangulo, cor)
	_desenhar_ator(origem, _npc, COR_NPC)
	_desenhar_ator(origem, _jogador, COR_JOGADOR)


func _desenhar_ator(origem: Vector2, celula: Vector2i, cor: Color) -> void:
	var margem: float = 8.0
	var posicao: Vector2 = origem + Vector2(celula.x * CELULA, celula.y * CELULA) + Vector2(margem, margem)
	draw_rect(Rect2(posicao, Vector2(CELULA - 2.0 * margem, CELULA - 2.0 * margem)), cor)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if _dialogo_aberto or is_instance_valid(_menu):
		return
	if not event.is_pressed() or event.is_echo():
		return
	if event.is_action("ui_cancel"):
		_menu = MenuPausa.abrir(self)
		get_viewport().set_input_as_handled()
		return
	var direcao: Vector2i = _direcao_da_tecla(event)
	if direcao != Vector2i.ZERO:
		_mover(direcao)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_E:
		_interagir()
		get_viewport().set_input_as_handled()


func _direcao_da_tecla(event: InputEvent) -> Vector2i:
	if event.is_action("ui_left"):
		return Vector2i(-1, 0)
	if event.is_action("ui_right"):
		return Vector2i(1, 0)
	if event.is_action("ui_up"):
		return Vector2i(0, -1)
	if event.is_action("ui_down"):
		return Vector2i(0, 1)
	if event is InputEventKey:
		match (event as InputEventKey).keycode:
			KEY_A:
				return Vector2i(-1, 0)
			KEY_D:
				return Vector2i(1, 0)
			KEY_W:
				return Vector2i(0, -1)
			KEY_S:
				return Vector2i(0, 1)
	return Vector2i.ZERO


func _mover(direcao: Vector2i) -> void:
	var destino: Vector2i = ExploracaoRules.passo(_mapa, _jogador, direcao)
	if destino == _npc:
		return
	if destino != _jogador:
		_jogador = destino
		queue_redraw()


func _interagir() -> void:
	if not ExploracaoRules.adjacente(_jogador, _npc):
		return
	_dialogo_aberto = true
	var dialogo: DialogoView = DialogoView.iniciar(self, DialogoPrologo.arvore_inicial(), _flags)
	dialogo.concluido.connect(_ao_concluir_dialogo)


func _ao_concluir_dialogo(flags: Dictionary) -> void:
	_flags = flags
	_dialogo_aberto = false
	grab_focus()
