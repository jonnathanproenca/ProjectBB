extends SceneTree
## Teste headless das regras de quest. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_quest_rules.gd

var _failures: int = 0


func _initialize() -> void:
	_check(QuestRules.estado({}, "carta") == "nao_iniciada", "estado padrão é nao_iniciada")
	_check(QuestRules.chave("carta") == "quest_carta", "chave usa o prefixo quest_")

	var original: Dictionary = {"outra": true}
	var ativa: Dictionary = QuestRules.atualizar(original, "carta", "ativa")
	_check(QuestRules.estado(ativa, "carta") == "ativa", "atualizar para ativa")
	_check(ativa["outra"] == true, "atualizar preserva outras flags")
	_check(not original.has("quest_carta"), "atualizar não altera o original")

	var feita: Dictionary = QuestRules.atualizar(ativa, "carta", "concluida")
	_check(QuestRules.estado(feita, "carta") == "concluida", "atualizar para concluida")

	var invalida: Dictionary = QuestRules.atualizar(ativa, "carta", "voando")
	_check(QuestRules.estado(invalida, "carta") == "ativa", "estado inválido é ignorado")
	var invalida2: Dictionary = QuestRules.atualizar({}, "carta", "voando")
	_check(QuestRules.estado(invalida2, "carta") == "nao_iniciada", "inválido em flags vazias mantém padrão")

	_check(QuestRules.estado({"quest_carta": "lixo"}, "carta") == "nao_iniciada", "valor corrompido volta ao padrão")
	_check(QuestRules.estado(ativa, "outra_quest") == "nao_iniciada", "quest diferente não é afetada")

	if _failures == 0:
		print("OK: todos os testes de quest passaram.")
		quit(0)
	else:
		print("FALHAS: ", _failures)
		quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures += 1
		printerr("FALHOU: ", label)
