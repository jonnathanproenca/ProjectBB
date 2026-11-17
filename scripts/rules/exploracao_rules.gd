class_name ExploracaoRules
extends RefCounted
## Regras puras de exploração em grade (sem nós de cena), para teste headless.
## Mapa: { "largura": int, "altura": int, "paredes": { Vector2i: true } }.
## Movimento em 4 direções; paredes e limites do mapa bloqueiam.


## Cria um mapa. `paredes` é uma lista de células (Array de Vector2i).
static func novo_mapa(largura: int, altura: int, paredes: Array) -> Dictionary:
	var conjunto: Dictionary = {}
	for celula in paredes:
		conjunto[celula] = true
	return {"largura": largura, "altura": altura, "paredes": conjunto}


## A célula está dentro dos limites do mapa?
static func dentro_dos_limites(mapa: Dictionary, x: int, y: int) -> bool:
	var largura: int = mapa.get("largura", 0)
	var altura: int = mapa.get("altura", 0)
	return x >= 0 and y >= 0 and x < largura and y < altura


## A célula é uma parede?
static func eh_parede(mapa: Dictionary, x: int, y: int) -> bool:
	var paredes: Dictionary = mapa.get("paredes", {})
	return paredes.has(Vector2i(x, y))


## Dá para pisar na célula? (dentro dos limites e fora de paredes)
static func pode_andar(mapa: Dictionary, x: int, y: int) -> bool:
	return dentro_dos_limites(mapa, x, y) and not eh_parede(mapa, x, y)


## Um passo na direção dada. Se não puder andar, fica no lugar.
static func passo(mapa: Dictionary, pos: Vector2i, direcao: Vector2i) -> Vector2i:
	var destino: Vector2i = pos + direcao
	if pode_andar(mapa, destino.x, destino.y):
		return destino
	return pos


## Distância em passos (Manhattan) entre duas células.
static func distancia(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


## Está ao alcance de interação (distância 1, sem diagonal)?
static func adjacente(a: Vector2i, b: Vector2i) -> bool:
	return distancia(a, b) == 1


## Menor caminho (busca em largura, 4 direções) de `origem` a `destino`.
## Inclui origem e destino; vazio se não houver caminho.
static func caminho_simples(mapa: Dictionary, origem: Vector2i, destino: Vector2i) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	if not pode_andar(mapa, origem.x, origem.y) or not pode_andar(mapa, destino.x, destino.y):
		return resultado
	var veio_de: Dictionary = {origem: origem}
	var fila: Array[Vector2i] = [origem]
	var cabeca: int = 0
	var direcoes: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while cabeca < fila.size():
		var atual: Vector2i = fila[cabeca]
		cabeca += 1
		if atual == destino:
			break
		for d in direcoes:
			var prox: Vector2i = passo(mapa, atual, d)
			if prox == atual or veio_de.has(prox):
				continue
			veio_de[prox] = atual
			fila.append(prox)
	if not veio_de.has(destino):
		return resultado
	var celula: Vector2i = destino
	resultado.append(celula)
	while celula != origem:
		celula = veio_de[celula]
		resultado.append(celula)
	resultado.reverse()
	return resultado
