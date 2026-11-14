extends SceneTree
## Teste headless das regras de combate. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_combat_rules.gd

var _failures: int = 0


func _initialize() -> void:
	_check(CombatRules.meters_to_squares(9.0) == 6, "9 m = 6 casas")
	_check(CombatRules.meters_to_squares(1.4) == 0, "1,4 m = 0 casas")
	_check(CombatRules.meters_to_squares(1.5) == 1, "1,5 m = 1 casa")
	_check(CombatRules.meters_to_squares(4.5) == 3, "4,5 m = 3 casas")

	var open_area := CombatRules.reachable(Vector2i(0, 0), 2, {}, Vector2i(10, 10))
	_check(open_area.has(Vector2i(2, 2)), "diagonal de 2 casas alcançável")
	_check(open_area[Vector2i(2, 2)] == 2, "diagonal de 2 casas custa 2")
	_check(not open_area.has(Vector2i(3, 0)), "3 casas fora do orçamento de 2")
	_check(open_area.size() == 9, "canto do mapa com 2 casas: 3x3 = 9 células (incluindo origem)")

	var wall: Dictionary = {}
	for y in range(10):
		wall[Vector2i(1, y)] = true
	var walled := CombatRules.reachable(Vector2i(0, 0), 5, wall, Vector2i(10, 10))
	_check(not walled.has(Vector2i(2, 0)), "parede bloqueia a passagem")
	_check(walled.size() == 10, "lado esquerdo da parede tem 10 células")

	var order := CombatRules.order_by_initiative([
		{"name": "a", "roll": 10},
		{"name": "b", "roll": 15},
		{"name": "c", "roll": 12},
	])
	_check(order[0]["name"] == "b", "maior iniciativa primeiro")
	_check(order[2]["name"] == "a", "menor iniciativa por último")

	if _failures == 0:
		print("OK: todos os testes de combate passaram.")
		quit(0)
	else:
		print("FALHAS: ", _failures)
		quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures += 1
		printerr("FALHOU: ", label)
