class_name CombatRules
extends RefCounted
## Regras puras de combate (sem nós de cena), para teste headless.
## Valores aprovados: 1 casa = 1,5 m; diagonal conta como 1 casa (docs/COMBATE.md).

const SQUARE_METERS: float = 1.5


## Converte metros em casas inteiras (arredonda para baixo).
static func meters_to_squares(meters: float) -> int:
	return int(floor(meters / SQUARE_METERS + 0.0001))


## Casas alcançáveis a partir de `start` com `budget` casas de movimento.
## Vizinhança de 8 direções, diagonal custa 1. Retorna { Vector2i: custo }.
static func reachable(start: Vector2i, budget: int, blocked: Dictionary, size: Vector2i) -> Dictionary:
	var cost: Dictionary = {start: 0}
	var frontier: Array[Vector2i] = [start]
	var head: int = 0
	while head < frontier.size():
		var cell: Vector2i = frontier[head]
		head += 1
		var current: int = cost[cell]
		if current >= budget:
			continue
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				if dx == 0 and dy == 0:
					continue
				var nxt: Vector2i = cell + Vector2i(dx, dy)
				if nxt.x < 0 or nxt.y < 0 or nxt.x >= size.x or nxt.y >= size.y:
					continue
				if blocked.has(nxt) or cost.has(nxt):
					continue
				cost[nxt] = current + 1
				frontier.append(nxt)
	return cost


## Ordem de iniciativa: maior rolagem primeiro.
## Entradas: [{ "name": String, "roll": int }, ...]. Empates: resolver por Destreza no M1.
static func order_by_initiative(entries: Array) -> Array:
	var ordered: Array = entries.duplicate()
	ordered.sort_custom(func(a, b): return a["roll"] > b["roll"])
	return ordered
