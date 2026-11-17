class_name DialogoView
extends Control
## Painel de diálogo na parte de baixo da tela. Criado por código (sem .tscn):
##   var v := DialogoView.iniciar(self, DialogoPrologo.arvore_inicial(), flags)
##   v.concluido.connect(func(novas: Dictionary) -> void: flags = novas)
## Regras em scripts/rules/dialogo_rules.gd.

## Emitido ao fim da conversa, com as flags alteradas.
signal concluido(flags: Dictionary)

const ALTURA_PAINEL: float = 240.0
const MARGEM: int = 20
const LARGURA_BOTAO: float = 640.0
const ALTURA_BOTAO: float = 28.0

var _arvore: Dictionary = {}
var _flags: Dictionary = {}
var _no_atual: String = ""
var _conteudo: VBoxContainer
var _encerrado: bool = false


## Cria a view, adiciona ao `pai` e começa no nó "inicio" da árvore.
static func iniciar(pai: Node, arvore: Dictionary, flags: Dictionary) -> DialogoView:
	var view := DialogoView.new()
	view._arvore = arvore
	view._flags = flags.duplicate(true)
	view._no_atual = str(arvore.get("inicio", ""))
	pai.add_child(view)
	return view


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	offset_top = -ALTURA_PAINEL
	mouse_filter = Control.MOUSE_FILTER_STOP

	var fundo := ColorRect.new()
	fundo.color = Color(0.05, 0.04, 0.04, 0.85)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)

	var margem := MarginContainer.new()
	margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margem.add_theme_constant_override("margin_left", MARGEM)
	margem.add_theme_constant_override("margin_right", MARGEM)
	margem.add_theme_constant_override("margin_top", MARGEM)
	margem.add_theme_constant_override("margin_bottom", MARGEM)
	add_child(margem)

	_conteudo = VBoxContainer.new()
	_conteudo.add_theme_constant_override("separation", 8)
	margem.add_child(_conteudo)

	_mostrar_no()


func _mostrar_no() -> void:
	for filho in _conteudo.get_children():
		_conteudo.remove_child(filho)
		filho.queue_free()

	var nos: Dictionary = _arvore.get("nos", {})
	if not nos.has(_no_atual):
		_encerrar()
		return
	var no: Dictionary = nos[_no_atual]

	var paragrafo: Label = UiKit.texto(str(no.get("texto", "")))
	paragrafo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	paragrafo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_conteudo.add_child(paragrafo)

	if DialogoRules.terminou(_arvore, _no_atual):
		var fechar: Button = UiKit.botao("Continuar", 22.0, Vector2(LARGURA_BOTAO, ALTURA_BOTAO))
		fechar.pressed.connect(_encerrar)
		_conteudo.add_child(fechar)
		return

	var opcoes: Array = DialogoRules.opcoes_disponiveis(no, _flags)
	if opcoes.is_empty():
		# Todas as opções foram filtradas por condição: nada a escolher.
		var sair: Button = UiKit.botao("Continuar", 22.0, Vector2(LARGURA_BOTAO, ALTURA_BOTAO))
		sair.pressed.connect(_encerrar)
		_conteudo.add_child(sair)
		return

	for i in range(opcoes.size()):
		var opcao: Dictionary = opcoes[i]
		var botao: Button = UiKit.botao(str(opcao.get("texto", "...")), 22.0, Vector2(LARGURA_BOTAO, ALTURA_BOTAO))
		botao.pressed.connect(_ao_escolher.bind(i))
		_conteudo.add_child(botao)


func _ao_escolher(indice: int) -> void:
	var r: Dictionary = DialogoRules.escolher(_arvore, _no_atual, _flags, indice)
	_flags = r["flags"]
	var proximo: String = str(r["proximo"])
	if proximo == "":
		_encerrar()
		return
	_no_atual = proximo
	_mostrar_no()


func _encerrar() -> void:
	if _encerrado:
		return
	_encerrado = true
	concluido.emit(_flags)
	queue_free()
