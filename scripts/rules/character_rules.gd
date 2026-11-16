class_name CharacterRules
extends RefCounted
## Regras puras de criação de personagem do MVP: espécie, origem, classe e atributos.
## Sem nós de cena, para testar headless. Valores marcados como (padrão) em docs/CRIACAO.md.

const ATRIBUTOS: Array[String] = ["for", "des", "con", "int", "sab", "car"]
const VALOR_MAX: int = 20
const ERR_NONE: String = ""
const ERR_ESPECIE: String = "especie"
const ERR_ORIGEM: String = "origem"
const ERR_CLASSE: String = "classe"

## Espécies do MVP. Bônus de atributo (padrão).
const ESPECIES: Dictionary = {
	"humano": {"bonus": {"car": 1, "con": 1}},
	"automato": {"bonus": {"con": 2, "int": 1}},
	"mestico": {"bonus": {"car": 2, "des": 1}},
}

## Origens do MVP. Cada uma dá duas perícias (padrão).
const ORIGENS: Dictionary = {
	"soldado": {"pericias": ["atletismo", "intimidacao"]},
	"orfao": {"pericias": ["furtividade", "percepcao"]},
	"nobre": {"pericias": ["historia", "persuasao"]},
	"criminoso": {"pericias": ["enganacao", "prestidigitacao"]},
	"eremita": {"pericias": ["sobrevivencia", "medicina"]},
}

## Classes do MVP. Atributos padrão seguem o conjunto 15, 14, 13, 12, 10, 8 (padrão).
const CLASSES: Dictionary = {
	"guerreiro": {"dado_vida": 10, "atributos": {"for": 15, "con": 14, "des": 13, "sab": 12, "int": 10, "car": 8}},
	"clerigo": {"dado_vida": 8, "atributos": {"sab": 15, "con": 14, "for": 13, "car": 12, "des": 10, "int": 8}},
	"ladino": {"dado_vida": 8, "atributos": {"des": 15, "int": 14, "con": 13, "car": 12, "sab": 10, "for": 8}},
	"mago_engenheiro": {"dado_vida": 6, "atributos": {"int": 15, "con": 14, "des": 13, "sab": 12, "for": 10, "car": 8}},
	"atirador_arcano": {"dado_vida": 8, "atributos": {"des": 15, "con": 14, "sab": 13, "int": 12, "for": 10, "car": 8}},
}


## Devolve ERR_NONE se a espécie, a origem e a classe existem no MVP; senão o código do primeiro erro.
static func validar(especie: String, origem: String, classe: String) -> String:
	if not ESPECIES.has(especie):
		return ERR_ESPECIE
	if not ORIGENS.has(origem):
		return ERR_ORIGEM
	if not CLASSES.has(classe):
		return ERR_CLASSE
	return ERR_NONE


## Atributos finais: valores padrão da classe somados ao bônus da espécie, limitados a VALOR_MAX.
static func atributos_finais(especie: String, classe: String) -> Dictionary:
	var base: Dictionary = (CLASSES[classe] as Dictionary)["atributos"]
	var bonus: Dictionary = (ESPECIES[especie] as Dictionary)["bonus"]
	var final: Dictionary = {}
	for atributo in ATRIBUTOS:
		final[atributo] = mini(VALOR_MAX, int(base[atributo]) + int(bonus.get(atributo, 0)))
	return final


## Pontos de vida no nível 1: maior valor do dado de vida da classe + modificador de Constituição, mínimo 1.
static func pv_nivel_1(classe: String, con_valor: int) -> int:
	var dado: int = int((CLASSES[classe] as Dictionary)["dado_vida"])
	return maxi(1, dado + DndRules.ability_modifier(con_valor))
