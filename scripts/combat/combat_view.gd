extends Control
## MVP de combate em grade (M1). Greybox: retângulos e texto.
## Regras: docs/COMBATE.md. Dano e acerto: scripts/rules/dnd_rules.gd.
## Movimento e iniciativa: scripts/combat/combat_rules.gd.
## Ajustes de design: constantes abaixo (ver docs/prototipos/combate-mvp/BRIEF.md).

const CELL: int = 52
const GRID: Vector2i = Vector2i(10, 7)
const ORIGIN: Vector2 = Vector2(40, 110)
const RIFLE_RANGE: int = 16   # casas (24 m)
const MELEE_RANGE: int = 1    # casas
const WALLS: Array = [Vector2i(4, 2), Vector2i(4, 3), Vector2i(4, 4), Vector2i(6, 5), Vector2i(7, 1)]

const COLOR_BG := Color("#16181f")
const COLOR_EMPTY := Color("#22262f")
const COLOR_WALL := Color("#2a2e3a")
const COLOR_GRID := Color("#3b3f4a")
const COLOR_PLAYER := Color("#b8893a")
const COLOR_ENEMY := Color("#7a3b22")
const COLOR_MOVE := Color(0.25, 0.9, 1.0, 0.35)
const COLOR_TARGET := Color(0.85, 0.23, 0.23, 0.45)
const COLOR_DEAD := Color("#4b4f5a")

var units: Array = []
var order: Array = []
var turn_index: int = -1
var round_num: int = 1
var selected: int = -1
var mode: String = "move"
var ended: bool = false
var reach: Dictionary = {}
var log_lines: Array = []
var rng := RandomNumberGenerator.new()

var status_label: Label
var log_label: Label


func _ready() -> void:
	rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	_start_combat()


# --- Interface ---------------------------------------------------------------

func _build_ui() -> void:
	var bar := HBoxContainer.new()
	bar.position = Vector2(40, 12)
	bar.add_theme_constant_override("separation", 8)
	add_child(bar)
	_add_button(bar, "Mover", _set_mode.bind("move"))
	_add_button(bar, "Atacar", _set_mode.bind("attack"))
	_add_button(bar, "Disparo focado", _set_mode.bind("focus"))
	_add_button(bar, "Encerrar turno", _end_turn)
	_add_button(bar, "Recarregar (teste)", _recharge)
	_add_button(bar, "Reiniciar", _start_combat)
	_add_button(bar, "Voltar", _back)

	status_label = Label.new()
	status_label.position = Vector2(40, 64)
	add_child(status_label)

	log_label = Label.new()
	log_label.position = Vector2(40, 500)
	add_child(log_label)


func _add_button(parent: Node, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)


func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


# --- Combate -----------------------------------------------------------------

func _start_combat() -> void:
	units = [
		_make("Guerreiro", "player", Vector2i(1, 2), 16, 15, 20, 6, true, 1, 8, 3, 0),
		_make("Atirador", "player", Vector2i(1, 4), 12, 13, 16, 6, false, 1, 8, 3, 3),
		_make("Bandido A", "enemy", Vector2i(8, 1), 9, 12, 10, 6, true, 1, 6, 1, 0),
		_make("Bandido B", "enemy", Vector2i(8, 3), 9, 12, 10, 6, true, 1, 6, 1, 0),
		_make("Bandido C", "enemy", Vector2i(8, 5), 9, 12, 10, 6, true, 1, 6, 1, 0),
	]
	var entries: Array = []
	for i in range(units.size()):
		entries.append({"idx": i, "name": units[i]["name"], "roll": rng.randi_range(1, 20)})
	var sorted: Array = CombatRules.order_by_initiative(entries)
	order = []
	for e in sorted:
		order.append(e["idx"])
	turn_index = -1
	round_num = 1
	selected = -1
	ended = false
	log_lines = []
	_log("Iniciativa: " + _join(_names_in_order(), ", "))
	_log("— Rodada 1 —")
	_advance()


func _make(n: String, team: String, pos: Vector2i, hp: int, ac: int, defense: int, speed: int,
		melee: bool, dice_n: int, dice_s: int, bonus: int, charges: int) -> Dictionary:
	return {
		"name": n, "team": team, "pos": pos,
		"hp": hp, "max_hp": hp, "ac": ac, "defense": defense, "speed": speed,
		"melee": melee, "dice_n": dice_n, "dice_s": dice_s, "bonus": bonus,
		"charges": charges, "max_charges": charges,
		"move_left": speed, "reaction": true, "acted": false, "alive": true,
	}


func _names_in_order() -> Array:
	var names: Array = []
	for idx in order:
		names.append(units[idx]["name"])
	return names


func _advance() -> void:
	if ended or _check_end():
		_refresh()
		return
	turn_index += 1
	if turn_index >= order.size():
		turn_index = 0
		round_num += 1
		_log("— Rodada %d —" % round_num)
	var i: int = order[turn_index]
	var u: Dictionary = units[i]
	if not u["alive"]:
		_advance()
		return
	u["move_left"] = u["speed"]
	u["reaction"] = true
	u["acted"] = false
	if u["team"] == "enemy":
		_enemy_turn(i)
		_advance()
		return
	selected = i
	_log("Turno de %s." % u["name"])
	_refresh()


func _check_end() -> bool:
	var players := 0
	var enemies := 0
	for u in units:
		if u["alive"]:
			if u["team"] == "player":
				players += 1
			else:
				enemies += 1
	if enemies == 0:
		ended = true
		_log("Vitória!")
		return true
	if players == 0:
		ended = true
		_log("Derrota.")
		return true
	return false


func _is_player_turn() -> bool:
	if ended or turn_index < 0:
		return false
	return units[order[turn_index]]["team"] == "player"


func _end_turn() -> void:
	if not _is_player_turn():
		return
	_log("%s encerra o turno." % units[selected]["name"])
	_advance()


func _recharge() -> void:
	for u in units:
		if u["team"] == "player" and u["max_charges"] > 0:
			u["charges"] = u["max_charges"]
	_log("Cargas do rifle restauradas (teste).")
	_refresh()


# --- Turno do inimigo (IA simples) -------------------------------------------

func _enemy_turn(i: int) -> void:
	var u: Dictionary = units[i]
	var target := _adjacent_player(u["pos"])
	if target >= 0:
		_attack(i, target, "normal")
		return
	var cells: Dictionary = CombatRules.reachable(u["pos"], u["move_left"], _blocked_cells(i), GRID)
	var best: Vector2i = u["pos"]
	var best_cost: int = 0
	var best_dist: int = _nearest_player_distance(u["pos"])
	for key in cells.keys():
		var c: Vector2i = key
		var d: int = _nearest_player_distance(c)
		if d < best_dist:
			best = c
			best_cost = cells[c]
			best_dist = d
	if best != u["pos"]:
		_move(i, best, best_cost)
	target = _adjacent_player(u["pos"])
	if target >= 0 and u["alive"]:
		_attack(i, target, "normal")


func _adjacent_player(pos: Vector2i) -> int:
	var found: int = -1
	var found_hp: int = 999
	for j in range(units.size()):
		var o: Dictionary = units[j]
		if o["alive"] and o["team"] == "player" and _cheb(o["pos"], pos) <= MELEE_RANGE:
			if o["hp"] < found_hp:
				found = j
				found_hp = o["hp"]
	return found


func _nearest_player_distance(pos: Vector2i) -> int:
	var best: int = 999
	for o in units:
		if o["alive"] and o["team"] == "player":
			best = mini(best, _cheb(o["pos"], pos))
	return best


# --- Ações --------------------------------------------------------------------

func _move(i: int, dest: Vector2i, cost: int) -> void:
	var u: Dictionary = units[i]
	var from: Vector2i = u["pos"]
	u["pos"] = dest
	u["move_left"] = u["move_left"] - cost
	_log("%s se move (%d casa(s))." % [u["name"], cost])
	_trigger_reactions(i, from, dest)
	_refresh()


func _trigger_reactions(mover: int, from: Vector2i, to: Vector2i) -> void:
	for j in range(units.size()):
		var o: Dictionary = units[j]
		if not o["alive"] or o["team"] == units[mover]["team"]:
			continue
		if not o["melee"] or not o["reaction"]:
			continue
		if _cheb(o["pos"], from) == MELEE_RANGE and _cheb(o["pos"], to) > MELEE_RANGE:
			o["reaction"] = false
			_log("%s usa a reação: ataque de oportunidade!" % o["name"])
			_attack(j, mover, "normal")
			if not units[mover]["alive"]:
				return


func _attack(a: int, t: int, kind: String) -> void:
	var att: Dictionary = units[a]
	var tgt: Dictionary = units[t]
	if kind == "focus":
		att["charges"] = att["charges"] - 1
	att["acted"] = true
	var roll: int = rng.randi_range(1, 20)
	var hit: bool = DndRules.attack_hits(roll, att["bonus"], tgt["ac"])
	if not hit:
		_log("%s erra %s (d20 = %d)." % [att["name"], tgt["name"], roll])
		_check_end()
		_refresh()
		return
	var dice_n: int = att["dice_n"] * (2 if kind == "focus" else 1)
	var raw: int = 0
	for k in range(dice_n):
		raw += rng.randi_range(1, att["dice_s"])
	if roll == 20:
		for k in range(dice_n):
			raw += rng.randi_range(1, att["dice_s"])
		_log("Acerto crítico!")
	raw += att["bonus"]
	var dmg: int = DndRules.mitigated_damage(float(raw), float(tgt["defense"]))
	tgt["hp"] = tgt["hp"] - dmg
	_log("%s acerta %s: %d de dano." % [att["name"], tgt["name"], dmg])
	if tgt["hp"] <= 0:
		tgt["alive"] = false
		_log("%s caiu." % tgt["name"])
	_check_end()
	_refresh()


# --- Entrada ------------------------------------------------------------------

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_click(event.position)


func _on_click(p: Vector2) -> void:
	if ended:
		return
	var cell := _cell_at(p)
	if cell == Vector2i(-1, -1):
		return
	var idx: int = _unit_at(cell)
	if idx >= 0 and units[idx]["team"] == "player" and units[idx]["alive"]:
		if _is_player_turn() and idx == order[turn_index]:
			selected = idx
		_refresh()
		return
	if not _is_player_turn() or selected < 0:
		return
	var me: Dictionary = units[selected]
	match mode:
		"move":
			if idx >= 0:
				return
			if reach.has(cell):
				_move(selected, cell, reach[cell])
		"attack", "focus":
			if idx < 0 or units[idx]["team"] != "enemy" or not units[idx]["alive"]:
				return
			if me["acted"]:
				_log("%s já usou a ação neste turno." % me["name"])
				_refresh()
				return
			var max_range: int = MELEE_RANGE if me["melee"] else RIFLE_RANGE
			if _cheb(me["pos"], cell) > max_range:
				_log("Fora de alcance.")
				_refresh()
				return
			if mode == "focus":
				if me["max_charges"] == 0 or me["charges"] <= 0:
					_log("Sem cargas no rifle. Use Recarregar (teste).")
					_refresh()
					return
				_attack(selected, idx, "focus")
			else:
				_attack(selected, idx, "normal")
	_refresh()


func _set_mode(m: String) -> void:
	mode = m
	_refresh()


func _cell_at(p: Vector2) -> Vector2i:
	var local: Vector2 = (p - ORIGIN) / CELL
	var c := Vector2i(floori(local.x), floori(local.y))
	if c.x < 0 or c.y < 0 or c.x >= GRID.x or c.y >= GRID.y:
		return Vector2i(-1, -1)
	return c


func _unit_at(cell: Vector2i) -> int:
	for j in range(units.size()):
		if units[j]["alive"] and units[j]["pos"] == cell:
			return j
	return -1


func _blocked_cells(exclude: int) -> Dictionary:
	var blocked: Dictionary = {}
	for w in WALLS:
		blocked[w] = true
	for j in range(units.size()):
		if j != exclude and units[j]["alive"]:
			blocked[units[j]["pos"]] = true
	return blocked


func _cheb(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


# --- Visual -------------------------------------------------------------------

func _refresh() -> void:
	reach = {}
	if _is_player_turn() and selected >= 0 and mode == "move" and units[selected]["alive"]:
		reach = CombatRules.reachable(units[selected]["pos"], units[selected]["move_left"], _blocked_cells(selected), GRID)
	_update_labels()
	queue_redraw()


func _update_labels() -> void:
	var active: String = "-"
	if turn_index >= 0 and turn_index < order.size():
		active = units[order[turn_index]]["name"]
	var sel_text: String = "nenhum"
	if selected >= 0:
		var u: Dictionary = units[selected]
		sel_text = "%s · casas restantes %d · cargas %d/%d" % [u["name"], u["move_left"], u["charges"], u["max_charges"]]
	status_label.text = "Rodada %d · Vez: %s · Modo: %s · Selecionado: %s" % [round_num, active, mode, sel_text]
	log_label.text = _join(log_lines.slice(maxi(0, log_lines.size() - 8)), "\n")


func _join(items: Array, sep: String) -> String:
	var out: String = ""
	for i in range(items.size()):
		if i > 0:
			out += sep
		out += str(items[i])
	return out


func _log(text: String) -> void:
	log_lines.append(text)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BG)
	var font: Font = ThemeDB.fallback_font
	for y in range(GRID.y):
		for x in range(GRID.x):
			var c := Vector2i(x, y)
			var r := Rect2(ORIGIN + Vector2(x, y) * CELL, Vector2(CELL, CELL))
			var fill: Color = COLOR_WALL if WALLS.has(c) else COLOR_EMPTY
			draw_rect(r, fill)
			draw_rect(r, COLOR_GRID, false, 1.0)
			if reach.has(c):
				draw_rect(r, COLOR_MOVE)
	if selected >= 0 and (mode == "attack" or mode == "focus"):
		for u in units:
			if u["alive"] and u["team"] == "enemy":
				draw_rect(_cell_rect(u["pos"]), COLOR_TARGET)
	for j in range(units.size()):
		_draw_unit(j, font)


func _cell_rect(c: Vector2i) -> Rect2:
	return Rect2(ORIGIN + Vector2(c.x, c.y) * CELL, Vector2(CELL, CELL))


func _draw_unit(j: int, font: Font) -> void:
	var u: Dictionary = units[j]
	var r := _cell_rect(u["pos"]).grow(-6)
	if not u["alive"]:
		draw_rect(r, COLOR_DEAD)
		draw_line(r.position, r.end, Color.WHITE, 2.0)
		draw_line(Vector2(r.end.x, r.position.y), Vector2(r.position.x, r.end.y), Color.WHITE, 2.0)
		return
	var color: Color = COLOR_PLAYER if u["team"] == "player" else COLOR_ENEMY
	draw_rect(r, color)
	draw_rect(r, Color("#0d0f14"), false, 2.0)
	if j == selected:
		draw_rect(r.grow(3), Color.WHITE, false, 3.0)
	var initial: String = String(u["name"]).substr(0, 1)
	draw_string(font, r.position + Vector2(0, r.size.y * 0.62), initial, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 22, Color.WHITE)
	var ratio: float = float(u["hp"]) / float(u["max_hp"])
	var bar := Rect2(r.position + Vector2(4, r.size.y + 2), Vector2(r.size.x - 8, 4))
	draw_rect(bar, Color("#0d0f14"))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(ratio, 0.0, 1.0), bar.size.y)), Color("#3fe0ff"))
