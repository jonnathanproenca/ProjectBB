class_name DialogoRules
extends RefCounted
## Regras puras de árvore de diálogo (sem nós de cena), para teste headless.
## Formato: {"inicio": "n1", "nos": {"n1": {"texto": "...", "opcoes": [
##   {"texto": "...", "proximo": "n2", "condicao": {"flag": "x", "valor": true},
##    "efeito": {"flag": "y", "valor": true}}]}}}
## Nó sem opções encerra a conversa. "condicao" e "efeito" são opcionais.


## Opções do nó que passam nas condições, na ordem original.
## Cada item é a própria opção (Dictionary); use `indice_original` para escolher.
static func opcoes_disponiveis(no: Dictionary, flags: Dictionary) -> Array:
	var resultado: Array = []
	var opcoes: Array = no.get("opcoes", [])
	for opcao in opcoes:
		if not (opcao is Dictionary):
			continue
		if _condicao_ok(opcao, flags):
			resultado.append(opcao)
	return resultado


## Escolhe a opção `indice` entre as DISPONÍVEIS (mesma ordem de opcoes_disponiveis).
## Devolve {"proximo": String, "flags": Dictionary}. Não altera `flags`.
## Nó inexistente ou índice inválido: proximo vazio e flags inalteradas (cópia).
static func escolher(arvore: Dictionary, id_no: String, flags: Dictionary, indice: int) -> Dictionary:
	var novas: Dictionary = flags.duplicate(true)
	var nos: Dictionary = arvore.get("nos", {})
	if not nos.has(id_no):
		return {"proximo": "", "flags": novas}
	var no: Dictionary = nos[id_no]
	var disponiveis: Array = opcoes_disponiveis(no, flags)
	if indice < 0 or indice >= disponiveis.size():
		return {"proximo": "", "flags": novas}
	var opcao: Dictionary = disponiveis[indice]
	var efeito: Variant = opcao.get("efeito", null)
	if efeito is Dictionary and efeito.has("flag"):
		novas[str(efeito["flag"])] = efeito.get("valor", true)
	return {"proximo": str(opcao.get("proximo", "")), "flags": novas}


## True se o nó encerra a conversa: sem opções (ou nó inexistente).
static func terminou(arvore: Dictionary, id_no: String) -> bool:
	var nos: Dictionary = arvore.get("nos", {})
	if not nos.has(id_no):
		return true
	var no: Dictionary = nos[id_no]
	var opcoes: Array = no.get("opcoes", [])
	return opcoes.is_empty()


static func _condicao_ok(opcao: Dictionary, flags: Dictionary) -> bool:
	var condicao: Variant = opcao.get("condicao", null)
	if not (condicao is Dictionary) or not condicao.has("flag"):
		return true
	var nome: String = str(condicao["flag"])
	var esperado: Variant = condicao.get("valor", true)
	if not flags.has(nome):
		return false
	return flags[nome] == esperado
