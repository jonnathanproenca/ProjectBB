class_name ProfileRules
extends RefCounted
## Regras puras de perfil: nome, slots, tempo de jogo e nível.
## Sem nós de cena, para testar headless. Os textos de erro são códigos; a tela traduz.

const NAME_MAX_LENGTH: int = 20
const ERR_NONE: String = ""
const ERR_EMPTY: String = "vazio"
const ERR_TOO_LONG: String = "longo"


## Valida o nome digitado. Devolve ERR_NONE ou um código de erro.
static func validate_name(raw: String) -> String:
	var clean := raw.strip_edges()
	if clean.is_empty():
		return ERR_EMPTY
	if clean.length() > NAME_MAX_LENGTH:
		return ERR_TOO_LONG
	return ERR_NONE


static func clean_name(raw: String) -> String:
	return raw.strip_edges()


## Perfil novo: raça e classe ficam vazias até a criação completa.
static func make_profile(name: String) -> Dictionary:
	return {"name": clean_name(name), "race": "", "class": "", "play_time_s": 0, "xp": 0}


## Índice do primeiro slot vazio (null), ou -1 se todos estiverem em uso.
static func first_free_slot(slots: Array) -> int:
	for i in range(slots.size()):
		if slots[i] == null:
			return i
	return -1


## Tempo de jogo em (horas, minutos). Segundos negativos viram zero.
@warning_ignore("integer_division")
static func play_time_parts(seconds: int) -> Vector2i:
	var total := maxi(seconds, 0)
	return Vector2i(total / 3600, (total % 3600) / 60)


## Nível do perfil a partir do XP, limitado ao nível máximo do MVP.
static func level_for_profile(profile: Dictionary, max_level: int) -> int:
	return DndRules.level_for_xp(int(profile.get("xp", 0)), max_level)
