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

	_testar_pericias()

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


func _testar_pericias() -> void:
	_check(CharacterRules.PERICIAS.size() == 18, "são 18 perícias")
	var atributo_ok := true
	for id in CharacterRules.PERICIAS.keys():
		if not CharacterRules.ATRIBUTOS.has((CharacterRules.PERICIAS[id] as Dictionary)["atributo"]):
			atributo_ok = false
	_check(atributo_ok, "toda perícia aponta para um atributo válido")
	_check(_igual(CharacterRules.PERSONAGENS, ["personalizado"]), "aba Origem tem só o personagem personalizado")

	var ids_ok := true
	for classe in CharacterRules.CLASSES.keys():
		for id in (CharacterRules.CLASSES[classe] as Dictionary)["pericias"]:
			if not CharacterRules.PERICIAS.has(id):
				ids_ok = false
	for origem in CharacterRules.ORIGENS.keys():
		for id in (CharacterRules.ORIGENS[origem] as Dictionary)["pericias"]:
			if not CharacterRules.PERICIAS.has(id):
				ids_ok = false
	_check(ids_ok, "perícias de classes e origens existem em PERICIAS")

	# Guerreiro (atletismo, percepcao) + soldado (atletismo, intimidacao): atletismo repete.
	var soldado: Array[String] = CharacterRules.pericias_finais("guerreiro", "soldado")
	_check(_igual(soldado, ["atletismo", "intimidacao", "percepcao"]), "guerreiro soldado: união sem repetir e em ordem")
	# Mago (arcanismo, investigacao) + nobre (historia, persuasao): sem repetição, ordem alfabética.
	var mago: Array[String] = CharacterRules.pericias_finais("mago_engenheiro", "nobre")
	_check(_igual(mago, ["arcanismo", "historia", "investigacao", "persuasao"]), "mago nobre: quatro perícias em ordem alfabética")
	# Ladino (4) + órfão: furtividade e percepcao já estão no ladino, então continuam 4.
	var ladino: Array[String] = CharacterRules.pericias_finais("ladino", "orfao")
	_check(_igual(ladino, ["enganacao", "furtividade", "percepcao", "prestidigitacao"]), "ladino órfão: sem repetição")

	var todas_ordenadas := true
	var todas_unicas := true
	for classe in CharacterRules.CLASSES.keys():
		for origem in CharacterRules.ORIGENS.keys():
			var lista: Array[String] = CharacterRules.pericias_finais(classe, origem)
			var ordenada: Array = Array(lista)
			ordenada.sort()
			if not _igual(lista, ordenada):
				todas_ordenadas = false
			for i in lista.size():
				if lista.find(lista[i]) != i:
					todas_unicas = false
	_check(todas_ordenadas, "pericias_finais sempre em ordem alfabética")
	_check(todas_unicas, "pericias_finais nunca repete")

	# Id inexistente e repetido: ignorado e removido, resultado ordenado.
	var filtrada: Array[String] = CharacterRules.unir_pericias(["percepcao", "inexistente", "atletismo", "percepcao", ""])
	_check(_igual(filtrada, ["atletismo", "percepcao"]), "id de perícia inexistente é ignorado")

	_check(_igual(CharacterRules.pericias_finais("bardo", "soldado"), ["atletismo", "intimidacao"]), "classe desconhecida só contribui com a origem")
	_check(_igual(CharacterRules.pericias_finais("guerreiro", "desertor"), ["atletismo", "percepcao"]), "origem desconhecida só contribui com a classe")
	_check(CharacterRules.pericias_finais("x", "y").is_empty(), "classe e origem desconhecidas dão lista vazia")


## Compara duas listas pelo conteúdo, na mesma ordem, sem depender do tipo do Array.
func _igual(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		if a[i] != b[i]:
			return false
	return true
