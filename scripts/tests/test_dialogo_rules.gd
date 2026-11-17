extends SceneTree
## Teste headless das regras de diálogo. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_dialogo_rules.gd

var _failures: int = 0


func _initialize() -> void:
	var arvore: Dictionary = {
		"inicio": "n1",
		"nos": {
			"n1": {"texto": "Olá.", "opcoes": [
				{"texto": "Sempre", "proximo": "n2"},
				{"texto": "Só se x", "proximo": "n3", "condicao": {"flag": "x", "valor": true}},
				{"texto": "Marca y", "proximo": "n2", "efeito": {"flag": "y", "valor": 5}},
			]},
			"n2": {"texto": "Fim.", "opcoes": []},
			"n3": {"texto": "Secreto.", "opcoes": []},
		},
	}
	var no1: Dictionary = arvore["nos"]["n1"]

	var sem_flags: Array = DialogoRules.opcoes_disponiveis(no1, {})
	_check(sem_flags.size() == 2, "sem flags: condição falha e opção some")
	_check(sem_flags[0]["texto"] == "Sempre", "opção sem condição sempre aparece")

	var com_x: Array = DialogoRules.opcoes_disponiveis(no1, {"x": true})
	_check(com_x.size() == 3, "condição satisfeita mostra a opção")
	var x_falso: Array = DialogoRules.opcoes_disponiveis(no1, {"x": false})
	_check(x_falso.size() == 2, "flag com valor diferente esconde a opção")

	var r1: Dictionary = DialogoRules.escolher(arvore, "n1", {}, 0)
	_check(r1["proximo"] == "n2", "escolher devolve o próximo nó")

	var original: Dictionary = {"a": 1}
	var r2: Dictionary = DialogoRules.escolher(arvore, "n1", original, 1)
	_check(r2["proximo"] == "n2", "índice 1 sem x é a opção de efeito")
	_check(r2["flags"]["y"] == 5, "efeito grava a flag")
	_check(r2["flags"]["a"] == 1, "efeito preserva flags existentes")
	_check(not original.has("y"), "dicionário original não é alterado")

	var r3: Dictionary = DialogoRules.escolher(arvore, "n1", {"x": true}, 1)
	_check(r3["proximo"] == "n3", "índice conta só opções disponíveis")

	var r4: Dictionary = DialogoRules.escolher(arvore, "n1", {}, 9)
	_check(r4["proximo"] == "", "índice acima do limite: proximo vazio")
	var r5: Dictionary = DialogoRules.escolher(arvore, "n1", {}, -1)
	_check(r5["proximo"] == "", "índice negativo: proximo vazio")
	var r6: Dictionary = DialogoRules.escolher(arvore, "nada", {"a": 1}, 0)
	_check(r6["proximo"] == "", "nó inexistente: proximo vazio")
	_check(r6["flags"]["a"] == 1, "nó inexistente mantém as flags")

	_check(DialogoRules.terminou(arvore, "n2"), "nó sem opções encerra")
	_check(not DialogoRules.terminou(arvore, "n1"), "nó com opções não encerra")
	_check(DialogoRules.terminou(arvore, "nada"), "nó inexistente encerra")

	if _failures == 0:
		print("OK: todos os testes de diálogo passaram.")
		quit(0)
	else:
		print("FALHAS: ", _failures)
		quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures += 1
		printerr("FALHOU: ", label)
