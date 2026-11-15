class_name ProfileStore
extends RefCounted
## Persistência local dos perfis em user://profiles.cfg. Um slot por seção.

const PATH: String = "user://profiles.cfg"
const KEYS = ["name", "race", "class", "play_time_s", "xp"]


## Lê os slots. Slot vazio fica null. Arquivo ausente = todos vazios.
static func load_slots(slot_count: int) -> Array:
	var slots: Array = []
	slots.resize(slot_count)
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return slots
	for i in range(slot_count):
		var section := _section(i)
		if not cfg.has_section(section):
			continue
		slots[i] = {
			"name": str(cfg.get_value(section, "name", "")),
			"race": str(cfg.get_value(section, "race", "")),
			"class": str(cfg.get_value(section, "class", "")),
			"play_time_s": int(cfg.get_value(section, "play_time_s", 0)),
			"xp": int(cfg.get_value(section, "xp", 0)),
		}
	return slots


static func save_slot(index: int, profile: Dictionary) -> Error:
	var cfg := ConfigFile.new()
	cfg.load(PATH)  # Sem arquivo ainda: começa vazio.
	var section := _section(index)
	for key in KEYS:
		cfg.set_value(section, key, profile.get(key))
	return cfg.save(PATH)


static func _section(index: int) -> String:
	return "perfil_%d" % index
