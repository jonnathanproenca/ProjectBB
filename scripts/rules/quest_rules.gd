class_name QuestRules
extends RefCounted
## Regras puras de estado de quest, guardado nas flags como "quest_<id>".
## Estados válidos: "nao_iniciada" (padrão), "ativa", "concluida".

const NAO_INICIADA: String = "nao_iniciada"
const ATIVA: String = "ativa"
const CONCLUIDA: String = "concluida"
const ESTADOS: Array = ["nao_iniciada", "ativa", "concluida"]


## Chave da flag de uma quest.
static func chave(id: String) -> String:
	return "quest_" + id


## Estado atual da quest; "nao_iniciada" se ausente ou inválido.
static func estado(flags: Dictionary, id: String) -> String:
	var valor: Variant = flags.get(chave(id), NAO_INICIADA)
	var texto: String = str(valor)
	if not ESTADOS.has(texto):
		return NAO_INICIADA
	return texto


## Devolve cópia das flags com o novo estado. Estado inválido: cópia inalterada.
static func atualizar(flags: Dictionary, id: String, novo_estado: String) -> Dictionary:
	var novas: Dictionary = flags.duplicate(true)
	if ESTADOS.has(novo_estado):
		novas[chave(id)] = novo_estado
	return novas
