extends SceneTree
## Teste headless das regras de criação de personagem. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_character_rules.gd
## Sai com código 0 se tudo passar, 1 se alguma asserção falhar.

var _failures: int = 0


func _initialize() -> void:
	_check(CharacterRules.validar("humano", "soldado", "guerreiro") == CharacterRules.ERR_NONE, "combinação válida passa")
	_check(CharacterRules.validar("anao", "soldado", "guerreiro") == CharacterRules.ERR_ESPECIE, "espécie fora do MVP é recusada")
	_check(CharacterRules.validar("humano", "desertor", "guerreiro") == CharacterRules.ERR_ORIGEM, "origem fora do MVP é recusada")
	_check(CharacterRules.validar("humano", "soldado", "bardo") == CharacterRules.ERR_CLASSE, "classe fora do MVP é recusada")

	var final_humano: Dictionary = CharacterRules.atributos_finais("humano", "guerreiro")
	_check(final_humano["car"] == 9, "humano dá +1 em Carisma (8 vira 9)")
	_check(final_humano["con"] == 15, "humano dá +1 em Constituição (14 vira 15)")
	_check(final_humano["for"] == 15, "atributo sem bônus de espécie não muda")

	var final_automato: Dictionary = CharacterRules.atributos_finais("automato", "clerigo")
	_check(final_automato["con"] == 16, "autômato dá +2 em Constituição (14 vira 16)")
	_check(final_automato["int"] == 9, "autômato dá +1 em Inteligência (8 vira 9)")

	var final_mestico: Dictionary = CharacterRules.atributos_finais("mestico", "ladino")
	_check(final_mestico["car"] == 14, "mestiço dá +2 em Carisma (12 vira 14)")
	_check(final_mestico["des"] == 16, "mestiço dá +1 em Destreza (15 vira 16)")

	var teto_ok := true
	for especie in CharacterRules.ESPECIES.keys():
		for classe in CharacterRules.CLASSES.keys():
			var final: Dictionary = CharacterRules.atributos_finais(especie, classe)
			for atributo in CharacterRules.ATRIBUTOS:
				if int(final[atributo]) > CharacterRules.VALOR_MAX:
					teto_ok = false
	_check(teto_ok, "nenhum atributo final passa de 20")

	var conjunto_padrao := [8, 10, 12, 13, 14, 15]
	var todas_padrao := true
	for classe in CharacterRules.CLASSES.keys():
		var valores: Array = (CharacterRules.CLASSES[classe] as Dictionary)["atributos"].values()
		valores.sort()
		if valores != conjunto_padrao:
			todas_padrao = false
	_check(todas_padrao, "atributos padrão de cada classe são o conjunto 15, 14, 13, 12, 10, 8")

	var duas_pericias := true
	for origem in CharacterRules.ORIGENS.keys():
		if (CharacterRules.ORIGENS[origem] as Dictionary)["pericias"].size() != 2:
			duas_pericias = false
	_check(duas_pericias, "cada origem dá duas perícias")

	_check(CharacterRules.pv_nivel_1("guerreiro", 14) == 12, "guerreiro com Con 14: 10 + 2 = 12 PV")
	_check(CharacterRules.pv_nivel_1("mago_engenheiro", 8) == 5, "mago com Con 8: 6 - 1 = 5 PV")
	_check(CharacterRules.pv_nivel_1("mago_engenheiro", 1) == 1, "PV no nível 1 nunca fica abaixo de 1")

	if _failures == 0:
		print("OK: todos os testes de criação de personagem passaram.")
		quit(0)
	else:
		print("FALHAS: ", _failures)
		quit(1)


func _check(condicao: bool, descricao: String) -> void:
	if not condicao:
		_failures += 1
		print("FALHOU: ", descricao)
