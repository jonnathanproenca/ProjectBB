extends SceneTree
## Teste headless das regras de exploração. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_exploracao_rules.gd

var _failures: int = 0


func _initialize() -> void:
	var paredes: Array = [Vector2i(2, 1), Vector2i(2, 2)]
	var mapa: Dictionary = ExploracaoRules.novo_mapa(5, 4, paredes)

	# Limites
	_check(ExploracaoRules.pode_andar(mapa, 0, 0), "canto (0,0) é andável")
	_check(ExploracaoRules.pode_andar(mapa, 4, 3), "canto (4,3) é andável")
	_check(not ExploracaoRules.pode_andar(mapa, -1, 0), "x negativo fora do mapa")
	_check(not ExploracaoRules.pode_andar(mapa, 0, -1), "y negativo fora do mapa")
	_check(not ExploracaoRules.pode_andar(mapa, 5, 0), "x = largura fora do mapa")
	_check(not ExploracaoRules.pode_andar(mapa, 0, 4), "y = altura fora do mapa")

	# Paredes
	_check(not ExploracaoRules.pode_andar(mapa, 2, 1), "parede bloqueia")
	_check(ExploracaoRules.eh_parede(mapa, 2, 2), "eh_parede reconhece parede")
	_check(not ExploracaoRules.eh_parede(mapa, 1, 1), "chão não é parede")

	# Passo
	_check(ExploracaoRules.passo(mapa, Vector2i(1, 1), Vector2i(0, 1)) == Vector2i(1, 2), "passo livre anda")
	_check(ExploracaoRules.passo(mapa, Vector2i(1, 1), Vector2i(1, 0)) == Vector2i(1, 1), "passo contra parede fica no lugar")
	_check(ExploracaoRules.passo(mapa, Vector2i(0, 0), Vector2i(-1, 0)) == Vector2i(0, 0), "passo para fora do mapa fica no lugar")
	_check(ExploracaoRules.passo(mapa, Vector2i(4, 3), Vector2i(0, 1)) == Vector2i(4, 3), "passo além da borda inferior fica no lugar")

	# Distância e interação
	_check(ExploracaoRules.distancia(Vector2i(0, 0), Vector2i(3, 2)) == 5, "distância Manhattan 3+2")
	_check(ExploracaoRules.adjacente(Vector2i(1, 1), Vector2i(1, 2)), "vizinho ortogonal é adjacente")
	_check(not ExploracaoRules.adjacente(Vector2i(1, 1), Vector2i(2, 2)), "diagonal não é adjacente")
	_check(not ExploracaoRules.adjacente(Vector2i(1, 1), Vector2i(1, 1)), "mesma célula não é adjacente")

	# Caminho
	var caminho: Array[Vector2i] = ExploracaoRules.caminho_simples(mapa, Vector2i(0, 1), Vector2i(4, 1))
	_check(caminho.size() > 0, "existe caminho contornando a parede")
	_check(caminho[0] == Vector2i(0, 1), "caminho começa na origem")
	_check(caminho[caminho.size() - 1] == Vector2i(4, 1), "caminho termina no destino")
	var tudo_andavel: bool = true
	for celula in caminho:
		if not ExploracaoRules.pode_andar(mapa, celula.x, celula.y):
			tudo_andavel = false
	_check(tudo_andavel, "caminho não atravessa parede")
	_check(caminho.size() == 7, "caminho contornando por cima tem 7 células")

	var fechado: Dictionary = ExploracaoRules.novo_mapa(3, 1, [Vector2i(1, 0)])
	_check(ExploracaoRules.caminho_simples(fechado, Vector2i(0, 0), Vector2i(2, 0)).is_empty(), "sem caminho quando bloqueado")
	_check(ExploracaoRules.caminho_simples(mapa, Vector2i(0, 0), Vector2i(2, 1)).is_empty(), "destino em parede não tem caminho")

	if _failures == 0:
		print("OK: todos os testes de exploração passaram.")
		quit(0)
	else:
		print("FALHAS: ", _failures)
		quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures += 1
		printerr("FALHOU: ", label)
