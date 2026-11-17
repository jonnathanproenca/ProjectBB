class_name InventarioRules
extends RefCounted
## Regras puras do inventário (sem nós de cena), para teste headless.
## O inventário é um Dictionary de item_id (String) para quantidade (int, sempre > 0).


## Devolve uma cópia com `quantidade` unidades a mais de `item_id`.
## Quantidade zero ou negativa, ou id vazio, não altera nada.
static func adicionar(inv: Dictionary, item_id: String, quantidade: int) -> Dictionary:
	var novo: Dictionary = inv.duplicate()
	if quantidade <= 0 or item_id.is_empty():
		return novo
	novo[item_id] = InventarioRules.quantidade(inv, item_id) + quantidade
	return novo


## Devolve uma cópia com `quantidade` unidades a menos de `item_id`.
## Nunca fica negativo: remover além do que existe zera e tira a chave.
## Quantidade zero ou negativa não altera nada.
static func remover(inv: Dictionary, item_id: String, quantidade: int) -> Dictionary:
	var novo: Dictionary = inv.duplicate()
	if quantidade <= 0 or not novo.has(item_id):
		return novo
	var restante: int = InventarioRules.quantidade(inv, item_id) - quantidade
	if restante <= 0:
		novo.erase(item_id)
	else:
		novo[item_id] = restante
	return novo


## Quantidade de `item_id` no inventário (0 se não existir).
static func quantidade(inv: Dictionary, item_id: String) -> int:
	return maxi(0, int(inv.get(item_id, 0)))
