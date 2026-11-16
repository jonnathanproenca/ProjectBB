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

## As 18 perícias do SRD 5.2, com o atributo de cada uma. Ids em minúsculas e sem acento.
const PERICIAS: Dictionary = {
	"acrobacia": {"atributo": "des"},
	"adestrar_animais": {"atributo": "sab"},
	"arcanismo": {"atributo": "int"},
	"atletismo": {"atributo": "for"},
	"atuacao": {"atributo": "car"},
	"enganacao": {"atributo": "car"},
	"furtividade": {"atributo": "des"},
	"historia": {"atributo": "int"},
	"intimidacao": {"atributo": "car"},
	"intuicao": {"atributo": "sab"},
	"investigacao": {"atributo": "int"},
	"medicina": {"atributo": "sab"},
	"natureza": {"atributo": "int"},
	"percepcao": {"atributo": "sab"},
	"persuasao": {"atributo": "car"},
	"prestidigitacao": {"atributo": "des"},
	"religiao": {"atributo": "int"},
	"sobrevivencia": {"atributo": "sab"},
}

## Personagens da aba Origem do MVP: só o personalizado (ADR-051).
const PERSONAGENS: Array[String] = ["personalizado"]

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
## "pericias": perícias fixas da classe, sem escolha no MVP (ADR-053 e ADR-054).
const CLASSES: Dictionary = {
	"guerreiro": {"dado_vida": 10, "pericias": ["atletismo", "percepcao"], "atributos": {"for": 15, "con": 14, "des": 13, "sab": 12, "int": 10, "car": 8}},
	"clerigo": {"dado_vida": 8, "pericias": ["medicina", "religiao"], "atributos": {"sab": 15, "con": 14, "for": 13, "car": 12, "des": 10, "int": 8}},
	"ladino": {"dado_vida": 8, "pericias": ["enganacao", "furtividade", "percepcao", "prestidigitacao"], "atributos": {"des": 15, "int": 14, "con": 13, "car": 12, "sab": 10, "for": 8}},
	"mago_engenheiro": {"dado_vida": 6, "pericias": ["arcanismo", "investigacao"], "atributos": {"int": 15, "con": 14, "des": 13, "sab": 12, "for": 10, "car": 8}},
	"atirador_arcano": {"dado_vida": 8, "pericias": ["acrobacia", "percepcao"], "atributos": {"des": 15, "con": 14, "sab": 13, "int": 12, "for": 10, "car": 8}},
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


## Perícias finais: une as da classe e as da origem (background), sem repetir, em ordem alfabética.
## Ids que não existem em PERICIAS são ignorados; classe ou origem desconhecida não contribui.
static func pericias_finais(classe: String, origem: String) -> Array[String]:
	var ids: Array = []
	if CLASSES.has(classe):
		ids.append_array((CLASSES[classe] as Dictionary).get("pericias", []))
	if ORIGENS.has(origem):
		ids.append_array((ORIGENS[origem] as Dictionary).get("pericias", []))
	return unir_pericias(ids)


## Filtra uma lista de ids: descarta os que não estão em PERICIAS e os repetidos, e ordena.
static func unir_pericias(ids: Array) -> Array[String]:
	var resultado: Array[String] = []
	for id in ids:
		var pericia: String = str(id)
		if PERICIAS.has(pericia) and not resultado.has(pericia):
			resultado.append(pericia)
	resultado.sort()
	return resultado
