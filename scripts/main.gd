extends Control
## Demo de teste no navegador. Usa apenas as regras puras de scripts/rules/dnd_rules.gd.
## Serve para validar o build web: rolagem de d20, modificador, proficiência, XP e dano.

var _output: Label
var _str_input: SpinBox
var _level_input: SpinBox
var _xp_input: SpinBox
var _defense_input: SpinBox


func _ready() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation", 12)
	box.offset_left = 40
	box.offset_top = 40
	box.offset_right = -40
	box.offset_bottom = -40
	add_child(box)

	var title := Label.new()
	title.text = "RPG D&D — teste de regras (SRD 5.2)"
	title.add_theme_font_size_override("font_size", 28)
	box.add_child(title)

	_str_input = _spin_row(box, "Valor de atributo", 1, 20, 16)
	_level_input = _spin_row(box, "Nível (teto %d)" % GameConfig.MAX_LEVEL, 1, GameConfig.MAX_LEVEL, 1)
	_xp_input = _spin_row(box, "XP acumulado", 0, 400000, 300)
	_defense_input = _spin_row(box, "Defesa do alvo", 0, 300, 50)

	var roll_button := Button.new()
	roll_button.text = "Rolar d20 + modificador de atributo"
	roll_button.pressed.connect(_on_roll_pressed)
	box.add_child(roll_button)

	var update_button := Button.new()
	update_button.text = "Recalcular nível, proficiência e dano"
	update_button.pressed.connect(_refresh)
	box.add_child(update_button)

	var combat_button := Button.new()
	combat_button.text = "Abrir combate MVP"
	combat_button.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/combat.tscn"))
	box.add_child(combat_button)
	_add_links(box)
	_add_mapa(box)

	_output = Label.new()
	_output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_output)

	_refresh()


func _spin_row(parent: Node, label_text: String, min_v: int, max_v: int, start: int) -> SpinBox:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(260, 0)
	row.add_child(label)
	var spin := SpinBox.new()
	spin.min_value = min_v
	spin.max_value = max_v
	spin.value = start
	spin.rounded = true
	spin.value_changed.connect(func(_v: float) -> void: _refresh())
	row.add_child(spin)
	parent.add_child(row)
	return spin


func _refresh() -> void:
	var level := mini(int(_level_input.value), GameConfig.MAX_LEVEL)
	var xp := int(_xp_input.value)
	var mod := DndRules.ability_modifier(int(_str_input.value))
	var prof := DndRules.proficiency_bonus(level)
	var level_by_xp := DndRules.level_for_xp(xp, GameConfig.MAX_LEVEL)
	var dmg := DndRules.mitigated_damage(10.0, _defense_input.value)
	_output.text = "Modificador: %+d | Proficiência: %+d | Nível pelo XP: %d | Dano base 10 contra defesa %d: %d" % [
		mod, prof, level_by_xp, int(_defense_input.value), dmg,
	]


func _on_roll_pressed() -> void:
	var roll := randi_range(1, 20)
	var mod := DndRules.ability_modifier(int(_str_input.value))
	var prof := DndRules.proficiency_bonus(int(_level_input.value))
	_output.text = "d20 = %d | total com modificador (%+d) = %d | proficiência de referência +%d" % [
		roll, mod, roll + mod, prof,
	]


## Links para os documentos publicados junto com o build.
## No web, o caminho é relativo à página; no desktop, usa a URL completa.
const LINKS := [
	["Comparação de estética", "estetica/", "https://jonnathanproenca.github.io/ProjectBB/estetica/"],
	["Classes (50 → 12)", "classes/", "https://jonnathanproenca.github.io/ProjectBB/classes/"],
	["Armas e equipamentos", "itens/", "https://jonnathanproenca.github.io/ProjectBB/itens/"],
]


func _add_links(box: VBoxContainer) -> void:
	var title := Label.new()
	title.text = "Documentos do projeto"
	box.add_child(title)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	for item in LINKS:
		var button := Button.new()
		button.text = item[0]
		button.pressed.connect(_open_link.bind(item[1], item[2]))
		row.add_child(button)


## Mapa-múndi de Aurel: fica escondido até o botão mostrar.
const MAPA := "res://assets/ui/mapa/mapa_mundo_aurel.jpg"
const LARGURA_MAPA: float = 600.0
var _mapa_imagem: TextureRect


func _add_mapa(box: VBoxContainer) -> void:
	var botao := Button.new()
	botao.text = "Mostrar mapa do mundo"
	box.add_child(botao)

	_mapa_imagem = TextureRect.new()
	_mapa_imagem.texture = load(MAPA)
	_mapa_imagem.custom_minimum_size = Vector2(LARGURA_MAPA, LARGURA_MAPA * 768.0 / 1376.0)
	_mapa_imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mapa_imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mapa_imagem.visible = false
	box.add_child(_mapa_imagem)

	botao.pressed.connect(func() -> void:
		_mapa_imagem.visible = not _mapa_imagem.visible
		botao.text = "Ocultar mapa do mundo" if _mapa_imagem.visible else "Mostrar mapa do mundo")


func _open_link(relative_path: String, url: String) -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.open('%s', '_blank')" % relative_path)
	else:
		OS.shell_open(url)
