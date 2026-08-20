extends Node2D

const SAVE_PATH = "user://aesdivinus_ios12_save.json"
const W = 1024
const H = 768
const FLOOR_Y = 610

var state = "intro"
var t = 0.0
var menu_index = 0
var character_index = 0
var origin_index = 0
var class_index = 0
var typed_name = "William"
var message = "Toque em JOGAR para comecar."

var characters = ["William", "Ethan", "Donovan", "Albert", "Hilda", "Elric"]
var origins = ["Gradon", "Fronteira Wood", "Castelo de Gradon", "Forja de Robert", "Ordem Divina"]
var classes = ["Cavaleiro", "Sentinela", "Lanceiro", "Arqueiro", "Marcado Divino"]

var player = {
	"x": 120.0,
	"y": FLOOR_Y,
	"vx": 0.0,
	"hp": 120,
	"max_hp": 120,
	"coins": 35,
	"xp": 0,
	"level": 1,
	"instinct": 1,
	"weapon": "Espada de Gradon",
	"facing": 1,
	"attack": 0.0
}
var enemy = {"x": 730.0, "hp": 95, "max_hp": 95, "name": "Homis Corruption"}
var buttons = []
var held = {}

func _ready():
	set_process(true)
	set_process_input(true)
	load_game()

func _process(delta):
	t += delta
	if state == "intro" and t > 2.4:
		state = "title"
	if state == "game":
		update_game(delta)
	update()

func update_game(delta):
	var dir = 0
	if held.has("left") and held.left:
		dir -= 1
	if held.has("right") and held.right:
		dir += 1
	player.vx = dir * 220
	player.x = clamp(player.x + player.vx * delta, 40, 960)
	if dir != 0:
		player.facing = dir
	if player.attack > 0:
		player.attack -= delta
	if enemy.hp > 0 and abs(enemy.x - player.x) < 58:
		player.hp = max(0, player.hp - int(18 * delta))
	if player.hp <= 0:
		message = "Voce caiu. Toque em JOGAR para tentar novamente."
		state = "title"

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_BACKSPACE and state == "create" and typed_name.length() > 0:
			typed_name = typed_name.substr(0, typed_name.length() - 1)
		elif state == "create" and event.unicode >= 32 and typed_name.length() < 14:
			typed_name += char(event.unicode)
		elif event.scancode == KEY_SPACE:
			activate("attack")
	if event is InputEventScreenTouch:
		if event.pressed:
			for b in buttons:
				if b.rect.has_point(event.position):
					if b.has("hold") and b.hold:
						held[b.action] = true
					else:
						activate(b.action)
		else:
			held.left = false
			held.right = false
	if event is InputEventScreenDrag:
		pass

func activate(action):
	if state == "title":
		if action == "play":
			state = "create"
		elif action == "load":
			load_game()
			state = "game"
	elif state == "create":
		if action == "char":
			character_index = (character_index + 1) % characters.size()
			typed_name = characters[character_index]
		elif action == "origin":
			origin_index = (origin_index + 1) % origins.size()
		elif action == "class":
			class_index = (class_index + 1) % classes.size()
		elif action == "play":
			new_game()
	elif state == "game":
		if action == "attack":
			player.attack = 0.25
			if abs(enemy.x - player.x) < 120 and enemy.hp > 0:
				enemy.hp = max(0, enemy.hp - 24 - player.level * 4)
				if enemy.hp <= 0:
					player.coins += 40
					player.xp += 50
					player.instinct += 1
					message = "A corrupcao caiu. Moedas e instinto ganharam forca."
					save_game()
		elif action == "mark":
			if player.instinct > 0 and enemy.hp > 0:
				player.instinct -= 1
				enemy.hp = max(0, enemy.hp - 45)
				message = "Marca Divina: luz verde-dourada corta a sombra."
				save_game()
		elif action == "save":
			save_game()
			message = "Progresso salvo no iPad."
		elif action == "title":
			state = "title"

func new_game():
	player.x = 120
	player.hp = player.max_hp
	player.coins = 35
	player.xp = 0
	player.level = 1
	player.instinct = 1
	enemy.hp = enemy.max_hp
	message = typed_name + " desperta na Floresta Wood."
	save_game()
	state = "game"

func save_game():
	var data = {
		"name": typed_name,
		"character": characters[character_index],
		"origin": origins[origin_index],
		"class": classes[class_index],
		"player": player,
		"enemy_hp": enemy.hp
	}
	var f = File.new()
	if f.open(SAVE_PATH, File.WRITE) == OK:
		f.store_string(to_json(data))
		f.close()

func load_game():
	var f = File.new()
	if not f.file_exists(SAVE_PATH):
		return
	if f.open(SAVE_PATH, File.READ) != OK:
		return
	var parsed = parse_json(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	typed_name = str(parsed.get("name", typed_name))
	character_index = max(0, characters.find(str(parsed.get("character", characters[0]))))
	origin_index = max(0, origins.find(str(parsed.get("origin", origins[0]))))
	class_index = max(0, classes.find(str(parsed.get("class", classes[0]))))
	var p = parsed.get("player", {})
	if typeof(p) == TYPE_DICTIONARY:
		for k in p.keys():
			player[k] = p[k]
	enemy.hp = int(parsed.get("enemy_hp", enemy.max_hp))
	message = "Save carregado."

func _draw():
	buttons.clear()
	draw_background()
	if state == "intro":
		draw_intro()
	elif state == "title":
		draw_title()
	elif state == "create":
		draw_create()
	elif state == "game":
		draw_game()
	draw_touch_buttons()

func draw_background():
	draw_rect(Rect2(0, 0, W, H), Color(0.02, 0.018, 0.03))
	for i in range(0, 22):
		var x = float((i * 97) % W)
		var y = float(40 + ((i * 61) % 170))
		draw_circle(Vector2(x, y), 1.5 + sin(t + i) * 0.5, Color(0.85, 0.76, 0.42))
	draw_rect(Rect2(0, FLOOR_Y, W, H - FLOOR_Y), Color(0.09, 0.12, 0.09))
	draw_rect(Rect2(0, FLOOR_Y - 8, W, 8), Color(0.24, 0.42, 0.24))
	for x in range(-80, W + 80, 95):
		draw_polygon([Vector2(x, FLOOR_Y), Vector2(x + 48, 260), Vector2(x + 95, FLOOR_Y)], [Color(0.05, 0.16, 0.12)])

func draw_intro():
	draw_string(get_font("font"), Vector2(360, 310), "AESDIVINUS", Color(0.95, 0.83, 0.35))
	draw_string(get_font("font"), Vector2(300, 354), "Legacy iOS 12 - iPad Air", Color(0.78, 0.9, 0.82))

func draw_title():
	draw_string(get_font("font"), Vector2(338, 210), "AESDIVINUS", Color(1.0, 0.85, 0.32))
	draw_string(get_font("font"), Vector2(250, 260), "A Marca Divina contra a Homis Corruption", Color(0.82, 0.9, 0.82))
	add_button("JOGAR", Rect2(360, 340, 300, 70), "play")
	add_button("CARREGAR", Rect2(360, 430, 300, 70), "load")
	draw_string(get_font("font"), Vector2(250, 540), message, Color(0.9, 0.9, 0.85))

func draw_create():
	draw_string(get_font("font"), Vector2(270, 150), "Criacao de Personagem", Color(1.0, 0.85, 0.32))
	draw_string(get_font("font"), Vector2(260, 220), "Nome: " + typed_name, Color(0.95, 0.95, 0.9))
	add_button("Tipo: " + characters[character_index], Rect2(260, 275, 500, 58), "char")
	add_button("Origem: " + origins[origin_index], Rect2(260, 345, 500, 58), "origin")
	add_button("Classe: " + classes[class_index], Rect2(260, 415, 500, 58), "class")
	add_button("ENTRAR NA FLORESTA", Rect2(300, 515, 420, 70), "play")

func draw_game():
	draw_string(get_font("font"), Vector2(28, 42), typed_name + " - " + classes[class_index] + " de " + origins[origin_index], Color(0.95, 0.95, 0.86))
	draw_bar(Vector2(28, 58), 240, player.hp, player.max_hp, Color(0.82, 0.15, 0.12))
	draw_string(get_font("font"), Vector2(28, 92), "Moedas: " + str(player.coins) + "  Instinto: " + str(player.instinct), Color(0.9, 0.82, 0.45))
	draw_string(get_font("font"), Vector2(28, 118), message, Color(0.82, 0.9, 0.82))
	draw_player(Vector2(player.x, player.y))
	if enemy.hp > 0:
		draw_enemy(Vector2(enemy.x, FLOOR_Y), enemy.name)
		draw_bar(Vector2(enemy.x - 70, FLOOR_Y - 105), 140, enemy.hp, enemy.max_hp, Color(0.55, 0.08, 0.08))
	else:
		draw_string(get_font("font"), Vector2(680, 435), "Gradon respira por enquanto.", Color(0.9, 0.82, 0.45))
	add_button("<", Rect2(42, 640, 92, 86), "left", true)
	add_button(">", Rect2(154, 640, 92, 86), "right", true)
	add_button("ATQ", Rect2(760, 638, 92, 86), "attack")
	add_button("MARCA", Rect2(870, 638, 112, 86), "mark")
	add_button("SALVAR", Rect2(798, 28, 96, 52), "save")
	add_button("MENU", Rect2(906, 28, 86, 52), "title")

func draw_player(pos):
	var color = Color(0.18, 0.48, 0.92)
	if characters[character_index] == "Hilda":
		color = Color(0.75, 0.22, 0.32)
	elif characters[character_index] == "Elric":
		color = Color(0.42, 0.28, 0.72)
	elif characters[character_index] == "Donovan":
		color = Color(0.35, 0.34, 0.32)
	draw_rect(Rect2(pos.x - 17, pos.y - 55, 34, 55), color)
	draw_rect(Rect2(pos.x - 11, pos.y - 72, 22, 20), Color(0.82, 0.65, 0.47))
	draw_rect(Rect2(pos.x + 20 * player.facing, pos.y - 38, 36 * player.facing, 6), Color(0.75, 0.84, 0.72))
	if player.attack > 0:
		draw_arc(Vector2(pos.x + 42 * player.facing, pos.y - 32), 42, -1.0, 1.0, 16, Color(0.9, 0.82, 0.3), 5)

func draw_enemy(pos, label):
	draw_rect(Rect2(pos.x - 24, pos.y - 62, 48, 62), Color(0.22, 0.09, 0.08))
	draw_circle(Vector2(pos.x - 8, pos.y - 45), 4, Color(0.9, 0.15, 0.08))
	draw_circle(Vector2(pos.x + 8, pos.y - 45), 4, Color(0.9, 0.15, 0.08))
	draw_string(get_font("font"), Vector2(pos.x - 72, pos.y - 118), label, Color(0.95, 0.65, 0.58))

func draw_bar(pos, width, value, max_value, color):
	draw_rect(Rect2(pos.x, pos.y, width, 14), Color(0.03, 0.03, 0.04))
	var ratio = 0.0
	if max_value > 0:
		ratio = clamp(float(value) / float(max_value), 0, 1)
	draw_rect(Rect2(pos.x + 2, pos.y + 2, (width - 4) * ratio, 10), color)

func add_button(label, rect, action, hold=false):
	buttons.append({"label": label, "rect": rect, "action": action, "hold": hold})
	draw_rect(rect, Color(0.1, 0.12, 0.14, 0.88))
	draw_rect(rect, Color(0.75, 0.62, 0.28), false, 2)
	draw_string(get_font("font"), Vector2(rect.position.x + 14, rect.position.y + rect.size.y * 0.58), label, Color(0.95, 0.9, 0.72))

func draw_touch_buttons():
	pass
