extends SceneTree
## Teste headless. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_inventario_rules.gd
## Sai com código 0 se tudo passar, 1 se alguma asserção falhar.

var _failures: int = 0


func _initialize() -> void:
	var vazio: Dictionary = {}

	# adicionar
	var a: Dictionary = InventarioRules.adicionar(vazio, "adaga", 2)
	_check(InventarioRules.quantidade(a, "adaga") == 2, "adicionar 2 adagas em inventário vazio")
	_check(vazio.is_empty(), "adicionar não altera o original")
	var b: Dictionary = InventarioRules.adicionar(a, "adaga", 3)
	_check(InventarioRules.quantidade(b, "adaga") == 5, "adicionar soma com o existente")
	_check(InventarioRules.quantidade(a, "adaga") == 2, "adicionar devolve cópia")

	# quantidade zero e negativa
	_check(InventarioRules.adicionar(a, "adaga", 0) == a, "adicionar 0 não altera")
	_check(InventarioRules.adicionar(a, "adaga", -3) == a, "adicionar negativo não altera")
	_check(InventarioRules.adicionar(vazio, "adaga", 0).is_empty(), "adicionar 0 não cria chave")
	_check(InventarioRules.remover(a, "adaga", 0) == a, "remover 0 não altera")
	_check(InventarioRules.remover(a, "adaga", -1) == a, "remover negativo não altera")

	# remover
	var c: Dictionary = InventarioRules.remover(b, "adaga", 2)
	_check(InventarioRules.quantidade(c, "adaga") == 3, "remover 2 de 5 sobra 3")
	var d: Dictionary = InventarioRules.remover(c, "adaga", 3)
	_check(not d.has("adaga"), "remover tudo tira a chave")
	_check(InventarioRules.quantidade(d, "adaga") == 0, "quantidade de item removido = 0")

	# remoção além do que existe
	var e: Dictionary = InventarioRules.remover(a, "adaga", 99)
	_check(not e.has("adaga"), "remover além do que existe tira a chave")
	_check(InventarioRules.quantidade(e, "adaga") == 0, "remover além do que existe não fica negativo")
	_check(InventarioRules.remover(vazio, "adaga", 1).is_empty(), "remover item inexistente não cria chave")

	# quantidade
	_check(InventarioRules.quantidade(vazio, "nada") == 0, "quantidade de item ausente = 0")

	# catálogo
	_check(CatalogoItens.itens().size() >= 5, "catálogo tem ao menos 5 itens")
	for id in CatalogoItens.itens():
		var item: Dictionary = CatalogoItens.itens()[id]
		_check(not str(item.get("nome", "")).is_empty() and not str(item.get("descricao", "")).is_empty(), "item %s tem nome e descrição" % id)

	if _failures == 0:
		print("OK: todos os testes de inventário passaram.")
		quit(0)
	else:
		print("FALHAS: ", _failures)
		quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures += 1
		printerr("FALHOU: ", label)
