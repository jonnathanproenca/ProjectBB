extends SceneTree
## Teste headless do gerador de arenas. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_arena_generator.gd
## Sai com código 0 se tudo passar, 1 se alguma asserção falhar.

var _failures: int = 0


func _initialize() -> void:
	var cat := _catalogo_falso()
	_check(not ArenaGenerator.pools_para(cat, "estrada").is_empty(), "catálogo completo gera pools")
	_check(ArenaGenerator.pools_para(cat, "inexistente").is_empty(), "tipo sem assets não gera pools")
	_check(ArenaGenerator.pools_para({}, "estrada").is_empty(), "catálogo vazio não gera pools")

	var sem_cerca := _catalogo_falso()
	sem_cerca["props"] = (sem_cerca["props"] as Array).filter(func(e): return e["papel"] != "cerca")
	_check(ArenaGenerator.pools_para(sem_cerca, "estrada").is_empty(), "falta de cerca invalida o catálogo")

	var a := ArenaGenerator.gerar(cat, "estrada", 7)
	_check(not a.is_empty(), "gera layout com catálogo completo")
	if not a.is_empty():
		_check((a["tiles"] as Array).size() == ArenaGenerator.LARGURA * ArenaGenerator.ALTURA, "um tile por hex")
		_check(ArenaGenerator.valido(a), "layout gerado passa na validação")
	var b := ArenaGenerator.gerar(cat, "estrada", 7)
	_check(not a.is_empty() and not b.is_empty() and a["assinatura"] == b["assinatura"], "mesma semente, mesmo layout")

	if not a.is_empty():
		var c := ArenaGenerator.gerar(cat, "estrada", 7, [a["assinatura"]])
		_check(not c.is_empty() and c["assinatura"] != a["assinatura"], "histórico impede repetir o layout")
	var d := ArenaGenerator.gerar(cat, "estrada", 8)
	_check(not a.is_empty() and not d.is_empty() and d["assinatura"] != a["assinatura"], "semente diferente muda o layout")

	var validos := 0
	var assinaturas: Dictionary = {}
	for s in range(1, 61):
		var layout := ArenaGenerator.gerar(cat, "estrada", s)
		if not layout.is_empty() and ArenaGenerator.valido(layout):
			validos += 1
			assinaturas[layout["assinatura"]] = true
	_check(validos == 60, "60 sementes geram 60 layouts válidos (achou %d)" % validos)
	_check(assinaturas.size() == 60, "60 sementes geram 60 layouts diferentes")

	_check(ArenaGenerator.distancia(Vector2i(0, 0), Vector2i(0, 0)) == 0, "mesmo hex: distância 0")
	_check(ArenaGenerator.distancia(Vector2i(0, 0), Vector2i(1, 0)) == 1, "vizinho em coluna par: distância 1")
	_check(ArenaGenerator.distancia(Vector2i(1, 0), Vector2i(2, 1)) == 1, "vizinho em coluna ímpar: distância 1")
	_check(ArenaGenerator.distancia(Vector2i(0, 0), Vector2i(2, 0)) == 2, "dois passos na mesma linha: distância 2")

	var simetria_ok := true
	var seis_vizinhos := true
	for x in range(1, ArenaGenerator.LARGURA - 1):
		for y in range(1, ArenaGenerator.ALTURA - 1):
			var p := Vector2i(x, y)
			var viz := ArenaGenerator.vizinhos(p)
			if viz.size() != 6:
				seis_vizinhos = false
			for v in viz:
				if ArenaGenerator.distancia(p, v) != 1 or not ArenaGenerator.vizinhos(v).has(p):
					simetria_ok = false
	_check(seis_vizinhos, "hex interno tem 6 vizinhos")
	_check(simetria_ok, "vizinhança é simétrica e de distância 1")
	_check(ArenaGenerator.vizinhos(Vector2i(1, 1)).has(Vector2i(2, 2)), "coluna ímpar desce meio hex para o vizinho")

	var com_trilho := _catalogo_falso()
	(com_trilho["tiles"] as Array).append({"arquivo": "trilho_a", "tipo_arena": "estrada", "papel": "trilho"})
	for semente in range(1, 21):
		var t := ArenaGenerator.gerar(com_trilho, "estrada", semente)
		if t.is_empty():
			_check(false, "com trilho ainda gera layout (semente %d)" % semente)
			continue
		var x_trilho: int = t["x0"]
		_check(x_trilho == 2 or x_trilho == ArenaGenerator.LARGURA - 2 - ArenaGenerator.LARGURA_PISTA, "trilho fica a 2 hexes da borda (semente %d)" % semente)
		var continuo := true
		for y in range(ArenaGenerator.ALTURA):
			if t["tiles"][y * ArenaGenerator.LARGURA + x_trilho] != "trilho_a":
				continuo = false
		_check(continuo, "trilho contínuo de cima a baixo (semente %d)" % semente)

	var pares_sem := 0
	var pares_com := 0
	for semente in range(1, 21):
		pares_sem += _pares_iguais(ArenaGenerator.gerar(cat, "estrada", semente, [], 1))
		pares_com += _pares_iguais(ArenaGenerator.gerar(cat, "estrada", semente, [], 3))
	_check(pares_com > pares_sem, "agrupamento 3 aumenta pares vizinhos de campo com o mesmo tile (%d > %d)" % [pares_com, pares_sem])

	_check(ArenaGenerator._perto_da_pista(4, 5), "coluna vizinha à pista conta como perto")
	_check(not ArenaGenerator._perto_da_pista(2, 5), "coluna longe da pista não conta")
	_check(not ArenaGenerator._perto_da_pista(5, 5), "dentro da pista não conta")

	var historico: Array = []
	for i in range(5):
		historico = ArenaGenerator.registrar(historico, {"assinatura": "s%d" % i}, 3)
	_check(historico.size() == 3 and historico[0] == "s2", "histórico guarda só os últimos 3")

	if validos == 60 and assinaturas.size() == 60:
		print("OK: todos os testes do gerador de arenas passaram.")
		quit(0)
	else:
		print("FALHAS: ", _failures)
		quit(1)


## Conta pares de hexes de campo vizinhos com o mesmo tile.
func _pares_iguais(layout: Dictionary) -> int:
	if layout.is_empty():
		return 0
	var tiles: Array = layout["tiles"]
	var papeis: Array = layout["papeis"]
	var pares := 0
	for y in range(ArenaGenerator.ALTURA):
		for x in range(ArenaGenerator.LARGURA):
			var p := Vector2i(x, y)
			if papeis[ArenaGenerator._indice(x, y)] != "campo":
				continue
			for v in ArenaGenerator.vizinhos(p):
				if papeis[ArenaGenerator._indice(v.x, v.y)] == "campo" and tiles[ArenaGenerator._indice(v.x, v.y)] == tiles[ArenaGenerator._indice(x, y)]:
					pares += 1
	return pares / 2


func _catalogo_falso() -> Dictionary:
	var tiles: Array = []
	for arq in ["campo_a", "campo_b", "campo_c"]:
		tiles.append({"arquivo": arq, "tipo_arena": "estrada", "papel": "campo"})
	tiles.append({"arquivo": "pista_a", "tipo_arena": "estrada", "papel": "pista"})
	tiles.append({"arquivo": "pista_b", "tipo_arena": "estrada", "papel": "pista"})
	tiles.append({"arquivo": "centro_a", "tipo_arena": "estrada", "papel": "centro"})
	tiles.append({"arquivo": "borda_a", "tipo_arena": "estrada", "papel": "borda"})
	tiles.append({"arquivo": "borda_b", "tipo_arena": "estrada", "papel": "borda"})
	var props: Array = []
	for arq in ["cerca_a", "cerca_b"]:
		props.append({"arquivo": arq, "tipo_arena": "estrada", "papel": "cerca"})
	for arq in ["cobertura_a", "cobertura_b", "cobertura_c"]:
		props.append({"arquivo": arq, "tipo_arena": "estrada", "papel": "cobertura"})
	props.append({"arquivo": "lampiao_a", "tipo_arena": "estrada", "papel": "lampiao"})
	return {"tiles": tiles, "props": props}


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures += 1
		print("FALHOU: ", label)
