extends SceneTree
## Teste headless das regras de perfil e configuração. Rodar com:
##   godot --headless --path . -s res://scripts/tests/test_profile_rules.gd
## Sai com código 0 se tudo passar, 1 se alguma asserção falhar.

var _failures: int = 0


func _initialize() -> void:
	_check(ProfileRules.validate_name("") == ProfileRules.ERR_EMPTY, "nome vazio é rejeitado")
	_check(ProfileRules.validate_name("   ") == ProfileRules.ERR_EMPTY, "nome só com espaços é vazio")
	_check(ProfileRules.validate_name("Aria") == ProfileRules.ERR_NONE, "nome válido passa")
	_check(ProfileRules.validate_name("A".repeat(20)) == ProfileRules.ERR_NONE, "20 caracteres é o limite")
	_check(ProfileRules.validate_name("A".repeat(21)) == ProfileRules.ERR_TOO_LONG, "21 caracteres é longo demais")
	_check(ProfileRules.clean_name("  Aria  ") == "Aria", "espaços das pontas são removidos")

	var novo := ProfileRules.make_profile(" Aria ")
	_check(novo["name"] == "Aria", "perfil novo guarda o nome limpo")
	_check(novo["race"] == "" and novo["class"] == "", "raça e classe começam vazias")
	_check(novo["xp"] == 0 and novo["play_time_s"] == 0, "perfil novo começa zerado")

	_check(ProfileRules.first_free_slot([null, {}, null]) == 0, "primeiro slot livre é o 0")
	_check(ProfileRules.first_free_slot([{}, null, {}]) == 1, "slot livre no meio")
	_check(ProfileRules.first_free_slot([{}, {}, {}]) == -1, "sem slot livre devolve -1")

	_check(ProfileRules.play_time_parts(0) == Vector2i(0, 0), "0 s = 0 h 0 min")
	_check(ProfileRules.play_time_parts(59) == Vector2i(0, 0), "59 s não chega a 1 min")
	_check(ProfileRules.play_time_parts(3 * 3600 + 5 * 60 + 30) == Vector2i(3, 5), "3 h 5 min 30 s")
	_check(ProfileRules.play_time_parts(-10) == Vector2i(0, 0), "tempo negativo vira zero")

	_check(ProfileRules.level_for_profile({"xp": 0}, 5) == 1, "0 XP = nível 1")
	_check(ProfileRules.level_for_profile({"xp": 300}, 5) == 2, "300 XP = nível 2")
	_check(ProfileRules.level_for_profile({"xp": 999999}, 5) == 5, "nível limitado ao máximo do MVP")
	_check(ProfileRules.level_for_profile({}, 5) == 1, "perfil sem XP = nível 1")

	_check(SettingsRules.sanitize_locale("en") == "en", "idioma válido é mantido")
	_check(SettingsRules.sanitize_locale("xx") == SettingsRules.DEFAULT_LOCALE, "idioma inválido cai no padrão")
	_check(SettingsRules.clamp_brightness(0.1) == SettingsRules.BRIGHTNESS_MIN, "brilho mínimo")
	_check(SettingsRules.clamp_brightness(3.0) == SettingsRules.BRIGHTNESS_MAX, "brilho máximo")
	_check(SettingsRules.brightness_overlay_color(1.0).a == 0.0, "brilho 1.0 não põe véu")
	_check(is_equal_approx(SettingsRules.brightness_overlay_color(0.5).a, 0.5), "brilho 0.5 escurece 50%")
	_check(is_equal_approx(SettingsRules.brightness_overlay_color(1.5).a, 0.25), "brilho 1.5 clareia 25%")

	if _failures == 0:
		print("OK: todos os testes de perfil e configuração passaram.")
		quit(0)
	else:
		print("FALHAS: ", _failures)
		quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures += 1
		printerr("FALHOU: ", label)
