class_name InventarioView
extends Control
## Tela de inventário: lista os itens (nome, quantidade e descrição) e tem botão Voltar.
## Overlay: se remove sozinho ao voltar. Uso:
##   var tela := InventarioView.new()
##   tela.configurar(inventario)   # Dictionary item_id -> quantidade
##   pai.add_child(tela)

const COR_FUNDO := Color(0, 0, 0, 0.82)
const TAMANHO_CHAPA := Vector2(640, 560)
const TAMANHO_BOTAO := Vector2(200, 52)
const LARGURA_LISTA: float = 440.0

var _inventario: Dictionary = {}


## Define o inventário mostrado. Chamar antes de add_child.
func configurar(inventario: Dictionary) -> void:
	_inventario = inventario


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

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
	miolo.alignment = BoxContainer.ALIGNMENT_BEGIN
	miolo.add_theme_constant_override("separation", 12)
	miolo.add_child(UiKit.titulo(UiText.t("inventario_titulo"), 30))

	var rolagem := ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.mouse_filter = Control.MOUSE_FILTER_PASS
	miolo.add_child(rolagem)

	var lista := VBoxContainer.new()
	lista.add_theme_constant_override("separation", 10)
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rolagem.add_child(lista)
	_preencher(lista)

	var voltar := UiKit.botao(UiText.t("voltar"), 26.0, TAMANHO_BOTAO)
	voltar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	voltar.pressed.connect(queue_free)
	miolo.add_child(voltar)


func _preencher(lista: VBoxContainer) -> void:
	var catalogo: Dictionary = CatalogoItens.itens()
	var ids: Array = _inventario.keys()
	ids.sort()
	var mostrados: int = 0
	for id in ids:
		var qtd: int = InventarioRules.quantidade(_inventario, str(id))
		if qtd <= 0:
			continue
		mostrados += 1
		# Id fora do catálogo não quebra a tela: mostra o próprio id e sem descrição.
		var dados: Dictionary = catalogo.get(str(id), {})
		var nome: String = str(dados.get("nome", str(id)))
		var descricao: String = str(dados.get("descricao", ""))

		var linha := VBoxContainer.new()
		linha.add_theme_constant_override("separation", 2)
		linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cabecalho := UiKit.texto("%s  (%s %d)" % [nome, UiText.t("inventario_qtd"), qtd], 20, UiKit.COR_TEXTO_DESTAQUE, LARGURA_LISTA)
		linha.add_child(cabecalho)
		if not descricao.is_empty():
			linha.add_child(UiKit.texto(descricao, 16, UiKit.COR_TEXTO, LARGURA_LISTA))
		lista.add_child(linha)

	if mostrados == 0:
		var vazio := UiKit.texto(UiText.t("inventario_vazio"), 20, UiKit.COR_TEXTO, LARGURA_LISTA)
		vazio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lista.add_child(vazio)
