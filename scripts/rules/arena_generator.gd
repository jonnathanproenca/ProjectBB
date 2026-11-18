class_name ArenaGenerator
extends RefCounted
## Gera layouts de arena por regras fixas e uma semente.
## Regra pura, sem nós de cena: testável headless.
## Os assets vêm do catálogo (manifesto gerado por tools/gerar_manifesto_arenas.py).
##
## Grade: 12 x 9 hexes flat-top. Colunas ímpares ficam meio hex abaixo das pares.
## Zonas: borda (muro externo), pista (duas colunas N-S), centro (dois hexes no meio
## da pista), campo (resto). Coberturas ficam no campo, alternadas entre os dois lados.

const LARGURA: int = 12
const ALTURA: int = 9
const LARGURA_PISTA: int = 2
const TENTATIVAS_MAX: int = 40
const COBERTURAS_MIN: int = 4
const COBERTURAS_MAX: int = 6
const COBERTURAS_POR_LADO_MIN: int = 2
const DISTANCIA_MIN_BLOQUEIO: int = 2
const CHANCE_CERCA: float = 0.55
const CHANCE_LAMPIAO: float = 0.7
const PAPEIS_OBRIGATORIOS := ["campo", "pista", "centro", "borda", "cerca", "cobertura"]


## Monta a lista de assets por papel para um tipo de arena. Vazia se faltar algum papel obrigatório.
static func pools_para(catalogo: Dictionary, tipo: String) -> Dictionary:
	var pools: Dictionary = {}
	for chave in ["tiles", "props"]:
		for entrada in catalogo.get(chave, []):
			if entrada.get("tipo_arena", "") != tipo:
				continue
			var papel: String = entrada.get("papel", "")
			if not pools.has(papel):
				pools[papel] = []
			pools[papel].append(entrada.get("arquivo", ""))
	if not pools.has("centro") and pools.has("pista"):
		pools["centro"] = pools["pista"]
	for papel in PAPEIS_OBRIGATORIOS:
		if not pools.has(papel):
			return {}
	return pools


## Gera um layout válido e diferente de todos em `historico` (lista de assinaturas).
## Mesma semente e mesmo histórico sempre dão o mesmo resultado. Devolve {} se não achar.
static func gerar(catalogo: Dictionary, tipo: String, semente: int, historico: Array = []) -> Dictionary:
	var pools := pools_para(catalogo, tipo)
	if pools.is_empty():
		return {}
	for tentativa in range(TENTATIVAS_MAX):
		var rng := RandomNumberGenerator.new()
		rng.seed = semente * 1000 + tentativa
		var layout := _montar(semente, pools, rng)
		if not valido(layout):
			continue
		if historico.has(layout["assinatura"]):
			continue
		return layout
	return {}


## Guarda a assinatura do layout e mantém só as últimas `limite` entradas.
static func registrar(historico: Array, layout: Dictionary, limite: int) -> Array:
	historico.append(layout["assinatura"])
	while historico.size() > limite:
		historico.pop_front()
	return historico


static func dentro(x: int, y: int) -> bool:
	return x >= 0 and x < LARGURA and y >= 0 and y < ALTURA


## Vizinhos de um hex dentro do grid (colunas ímpares descem meio hex).
static func vizinhos(p: Vector2i) -> Array[Vector2i]:
	var deslocamentos: Array[Vector2i] = []
	if p.x % 2 == 0:
		deslocamentos = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(1, -1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	else:
		deslocamentos = [Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -1), Vector2i(0, 1)]
	var saida: Array[Vector2i] = []
	for d in deslocamentos:
		var v := p + d
		if dentro(v.x, v.y):
			saida.append(v)
	return saida


## Número de passos entre dois hexes (distância em coordenadas cúbicas).
static func distancia(a: Vector2i, b: Vector2i) -> int:
	var ca := _cubo(a)
	var cb := _cubo(b)
	return maxi(absi(ca.x - cb.x), maxi(absi(ca.y - cb.y), absi(ca.z - cb.z)))


## Checa as regras do layout: pista e centro livres, coberturas afastadas,
## dois lados com cobertura e todo hex passável ligado à entrada norte da pista.
static func valido(layout: Dictionary) -> bool:
	if layout.is_empty():
		return false
	var tiles: Array = layout["tiles"]
	var papeis: Array = layout["papeis"]
	var props: Array = layout["props"]
	var x0: int = layout["x0"]
	if tiles.size() != LARGURA * ALTURA or papeis.size() != LARGURA * ALTURA:
		return false
	var bloqueados: Dictionary = {}
	var esquerda := 0
	var direita := 0
	for p in props:
		var pos := Vector2i(p["x"], p["y"])
		var papel: String = papeis[_indice(pos.x, pos.y)]
		if papel == "pista" or papel == "centro":
			return false
		if p["bloqueia"]:
			bloqueados[pos] = true
			if pos.x < x0:
				esquerda += 1
			elif pos.x >= x0 + LARGURA_PISTA:
				direita += 1
	if esquerda < COBERTURAS_POR_LADO_MIN or direita < COBERTURAS_POR_LADO_MIN:
		return false
	var lista: Array = bloqueados.keys()
	for i in range(lista.size()):
		for j in range(i + 1, lista.size()):
			if distancia(lista[i], lista[j]) < DISTANCIA_MIN_BLOQUEIO:
				return false
	var inicio := Vector2i(x0, 1)
	if bloqueados.has(inicio):
		return false
	return _alcancaveis(inicio, bloqueados) == LARGURA * ALTURA - bloqueados.size()


static func assinatura_de(layout: Dictionary) -> String:
	var partes := PackedStringArray()
	partes.append(str(layout["x0"]))
	partes.append("|".join(PackedStringArray(layout["tiles"])))
	for p in layout["props"]:
		partes.append("%d,%d,%s" % [p["x"], p["y"], p["arquivo"]])
	return ";".join(partes)


static func _montar(semente: int, pools: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var x0 := rng.randi_range(3, LARGURA - 3 - LARGURA_PISTA)
	var yc := int(ALTURA / 2.0)
	var papeis: Array = []
	var tiles: Array = []
	papeis.resize(LARGURA * ALTURA)
	tiles.resize(LARGURA * ALTURA)
	var centros: Array[Vector2i] = []
	for y in range(ALTURA):
		for x in range(LARGURA):
			var papel := "campo"
			if x == 0 or y == 0 or x == LARGURA - 1 or y == ALTURA - 1:
				papel = "borda"
			elif x >= x0 and x < x0 + LARGURA_PISTA:
				papel = "pista"
				if y == yc:
					papel = "centro"
					centros.append(Vector2i(x, y))
			var i := _indice(x, y)
			papeis[i] = papel
			tiles[i] = _escolher(pools[papel], rng)

	var props: Array = []
	for x in range(1, LARGURA - 1):
		if x >= x0 and x < x0 + LARGURA_PISTA:
			continue
		if rng.randf() < CHANCE_CERCA:
			props.append(_prop(x, 0, "cerca", pools, rng))

	var candidatos: Array[Vector2i] = []
	for y in range(1, ALTURA - 1):
		for x in range(1, LARGURA - 1):
			if papeis[_indice(x, y)] == "campo":
				candidatos.append(Vector2i(x, y))
	_embaralhar(candidatos, rng)

	var quantidade := rng.randi_range(COBERTURAS_MIN, COBERTURAS_MAX)
	var colocadas := 0
	for c in candidatos:
		if colocadas >= quantidade:
			break
		var quer_oeste := colocadas % 2 == 0
		var esta_oeste := c.x < x0
		if quer_oeste != esta_oeste:
			continue
		if not _livre_para_bloqueio(c, props, centros):
			continue
		props.append(_prop(c.x, c.y, "cobertura", pools, rng))
		colocadas += 1

	if pools.has("lampiao") and rng.randf() < CHANCE_LAMPIAO:
		var lamp: Array[Vector2i] = []
		for c in candidatos:
			if (c.x == x0 - 1 or c.x == x0 + LARGURA_PISTA) and _livre_para_bloqueio(c, props, centros):
				lamp.append(c)
		if not lamp.is_empty():
			var escolhido: Vector2i = lamp[rng.randi_range(0, lamp.size() - 1)]
			props.append(_prop(escolhido.x, escolhido.y, "lampiao", pools, rng))

	var layout := {
		"tipo_semente": semente,
		"semente": semente,
		"x0": x0,
		"papeis": papeis,
		"tiles": tiles,
		"props": props,
	}
	layout["assinatura"] = assinatura_de(layout)
	return layout


static func _prop(x: int, y: int, tipo: String, pools: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var cobertura := "nenhuma"
	var bloqueia := false
	if tipo == "cerca":
		cobertura = "meia"
	elif tipo == "cobertura":
		cobertura = "tres_quartos"
		bloqueia = true
	elif tipo == "lampiao":
		bloqueia = true
	return {
		"x": x,
		"y": y,
		"tipo": tipo,
		"arquivo": _escolher(pools[tipo], rng),
		"cobertura": cobertura,
		"bloqueia": bloqueia,
	}


static func _livre_para_bloqueio(c: Vector2i, props: Array, centros: Array[Vector2i]) -> bool:
	for p in props:
		if p["bloqueia"] and distancia(c, Vector2i(p["x"], p["y"])) < DISTANCIA_MIN_BLOQUEIO:
			return false
	for centro in centros:
		if distancia(c, centro) < DISTANCIA_MIN_BLOQUEIO:
			return false
	return true


static func _alcancaveis(inicio: Vector2i, bloqueados: Dictionary) -> int:
	var visitados: Dictionary = {inicio: true}
	var fila: Array = [inicio]
	while not fila.is_empty():
		var atual: Vector2i = fila.pop_back()
		for v in vizinhos(atual):
			if visitados.has(v) or bloqueados.has(v):
				continue
			visitados[v] = true
			fila.append(v)
	return visitados.size()


static func _cubo(p: Vector2i) -> Vector3i:
	var x := p.x
	var z := p.y - ((p.x - (p.x & 1)) >> 1)
	return Vector3i(x, -x - z, z)


static func _indice(x: int, y: int) -> int:
	return y * LARGURA + x


static func _escolher(lista: Array, rng: RandomNumberGenerator) -> String:
	return str(lista[rng.randi_range(0, lista.size() - 1)])


static func _embaralhar(lista: Array, rng: RandomNumberGenerator) -> void:
	for i in range(lista.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = lista[i]
		lista[i] = lista[j]
		lista[j] = tmp
