extends SceneTree
## Teste headless. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_dnd_rules.gd
## Sai com código 0 se tudo passar, 1 se alguma asserção falhar.

var _failures: int = 0


func _initialize() -> void:
	_check(DndRules.ability_modifier(10) == 0, "mod 10 = 0")
	_check(DndRules.ability_modifier(9) == -1, "mod 9 = -1")
	_check(DndRules.ability_modifier(1) == -5, "mod 1 = -5")
	_check(DndRules.ability_modifier(20) == 5, "mod 20 = +5")

	_check(DndRules.proficiency_bonus(1) == 2, "prof nível 1 = +2")
	_check(DndRules.proficiency_bonus(5) == 3, "prof nível 5 = +3")
	_check(DndRules.proficiency_bonus(9) == 4, "prof nível 9 = +4")
	_check(DndRules.proficiency_bonus(17) == 6, "prof nível 17 = +6")

	_check(DndRules.level_for_xp(0, 5) == 1, "0 XP = nível 1")
	_check(DndRules.level_for_xp(300, 5) == 2, "300 XP = nível 2")
	_check(DndRules.level_for_xp(6500, 5) == 5, "6500 XP = nível 5")
	_check(DndRules.level_for_xp(999999, 5) == 5, "teto do MVP respeitado (nível 5)")

	_check(DndRules.mitigated_damage(100, 100, 100) == 50, "defesa = K reduz à metade")
	_check(DndRules.mitigated_damage(100, 0, 100) == 100, "defesa 0 não reduz")
	_check(DndRules.mitigated_damage(10, 1000000, 100) >= 0, "defesa enorme não gera dano negativo")
	_check(DndRules.mitigated_damage(0, 50) == 0, "dano 0 = 0")

	_check(DndRules.clamp_resistance(90.0) == 75.0, "resistência limitada a 75%")
	_check(DndRules.clamp_resistance(-150.0) == -100.0, "vulnerabilidade limitada a -100%")

	if _failures == 0:
		print("OK: todos os testes de regra passaram.")
		quit(0)
	else:
		print("FALHAS: ", _failures)
		quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures += 1
		printerr("FALHOU: ", label)
