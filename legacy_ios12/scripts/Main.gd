extends Node2D

const DB_PATH = "user://aesdivinus_ios12_db.json"
const BUILD_VERSION = "1.4.0-ios12"
const W = 1024
const H = 768
const FLOOR_Y = 610
const WORLD_W = 2600

var state = "intro"
var overlay = ""
var t = 0.0
var transition = 1.0
var transition_title = "A MARCA DESPERTA"
var message = "Entre em AESDIVINUS."
var ui_font = null
var buttons = []
var held = {}
var active_field = "email"

var account = {"id": "", "email": "convidado@aesdivinus.local", "name": "Convidado", "logged_in": false, "registered": false}
var login_password = ""
var register_password = ""
var current_user_id = "guest"
var db = {"version": BUILD_VERSION, "users": {}, "events": []}

var maps = [
	{
		"title": "Floresta Wood 1.1",
		"goal": "Aprenda movimento, coleta e combate.",
		"spawn": 120.0,
		"enemies": [
			{"name": "Homem Corrupto", "type": "barbarian", "x": 820.0, "hp": 55, "max_hp": 55},
			{"name": "Servus Belli Larva", "type": "servi", "x": 1380.0, "hp": 75, "max_hp": 75}
		],
		"items": [
			{"name": "Aes Divinus", "x": 520.0, "amount": 2, "taken": false},
			{"name": "Fragmento de Ferro", "x": 1120.0, "amount": 1, "taken": false}
		],
		"npcs": [{"name": "Ethan", "x": 300.0, "lines": ["A trilha escureceu cedo demais.", "Mantenha a espada pronta."]}]
	},
	{
		"title": "Floresta Wood 1.2",
		"goal": "Sobreviva a emboscada e avance.",
		"spawn": 120.0,
		"enemies": [
			{"name": "Barbaro Corrupto", "type": "barbarian", "x": 760.0, "hp": 70, "max_hp": 70},
			{"name": "Canis Ferox", "type": "canis", "x": 1240.0, "hp": 95, "max_hp": 95},
			{"name": "Bestia Ignis", "type": "ignis", "x": 1900.0, "hp": 135, "max_hp": 135}
		],
		"items": [{"name": "Relato Manchado", "x": 980.0, "amount": 1, "taken": false}],
		"npcs": []
	},
	{
		"title": "Floresta Wood 1.3",
		"goal": "Derrote o Ogre Larva Belli.",
		"spawn": 120.0,
		"enemies": [{"name": "Ogre Larva Belli", "type": "boss", "x": 1720.0, "hp": 280, "max_hp": 280}],
		"items": [{"name": "Aes Divinus", "x": 650.0, "amount": 3, "taken": false}],
		"npcs": [
			{"name": "Donovan", "x": 350.0, "lines": ["Nao tente salvar todos sozinho."]},
			{"name": "Hilda", "x": 455.0, "lines": ["A floresta pune quem hesita."]},
			{"name": "Elric", "x": 560.0, "lines": ["A marca reage ao sangue derramado."]}
		]
	}
]

var map_index = 0
var enemies = []
var items = []
var npcs = []
var camera_x = 0.0

var character_types = ["William", "Ethan", "Donovan", "Albert", "Hilda", "Elric"]
var class_options = ["Cavaleiro", "Sentinela", "Mercenario", "Lanceiro", "Arqueiro", "Ferreiro", "Estrategista", "Marcado Divino"]
var origin_options = ["Gradon", "Fronteira Wood", "Castelo de Gradon", "Sala do Conselho", "Aposentos Militares", "Forja de Robert Smith", "Casa Exilada", "Ordem Divina"]
var character_profile = {"name": "William", "type": "William", "class": "Cavaleiro", "origin": "Gradon", "created": false}
var type_i = 0
var class_i = 0
var origin_i = 0

var player = {
	"x": 120.0, "vx": 0.0, "facing": 1,
	"hp": 120, "max_hp": 120, "stamina": 100.0, "courage": 100.0,
	"coins": 35, "skill_points": 1, "instinct_points": 1, "level": 1, "xp": 0,
	"attack": 0.0, "block": 0.0, "dodge": 0.0,
	"equipment": {"weapon": "Espada de Gradon", "tool": "Kit de Campanha", "armor": "Couro militar"},
	"weapon_levels": {"Espada de Gradon": 1},
	"tool_levels": {"Kit de Campanha": 1},
	"skills": {"Forca": 0, "Defesa": 0, "Agilidade": 0, "Fe": 0, "Honra": 0},
	"instincts": {"Sobrevivencia": 0, "Percepcao": 0, "Furia Controlada": 0, "Marca Divina": 0},
	"inventory": {"Aes Divinus": 0, "Fragmento de Ferro": 0, "Relato Manchado": 0, "Racao": 1}
}

var weapon_catalog = {
	"Espada de Gradon": {"damage": 9, "price": 0},
	"Lamina de Ferro": {"damage": 14, "price": 80},
	"Machado de Donovan": {"damage": 20, "price": 130},
	"Lanca de Hilda": {"damage": 17, "price": 110},
	"Cajado de Elric": {"damage": 12, "price": 95},
	"Espada Aes": {"damage": 24, "price": 180},
	"Lanca Aes": {"damage": 22, "price": 170},
	"Alabarda Aes": {"damage": 30, "price": 220}
}
var recipes = [
	{"name": "Lamina de Ferro", "kind": "weapon", "cost": {"Fragmento de Ferro": 2}, "coins": 20},
	{"name": "Machado de Donovan", "kind": "weapon", "cost": {"Fragmento de Ferro": 3, "Aes Divinus": 1}, "coins": 35},
	{"name": "Lanca de Hilda", "kind": "weapon", "cost": {"Fragmento de Ferro": 2, "Aes Divinus": 1}, "coins": 30},
	{"name": "Cajado de Elric", "kind": "weapon", "cost": {"Aes Divinus": 2}, "coins": 45},
	{"name": "Espada Aes", "kind": "weapon", "cost": {"Aes Divinus": 3, "Fragmento de Ferro": 2}, "coins": 80},
	{"name": "Picareta de Robert", "kind": "tool", "cost": {"Fragmento de Ferro": 2}, "coins": 25},
	{"name": "Bolsa de Mercador", "kind": "tool", "cost": {"Relato Manchado": 1, "Fragmento de Ferro": 1}, "coins": 30}
]
var shop_items = [
	{"name": "Racao", "price": 18, "sell": 7},
	{"name": "Aes Divinus", "price": 65, "sell": 26},
	{"name": "Fragmento de Ferro", "price": 32, "sell": 12},
	{"name": "Relato Manchado", "price": 45, "sell": 18}
]
var codex = [
	"Homis Corruption: humanos usados por deuses corrompidos em rituais.",
	"Servi Belli Larvae: cadaveres usados como tropa de choque.",
	"Ogre Larva Belli: evolucao brutal dos Servi.",
	"Aes Divinus: minerio verde-dourado usado em armas sagradas.",
	"Canis Ferox: caes corrompidos usados para caca.",
	"Bestia Ignis: abominacao com fogo, dentes e veneno.",
	"Marca de Gloregni: marca de reis e principes.",
	"Marca de Iusdicta: revela pecados e corrupcao.",
	"Marca de Thofestoe: criacao, forja e ferramentas.",
	"Marca de Satiae: conhecimento e leitura das pessoas.",
	"Marca Miseritae: cura e protecao da vida."
]

var quality_order = ["Compatibilidade", "Baixo", "Medio", "Alto"]
var settings = {"quality": "Compatibilidade", "fps": 30, "particles": false, "contrast": false}
var inv_i = 0
var equip_i = 0
var forge_i = 0
var shop_i = 0
var prog_i = 0
var set_i = 0
var codex_i = 0

func _ready():
	randomize()
	var font_source = Label.new()
	add_child(font_source)
	ui_font = font_source.get_font("font")
	font_source.hide()
	set_process(true)
	set_process_input(true)
	_db_load()
	_load_map(0)
	_apply_settings()
	if OS.get_cmdline_args().has("--smoke-test"):
		_run_smoke_test()

func _process(delta):
	t += delta
	transition = max(0.0, transition - delta)
	if state == "intro" and t > 2.2:
		_go("title", "AESDIVINUS")
	if state == "game" and overlay == "":
		_update_game(delta)
	update()

func _input(event):
	if event is InputEventKey and event.pressed:
		_key(event)
	if event is InputEventScreenTouch:
		if event.pressed:
			for b in buttons:
				if b.rect.has_point(event.position):
					if b.has("hold") and b.hold:
						held[b.action] = true
					else:
						_activate(b.action)
		else:
			held.left = false
			held.right = false
			held.run = false

func _key(event):
	if event.scancode == KEY_ESCAPE:
		_activate("back")
	elif event.scancode == KEY_ENTER or event.scancode == KEY_SPACE:
		_activate("ok")
	elif event.scancode == KEY_TAB:
		_next_field()
	elif event.scancode == KEY_BACKSPACE:
		_backspace_field()
	elif state in ["login", "register", "create"] and event.unicode >= 32:
		_type_char(char(event.unicode))
	elif event.scancode == KEY_Q:
		_activate("mark")
	elif event.scancode == KEY_I:
		_open_overlay("inventory")
	elif event.scancode == KEY_E:
		_activate("interact")
	elif event.scancode == KEY_J:
		_activate("attack")
	elif event.scancode == KEY_K:
		_activate("dodge")
	elif event.scancode == KEY_L:
		_activate("block")
	held.left = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
	held.right = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)
	held.run = Input.is_key_pressed(KEY_SHIFT)

func _go(next_state, title):
	state = next_state
	overlay = ""
	transition = 0.85
	transition_title = title

func _activate(action):
	if overlay != "":
		_overlay_action(action)
		return
	if state == "title":
		if action == "play":
			_go("login", "PORTAO DE GRADON")
		elif action == "guest":
			_guest_login()
		elif action == "load":
			_load_save()
			_go("game", "SAVE CARREGADO")
	elif state == "login":
		if action == "field":
			_next_field()
		elif action == "login":
			_login()
		elif action == "register":
			_go("register", "CADASTRO")
		elif action == "guest":
			_guest_login()
	elif state == "register":
		if action == "field":
			_next_field()
		elif action == "register":
			_register()
		elif action == "login":
			_go("login", "LOGIN")
	elif state == "create":
		if action == "field":
			active_field = "name"
		elif action == "type":
			type_i = (type_i + 1) % character_types.size()
			character_profile.type = character_types[type_i]
			if character_profile.name == "":
				character_profile.name = character_profile.type
		elif action == "origin":
			origin_i = (origin_i + 1) % origin_options.size()
			character_profile.origin = origin_options[origin_i]
		elif action == "class":
			class_i = (class_i + 1) % class_options.size()
			character_profile["class"] = class_options[class_i]
		elif action == "start":
			_new_game()
	elif state == "game":
		if action == "left" or action == "right" or action == "run":
			held[action] = true
		elif action == "attack":
			_attack()
		elif action == "mark":
			_divine_mark()
		elif action == "block":
			player.block = 0.55
		elif action == "dodge":
			player.dodge = 0.22
			player.x = clamp(player.x + 120 * player.facing, 30, WORLD_W - 30)
		elif action == "interact":
			_interact()
		elif action == "pause":
			_open_overlay("inventory")

func _overlay_action(action):
	if action == "back":
		overlay = ""
		_save_game()
		return
	if action == "next":
		_cycle_overlay(1)
	elif action == "prev":
		_cycle_overlay(-1)
	elif action in ["inventory", "equipment", "forge", "shop", "progress", "settings", "codex", "map"]:
		_open_overlay(action)
	elif action == "ok":
		_overlay_ok()
	elif action == "up":
		_change_selection(-1)
	elif action == "down":
		_change_selection(1)
	elif action == "save":
		_save_game()
		message = "Banco local salvo."
	elif action == "title":
		_save_game()
		_go("title", "MENU")

func _open_overlay(name):
	if state == "game":
		overlay = name
		transition = 0.25

func _cycle_overlay(dir):
	var order = ["inventory", "equipment", "forge", "shop", "progress", "settings", "codex", "map"]
	var idx = max(0, order.find(overlay))
	overlay = order[(idx + dir + order.size()) % order.size()]

func _change_selection(dir):
	if overlay == "inventory":
		inv_i = max(0, inv_i + dir)
	elif overlay == "equipment":
		equip_i = max(0, equip_i + dir)
	elif overlay == "forge":
		forge_i = clamp(forge_i + dir, 0, recipes.size() - 1)
	elif overlay == "shop":
		shop_i = clamp(shop_i + dir, 0, shop_items.size() - 1)
	elif overlay == "progress":
		prog_i = clamp(prog_i + dir, 0, 8)
	elif overlay == "settings":
		set_i = clamp(set_i + dir, 0, 3)
	elif overlay == "codex":
		codex_i = clamp(codex_i + dir, 0, codex.size() - 1)
	elif overlay == "map":
		map_index = clamp(map_index + dir, 0, maps.size() - 1)
		_load_map(map_index)

func _overlay_ok():
	if overlay == "forge":
		_craft()
	elif overlay == "shop":
		_buy()
	elif overlay == "progress":
		_upgrade_progress()
	elif overlay == "settings":
		_toggle_setting()
	elif overlay == "equipment":
		_equip_selected()
	elif overlay == "map":
		player.x = float(maps[map_index].spawn)
		message = "Viagem para " + maps[map_index].title + "."
		_save_game()

func _next_field():
	if state == "login":
		active_field = "password" if active_field == "email" else "email"
	elif state == "register":
		if active_field == "email":
			active_field = "name"
		elif active_field == "name":
			active_field = "password"
		else:
			active_field = "email"
	elif state == "create":
		active_field = "name"

func _type_char(ch):
	if state == "login":
		if active_field == "email" and account.email.length() < 34:
			account.email += ch
		elif active_field == "password" and login_password.length() < 20:
			login_password += ch
	elif state == "register":
		if active_field == "email" and account.email.length() < 34:
			account.email += ch
		elif active_field == "name" and account.name.length() < 18:
			account.name += ch
		elif active_field == "password" and register_password.length() < 20:
			register_password += ch
	elif state == "create" and active_field == "name" and character_profile.name.length() < 18:
		character_profile.name += ch

func _backspace_field():
	if state in ["login", "register"] and active_field == "email" and account.email.length() > 0:
		account.email = account.email.substr(0, account.email.length() - 1)
	elif state == "register" and active_field == "name" and account.name.length() > 0:
		account.name = account.name.substr(0, account.name.length() - 1)
	elif active_field == "password":
		if state == "login" and login_password.length() > 0:
			login_password = login_password.substr(0, login_password.length() - 1)
		elif state == "register" and register_password.length() > 0:
			register_password = register_password.substr(0, register_password.length() - 1)
	elif state == "create" and character_profile.name.length() > 0:
		character_profile.name = character_profile.name.substr(0, character_profile.name.length() - 1)

func _user_id(email):
	return email.strip_edges().to_lower().replace("@", "_at_").replace(".", "_")

func _guest_login():
	current_user_id = "guest"
	account = {"id": "guest", "email": "convidado@aesdivinus.local", "name": "Convidado", "logged_in": true, "registered": false}
	if not db.users.has(current_user_id):
		db.users[current_user_id] = {"account": account, "save": {}, "characters": {}, "settings": settings}
	_db_save()
	_go("create", "CRIACAO")

func _register():
	if account.email.find("@") == -1 or register_password.length() < 4:
		message = "Email invalido ou senha curta."
		return
	current_user_id = _user_id(account.email)
	account.id = current_user_id
	account.logged_in = true
	account.registered = true
	db.users[current_user_id] = {"account": account.duplicate(true), "password": register_password, "save": {}, "characters": {}, "settings": settings}
	_db_save()
	message = "Cadastro criado."
	_go("create", "PERSONAGEM")

func _login():
	current_user_id = _user_id(account.email)
	if not db.users.has(current_user_id):
		message = "Usuario nao encontrado."
		return
	var user = db.users[current_user_id]
	if str(user.get("password", "")) != login_password:
		message = "Senha incorreta."
		return
	account = user.get("account", account)
	account.logged_in = true
	_load_save()
	_go("game" if bool(character_profile.created) else "create", "ENTRADA")

func _db_load():
	var f = File.new()
	if not f.file_exists(DB_PATH):
		return
	if f.open(DB_PATH, File.READ) != OK:
		return
	var parsed = parse_json(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		db = parsed

func _db_save():
	db.version = BUILD_VERSION
	var f = File.new()
	if f.open(DB_PATH, File.WRITE) == OK:
		f.store_string(to_json(db))
		f.close()

func _save_game():
	if current_user_id == "":
		current_user_id = "guest"
	var user = db.users.get(current_user_id, {"account": account, "save": {}, "characters": {}, "settings": settings})
	user.account = account.duplicate(true)
	user.settings = settings.duplicate(true)
	user.save = {
		"map_index": map_index,
		"player": player.duplicate(true),
		"character": character_profile.duplicate(true),
		"items": items.duplicate(true),
		"enemies": enemies.duplicate(true)
	}
	user.characters[character_profile.name] = character_profile.duplicate(true)
	db.users[current_user_id] = user
	_db_save()

func _load_save():
	if not db.users.has(current_user_id):
		return
	var user = db.users[current_user_id]
	settings = user.get("settings", settings)
	var save = user.get("save", {})
	if typeof(save) != TYPE_DICTIONARY or save.empty():
		return
	map_index = clamp(int(save.get("map_index", 0)), 0, maps.size() - 1)
	player = save.get("player", player)
	character_profile = save.get("character", character_profile)
	_sync_character_indices()
	_load_map(map_index)
	items = save.get("items", items)
	enemies = save.get("enemies", enemies)
	_apply_settings()
	message = "Save carregado do banco local."

func _new_game():
	character_profile.created = true
	_apply_character_template()
	player.x = float(maps[0].spawn)
	map_index = 0
	_load_map(0)
	message = character_profile.name + " desperta na Floresta Wood."
	_save_game()
	_go("game", "FLORESTA WOOD")

func _apply_character_template():
	player.max_hp = 120
	player.stamina = 100
	player.courage = 100
	if character_profile["class"] == "Sentinela":
		player.max_hp = 145
	elif character_profile["class"] == "Arqueiro":
		player.stamina = 125
	elif character_profile["class"] == "Ferreiro":
		player.inventory["Fragmento de Ferro"] = int(player.inventory.get("Fragmento de Ferro", 0)) + 2
	elif character_profile["class"] == "Marcado Divino":
		player.instinct_points = int(player.instinct_points) + 1
	if character_profile.origin == "Forja de Robert Smith":
		player.coins += 20
	player.hp = player.max_hp

func _sync_character_indices():
	type_i = max(0, character_types.find(str(character_profile.get("type", "William"))))
	class_i = max(0, class_options.find(str(character_profile.get("class", "Cavaleiro"))))
	origin_i = max(0, origin_options.find(str(character_profile.get("origin", "Gradon"))))

func _load_map(idx):
	map_index = clamp(idx, 0, maps.size() - 1)
	enemies = []
	for e in maps[map_index].enemies:
		enemies.append(e.duplicate(true))
	items = []
	for it in maps[map_index].items:
		items.append(it.duplicate(true))
	npcs = []
	for n in maps[map_index].npcs:
		npcs.append(n.duplicate(true))

func _update_game(delta):
	var dir = 0
	if held.has("left") and held.left:
		dir -= 1
	if held.has("right") and held.right:
		dir += 1
	var speed = 215
	if held.has("run") and held.run and player.stamina > 0:
		speed = 305
		player.stamina = max(0, player.stamina - 24 * delta)
	else:
		player.stamina = min(100, player.stamina + 18 * delta)
	player.vx = dir * speed
	player.x = clamp(player.x + player.vx * delta, 30, WORLD_W - 30)
	if dir != 0:
		player.facing = dir
	camera_x = clamp(player.x - W * 0.45, 0, WORLD_W - W)
	player.attack = max(0, player.attack - delta)
	player.block = max(0, player.block - delta)
	player.dodge = max(0, player.dodge - delta)
	for e in enemies:
		if int(e.hp) <= 0:
			continue
		var dist = abs(float(e.x) - player.x)
		if dist < 62 and player.dodge <= 0:
			var dmg = 8
			if e.type == "boss":
				dmg = 18
			elif e.type == "ignis":
				dmg = 14
			if player.block > 0:
				dmg = int(dmg * 0.35)
			player.hp = max(0, int(player.hp) - int(dmg * delta))
	if int(player.hp) <= 0:
		message = "Voce caiu. Use carregar ou novo jogo."
		_save_game()
		_go("title", "DERROTA")

func _attack():
	player.attack = 0.24
	var dmg = _weapon_damage()
	for e in enemies:
		if int(e.hp) > 0 and abs(float(e.x) - player.x) < _attack_range():
			e.hp = max(0, int(e.hp) - dmg)
			if int(e.hp) <= 0:
				_gain_rewards(e)
			break

func _divine_mark():
	if int(player.instinct_points) <= 0:
		message = "Sem instinto para a Marca."
		return
	player.instinct_points = int(player.instinct_points) - 1
	for e in enemies:
		if int(e.hp) > 0 and abs(float(e.x) - player.x) < 240:
			e.hp = max(0, int(e.hp) - 58 - int(player.skills.get("Fe", 0)) * 8)
			message = "Marca Divina corta a corrupcao."
			if int(e.hp) <= 0:
				_gain_rewards(e)
			_save_game()
			return
	message = "A Marca pulsa, mas nao encontra alvo."

func _weapon_damage():
	var weapon = str(player.equipment.weapon)
	var base = int(weapon_catalog.get(weapon, {"damage": 9}).damage)
	var level = int(player.weapon_levels.get(weapon, 1))
	return base + level * 3 + int(player.skills.get("Forca", 0)) * 4

func _attack_range():
	var w = str(player.equipment.weapon)
	if w.find("Lanca") != -1 or w.find("Alabarda") != -1:
		return 155
	return 112

func _gain_rewards(e):
	var reward = 35
	if e.type == "boss":
		reward = 120
	player.coins += reward
	player.xp += 50
	if int(player.xp) >= int(player.level) * 100:
		player.xp = 0
		player.level += 1
		player.skill_points += 1
		player.instinct_points += 1
	message = e.name + " derrotado. Moedas e experiencia recebidas."
	_save_game()

func _interact():
	for it in items:
		if not bool(it.taken) and abs(float(it.x) - player.x) < 54:
			it.taken = true
			player.inventory[it.name] = int(player.inventory.get(it.name, 0)) + int(it.amount)
			message = "Coletado: " + it.name
			_save_game()
			return
	for n in npcs:
		if abs(float(n.x) - player.x) < 62:
			message = n.name + ": " + str(n.lines[0])
			return
	if _all_enemies_defeated() and map_index < maps.size() - 1:
		_load_map(map_index + 1)
		player.x = float(maps[map_index].spawn)
		message = "Novo trecho: " + maps[map_index].title
		_save_game()
	elif _all_enemies_defeated():
		message = "Prologo vencido. Gradon ainda precisa de voce."
		_save_game()

func _all_enemies_defeated():
	for e in enemies:
		if int(e.hp) > 0:
			return false
	return true

func _craft():
	var r = recipes[forge_i]
	if player.coins < int(r.coins):
		message = "Moedas insuficientes."
		return
	for k in r.cost.keys():
		if int(player.inventory.get(k, 0)) < int(r.cost[k]):
			message = "Falta material: " + k
			return
	player.coins -= int(r.coins)
	for k in r.cost.keys():
		player.inventory[k] = int(player.inventory.get(k, 0)) - int(r.cost[k])
	if r.kind == "weapon":
		player.weapon_levels[r.name] = max(1, int(player.weapon_levels.get(r.name, 0)) + 1)
	else:
		player.tool_levels[r.name] = max(1, int(player.tool_levels.get(r.name, 0)) + 1)
	message = "Criado/melhorado: " + r.name
	_save_game()

func _buy():
	var item = shop_items[shop_i]
	if player.coins < int(item.price):
		message = "Moedas insuficientes."
		return
	player.coins -= int(item.price)
	player.inventory[item.name] = int(player.inventory.get(item.name, 0)) + 1
	message = "Comprado: " + item.name
	_save_game()

func _upgrade_progress():
	var rows = ["Forca", "Defesa", "Agilidade", "Fe", "Honra", "Sobrevivencia", "Percepcao", "Furia Controlada", "Marca Divina"]
	var row = rows[clamp(prog_i, 0, rows.size() - 1)]
	if prog_i < 5:
		if int(player.skill_points) <= 0:
			message = "Sem pontos de habilidade."
			return
		player.skill_points -= 1
		player.skills[row] = int(player.skills.get(row, 0)) + 1
	else:
		if int(player.instinct_points) <= 0:
			message = "Sem pontos de instinto."
			return
		player.instinct_points -= 1
		player.instincts[row] = int(player.instincts.get(row, 0)) + 1
	message = "Melhoria aplicada: " + row
	_save_game()

func _toggle_setting():
	if set_i == 0:
		var idx = quality_order.find(settings.quality)
		settings.quality = quality_order[(idx + 1) % quality_order.size()]
	elif set_i == 1:
		settings.fps = 60 if int(settings.fps) == 30 else 30
	elif set_i == 2:
		settings.particles = not bool(settings.particles)
	elif set_i == 3:
		settings.contrast = not bool(settings.contrast)
	_apply_settings()
	_save_game()

func _apply_settings():
	Engine.target_fps = int(settings.fps)

func _equip_selected():
	var rows = _equipment_rows()
	if rows.empty():
		return
	var name = rows[clamp(equip_i, 0, rows.size() - 1)]
	if player.weapon_levels.has(name):
		player.equipment.weapon = name
	elif player.tool_levels.has(name):
		player.equipment.tool = name
	message = "Equipado: " + name
	_save_game()

func _equipment_rows():
	var rows = []
	for k in player.weapon_levels.keys():
		rows.append(k)
	for k in player.tool_levels.keys():
		rows.append(k)
	return rows

func _run_smoke_test():
	current_user_id = "smoke"
	account.email = "smoke@aesdivinus.local"
	account.name = "Smoke"
	register_password = "1234"
	_register()
	character_profile.name = "Aurea Teste"
	character_profile.type = "Hilda"
	character_profile["class"] = "Marcado Divino"
	character_profile.origin = "Ordem Divina"
	_new_game()
	player.coins = 500
	player.inventory["Aes Divinus"] = 6
	player.inventory["Fragmento de Ferro"] = 6
	_attack()
	_divine_mark()
	forge_i = 0
	_craft()
	shop_i = 0
	_buy()
	prog_i = 0
	_upgrade_progress()
	set_i = 0
	_toggle_setting()
	_save_game()
	get_tree().quit(0)

func _draw():
	buttons.clear()
	_draw_world()
	if state == "intro":
		_draw_intro()
	elif state == "title":
		_draw_title()
	elif state == "login":
		_draw_login()
	elif state == "register":
		_draw_register()
	elif state == "create":
		_draw_create()
	elif state == "game":
		_draw_game()
	if overlay != "":
		_draw_overlay()
	if transition > 0:
		_draw_transition()
	_draw_touch_controls()

func _draw_world():
	var bg = Color(0.025, 0.025, 0.035)
	if bool(settings.contrast):
		bg = Color(0, 0, 0)
	draw_rect(Rect2(0, 0, W, H), bg)
	var stars = 12
	if settings.quality == "Medio":
		stars = 24
	elif settings.quality == "Alto":
		stars = 36
	for i in range(stars):
		var x = float((i * 113) % W)
		var y = float(35 + ((i * 53) % 180))
		draw_circle(Vector2(x, y), 1.2 + sin(t + i) * 0.35, Color(0.85, 0.72, 0.32))
	for x in range(-120, W + 140, 96):
		var sx = x - int(camera_x * 0.12) % 96
		draw_polygon([Vector2(sx, FLOOR_Y), Vector2(sx + 48, 250), Vector2(sx + 96, FLOOR_Y)], [Color(0.04, 0.15, 0.12)])
	draw_rect(Rect2(0, FLOOR_Y, W, H - FLOOR_Y), Color(0.08, 0.12, 0.08))
	draw_rect(Rect2(0, FLOOR_Y - 8, W, 8), Color(0.24, 0.39, 0.23))

func _draw_intro():
	_draw_center("AESDIVINUS", 300, Color(1.0, 0.82, 0.25), 2)
	_draw_center("A coroa, a floresta e a marca", 350, Color(0.65, 0.95, 0.85), 1)

func _draw_title():
	_draw_logo(300, 160)
	_draw_center("A Marca Divina contra a Homis Corruption", 262, Color(0.8, 0.9, 0.82), 1)
	_button("Entrar", Rect2(362, 335, 300, 62), "play")
	_button("Convidado", Rect2(362, 414, 300, 62), "guest")
	_button("Carregar", Rect2(362, 493, 300, 62), "load")
	_draw_center(message, 595, Color(0.95, 0.9, 0.68), 1)

func _draw_login():
	_draw_panel(Rect2(210, 150, 604, 430), "Login")
	_text(Vector2(260, 245), "Email: " + account.email, _field_color("email"))
	_text(Vector2(260, 300), "Senha: " + _stars(login_password), _field_color("password"))
	_button("Campo", Rect2(260, 360, 130, 54), "field")
	_button("Entrar", Rect2(410, 360, 150, 54), "login")
	_button("Cadastro", Rect2(580, 360, 170, 54), "register")
	_button("Convidado", Rect2(410, 440, 200, 54), "guest")
	_text(Vector2(260, 525), message, Color(0.94, 0.87, 0.62))

func _draw_register():
	_draw_panel(Rect2(188, 120, 648, 510), "Cadastro local")
	_text(Vector2(238, 215), "Email: " + account.email, _field_color("email"))
	_text(Vector2(238, 270), "Nome: " + account.name, _field_color("name"))
	_text(Vector2(238, 325), "Senha: " + _stars(register_password), _field_color("password"))
	_button("Campo", Rect2(238, 386, 130, 54), "field")
	_button("Criar", Rect2(388, 386, 150, 54), "register")
	_button("Login", Rect2(558, 386, 150, 54), "login")
	_text(Vector2(238, 510), message, Color(0.94, 0.87, 0.62))

func _draw_create():
	_draw_panel(Rect2(154, 98, 716, 590), "Criacao de personagem")
	_text(Vector2(215, 190), "Nome: " + character_profile.name, _field_color("name"))
	_button("Editar nome", Rect2(650, 160, 150, 48), "field")
	_button("Tipo: " + character_profile.type, Rect2(215, 240, 585, 54), "type")
	_button("Origem: " + character_profile.origin, Rect2(215, 310, 585, 54), "origin")
	_button("Classe: " + character_profile["class"], Rect2(215, 380, 585, 54), "class")
	_draw_character(Vector2(330, 565), character_profile.type, 1.18)
	_text(Vector2(430, 535), _origin_blurb(character_profile.origin), Color(0.78, 0.91, 0.84))
	_button("Entrar na Floresta Wood", Rect2(430, 600, 320, 58), "start")

func _draw_game():
	_text(Vector2(24, 36), character_profile.name + " - " + character_profile["class"] + " de " + character_profile.origin, Color(0.96, 0.93, 0.78))
	_bar(Vector2(24, 52), 220, player.hp, player.max_hp, Color(0.82, 0.12, 0.12))
	_bar(Vector2(24, 72), 220, player.stamina, 100, Color(0.12, 0.58, 0.28))
	_text(Vector2(24, 106), "Moedas " + str(player.coins) + "  XP " + str(player.xp) + "  Nivel " + str(player.level), Color(0.9, 0.76, 0.36))
	_text(Vector2(24, 132), maps[map_index].title + " - " + maps[map_index].goal, Color(0.72, 0.9, 0.84))
	_draw_entities()
	_text(Vector2(24, 164), message, Color(0.92, 0.9, 0.72))
	_button("Sistemas", Rect2(830, 28, 168, 54), "pause")

func _draw_entities():
	for it in items:
		if not bool(it.taken):
			var x = float(it.x) - camera_x
			if x > -40 and x < W + 40:
				draw_circle(Vector2(x, FLOOR_Y - 20), 9, Color(0.28, 0.95, 0.72))
				_text(Vector2(x - 42, FLOOR_Y - 36), it.name, Color(0.82, 0.95, 0.82))
	for n in npcs:
		var nx = float(n.x) - camera_x
		if nx > -40 and nx < W + 40:
			_draw_character(Vector2(nx, FLOOR_Y), n.name, 0.78)
			_text(Vector2(nx - 28, FLOOR_Y - 88), n.name, Color(0.86, 0.88, 0.62))
	for e in enemies:
		var ex = float(e.x) - camera_x
		if ex > -80 and ex < W + 80 and int(e.hp) > 0:
			_draw_enemy(Vector2(ex, FLOOR_Y), e)
	_draw_character(Vector2(player.x - camera_x, FLOOR_Y), character_profile.type, 1.0)
	if player.attack > 0:
		draw_arc(Vector2(player.x - camera_x + 44 * player.facing, FLOOR_Y - 38), 48, -1.0, 1.0, 20, Color(0.95, 0.8, 0.26), 5)

func _draw_overlay():
	_draw_panel(Rect2(122, 92, 780, 540), _overlay_title())
	_button("<", Rect2(150, 652, 70, 58), "prev")
	_button("OK", Rect2(238, 652, 90, 58), "ok")
	_button(">", Rect2(346, 652, 70, 58), "next")
	_button("Salvar", Rect2(612, 652, 120, 58), "save")
	_button("Voltar", Rect2(750, 652, 120, 58), "back")
	_draw_overlay_tabs()
	if overlay == "inventory":
		_draw_inventory()
	elif overlay == "equipment":
		_draw_equipment()
	elif overlay == "forge":
		_draw_forge()
	elif overlay == "shop":
		_draw_shop()
	elif overlay == "progress":
		_draw_progress()
	elif overlay == "settings":
		_draw_settings()
	elif overlay == "codex":
		_draw_codex()
	elif overlay == "map":
		_draw_map()

func _draw_overlay_tabs():
	var labels = [["Inv","inventory"], ["Eq","equipment"], ["Forja","forge"], ["Loja","shop"], ["Prog","progress"], ["Cfg","settings"], ["Codex","codex"], ["Mapa","map"]]
	for i in range(labels.size()):
		_button(labels[i][0], Rect2(152 + i * 88, 112, 76, 40), labels[i][1])

func _draw_inventory():
	var y = 188
	var idx = 0
	for k in player.inventory.keys():
		_text(Vector2(190, y), _sel(idx, inv_i) + k + ": " + str(player.inventory[k]), Color(0.9, 0.9, 0.78))
		y += 34
		idx += 1
	_text(Vector2(530, 190), "Itens sao salvos no banco local do usuario.", Color(0.72, 0.88, 0.82))

func _draw_equipment():
	var rows = _equipment_rows()
	for i in range(rows.size()):
		var lvl = int(player.weapon_levels.get(rows[i], player.tool_levels.get(rows[i], 1)))
		_text(Vector2(190, 190 + i * 34), _sel(i, equip_i) + rows[i] + " Nv." + str(lvl), Color(0.9, 0.9, 0.78))
	_text(Vector2(550, 190), "Arma: " + str(player.equipment.weapon), Color(0.84, 0.96, 0.82))
	_text(Vector2(550, 224), "Ferramenta: " + str(player.equipment.tool), Color(0.84, 0.96, 0.82))

func _draw_forge():
	for i in range(recipes.size()):
		var r = recipes[i]
		_text(Vector2(170, 185 + i * 34), _sel(i, forge_i) + r.name + " - " + str(r.coins) + " moedas", Color(0.92, 0.83, 0.62))
	_text(Vector2(565, 190), "Materiais: " + _cost_text(recipes[forge_i].cost), Color(0.78, 0.92, 0.84))
	_text(Vector2(565, 224), "OK cria ou melhora o item.", Color(0.78, 0.92, 0.84))

func _draw_shop():
	for i in range(shop_items.size()):
		var it = shop_items[i]
		_text(Vector2(190, 190 + i * 42), _sel(i, shop_i) + it.name + " compra " + str(it.price), Color(0.92, 0.83, 0.62))
	_text(Vector2(550, 190), "Moedas atuais: " + str(player.coins), Color(0.84, 0.96, 0.82))

func _draw_progress():
	var rows = ["Forca", "Defesa", "Agilidade", "Fe", "Honra", "Sobrevivencia", "Percepcao", "Furia Controlada", "Marca Divina"]
	for i in range(rows.size()):
		var val = int(player.skills.get(rows[i], player.instincts.get(rows[i], 0)))
		_text(Vector2(180, 180 + i * 34), _sel(i, prog_i) + rows[i] + " +" + str(val), Color(0.9, 0.9, 0.78))
	_text(Vector2(575, 190), "Habilidade: " + str(player.skill_points), Color(0.84, 0.96, 0.82))
	_text(Vector2(575, 224), "Instinto: " + str(player.instinct_points), Color(0.84, 0.96, 0.82))

func _draw_settings():
	var rows = ["Qualidade: " + str(settings.quality), "FPS alvo: " + str(settings.fps), "Particulas: " + str(settings.particles), "Alto contraste: " + str(settings.contrast)]
	for i in range(rows.size()):
		_text(Vector2(210, 210 + i * 46), _sel(i, set_i) + rows[i], Color(0.88, 0.93, 0.85))
	_text(Vector2(560, 210), "Compatibilidade e indicada para iPad Air A7.", Color(0.78, 0.92, 0.84))

func _draw_codex():
	var start = max(0, codex_i - 2)
	for i in range(start, min(codex.size(), codex_i + 5)):
		_text(Vector2(170, 190 + (i - start) * 54), _sel(i, codex_i) + codex[i], Color(0.88, 0.9, 0.78))

func _draw_map():
	for i in range(maps.size()):
		_text(Vector2(210, 210 + i * 52), _sel(i, map_index) + maps[i].title + " - " + maps[i].goal, Color(0.88, 0.93, 0.85))

func _draw_touch_controls():
	if state == "game" and overlay == "":
		_button("<", Rect2(42, 650, 82, 78), "left", true)
		_button(">", Rect2(146, 650, 82, 78), "right", true)
		_button("RUN", Rect2(90, 574, 92, 56), "run", true)
		_button("ATQ", Rect2(742, 650, 82, 78), "attack")
		_button("BLK", Rect2(842, 650, 82, 78), "block")
		_button("AES", Rect2(940, 650, 82, 78), "mark")
	elif overlay != "":
		_button("^", Rect2(34, 520, 72, 58), "up")
		_button("v", Rect2(34, 590, 72, 58), "down")

func _draw_transition():
	draw_rect(Rect2(0, 0, W, H), Color(0.03, 0.025, 0.02, transition * 0.78))
	_draw_center(transition_title, 362, Color(0.95, 0.82, 0.32, transition), 1)
	draw_arc(Vector2(W / 2, H / 2), 80 + transition * 120, 0, PI * 2, 64, Color(0.3, 0.95, 0.78, transition * 0.6), 4)

func _draw_logo(x, y):
	_draw_star(Vector2(x, y), 34)
	_text(Vector2(x + 54, y - 8), "AESDIVINUS", Color(0.98, 0.86, 0.36), 2)
	_text(Vector2(x + 58, y + 40), "A COROA, A FLORESTA E A MARCA", Color(0.58, 0.9, 0.82))

func _draw_character(pos, name, scale):
	var colors = {
		"William": Color(0.2, 0.36, 0.56),
		"Ethan": Color(0.22, 0.48, 0.72),
		"Donovan": Color(0.38, 0.38, 0.39),
		"Albert": Color(0.45, 0.32, 0.58),
		"Hilda": Color(0.58, 0.22, 0.42),
		"Elric": Color(0.20, 0.43, 0.39)
	}
	var c = colors.get(name, Color(0.28, 0.42, 0.56))
	var s = scale
	draw_rect(Rect2(pos.x - 18 * s, pos.y - 56 * s, 36 * s, 56 * s), c)
	draw_rect(Rect2(pos.x - 12 * s, pos.y - 76 * s, 24 * s, 22 * s), Color(0.78, 0.63, 0.46))
	draw_rect(Rect2(pos.x - 16 * s, pos.y - 82 * s, 32 * s, 8 * s), c.darkened(0.45))
	draw_line(Vector2(pos.x + 18 * s * player.facing, pos.y - 36 * s), Vector2(pos.x + 60 * s * player.facing, pos.y - 62 * s), Color(0.83, 0.84, 0.76), 4 * s)
	draw_circle(Vector2(pos.x, pos.y - 48 * s), 4 * s, Color(0.36, 0.95, 0.78, 0.65))

func _draw_enemy(pos, e):
	var c = Color(0.25, 0.07, 0.06)
	if e.type == "canis":
		c = Color(0.18, 0.16, 0.12)
	elif e.type == "ignis":
		c = Color(0.45, 0.13, 0.05)
	elif e.type == "boss":
		c = Color(0.19, 0.06, 0.10)
	draw_rect(Rect2(pos.x - 24, pos.y - 64, 48, 64), c)
	draw_circle(Vector2(pos.x - 8, pos.y - 47), 4, Color(0.95, 0.12, 0.05))
	draw_circle(Vector2(pos.x + 8, pos.y - 47), 4, Color(0.95, 0.12, 0.05))
	_bar(Vector2(pos.x - 58, pos.y - 96), 116, e.hp, e.max_hp, Color(0.65, 0.08, 0.08))
	_text(Vector2(pos.x - 70, pos.y - 112), e.name, Color(0.95, 0.66, 0.56))

func _button(label, rect, action, hold=false):
	buttons.append({"label": label, "rect": rect, "action": action, "hold": hold})
	draw_rect(rect, Color(0.08, 0.10, 0.11, 0.88))
	draw_rect(rect, Color(0.72, 0.58, 0.24), false, 2)
	_text(rect.position + Vector2(12, rect.size.y * 0.60), label, Color(0.96, 0.9, 0.68))

func _draw_panel(rect, title):
	draw_rect(rect, Color(0.05, 0.075, 0.07, 0.92))
	draw_rect(rect, Color(0.78, 0.62, 0.26), false, 3)
	draw_rect(Rect2(rect.position + Vector2(10, 10), rect.size - Vector2(20, 20)), Color(0.18, 0.52, 0.42, 0.45), false, 1)
	_text(rect.position + Vector2(36, 52), title, Color(0.98, 0.86, 0.36), 2)

func _text(pos, value, color, scale=1):
	if ui_font == null:
		return
	draw_string(ui_font, pos, str(value), color)
	if scale > 1:
		draw_string(ui_font, pos + Vector2(1, 0), str(value), color)

func _draw_center(value, y, color, scale):
	var x = W / 2 - str(value).length() * 4 * scale
	_text(Vector2(x, y), value, color, scale)

func _bar(pos, width, value, max_value, color):
	draw_rect(Rect2(pos.x, pos.y, width, 14), Color(0.02, 0.02, 0.025))
	var ratio = 0.0
	if float(max_value) > 0:
		ratio = clamp(float(value) / float(max_value), 0, 1)
	draw_rect(Rect2(pos.x + 2, pos.y + 2, (width - 4) * ratio, 10), color)

func _draw_star(center, radius):
	var pts = PoolVector2Array()
	for i in range(10):
		var r = radius if i % 2 == 0 else radius * 0.42
		var a = -PI / 2 + i * PI / 5
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	draw_polygon(pts, [Color(0.86, 0.72, 0.28)])
	draw_circle(center, radius * 0.25, Color(0.05, 0.07, 0.06))

func _field_color(field):
	return Color(0.52, 0.96, 0.84) if active_field == field else Color(0.92, 0.9, 0.78)

func _stars(value):
	var out = ""
	for _i in range(str(value).length()):
		out += "*"
	return out

func _origin_blurb(origin):
	if origin == "Forja de Robert Smith":
		return "Comeca com ferro extra e talento de forja."
	if origin == "Ordem Divina":
		return "Marca Divina responde mais cedo."
	if origin == "Fronteira Wood":
		return "Conhece trilhas e emboscadas."
	return "Origem salva no personagem e no banco."

func _cost_text(cost):
	var parts = []
	for k in cost.keys():
		parts.append(k + " x" + str(cost[k]))
	return ", ".join(parts)

func _sel(i, selected):
	return "> " if i == selected else "  "

func _overlay_title():
	var names = {
		"inventory": "Inventario",
		"equipment": "Equipamentos",
		"forge": "Forja e criacao",
		"shop": "Loja com moeda do jogo",
		"progress": "Habilidades e instinto",
		"settings": "Configuracoes",
		"codex": "Codex e historia",
		"map": "Mapa"
	}
	return names.get(overlay, "Sistemas")
