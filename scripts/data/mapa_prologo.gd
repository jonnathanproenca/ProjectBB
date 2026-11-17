class_name MapaPrologo
extends RefCounted
## Mapa de exemplo do prólogo (16x10): borda de paredes, um muro interno com
## passagem e algumas pedras. Dados puros, sem nós de cena.

const LARGURA: int = 16
const ALTURA: int = 10


## Devolve { "largura", "altura", "paredes", "inicio", "npc" }.
static func mapa() -> Dictionary:
	var paredes: Array = []
	# Borda
	for x in range(LARGURA):
		paredes.append(Vector2i(x, 0))
		paredes.append(Vector2i(x, ALTURA - 1))
	for y in range(ALTURA):
		paredes.append(Vector2i(0, y))
		paredes.append(Vector2i(LARGURA - 1, y))
	# Muro interno vertical em x = 8, com passagem em y = 5
	for y in range(1, ALTURA - 1):
		if y != 5:
			paredes.append(Vector2i(8, y))
	# Pedras soltas
	paredes.append(Vector2i(3, 3))
	paredes.append(Vector2i(4, 3))
	paredes.append(Vector2i(5, 7))
	paredes.append(Vector2i(11, 2))
	paredes.append(Vector2i(12, 7))
	var base: Dictionary = ExploracaoRules.novo_mapa(LARGURA, ALTURA, paredes)
	base["inicio"] = Vector2i(2, 5)
	base["npc"] = Vector2i(12, 4)
	return base
