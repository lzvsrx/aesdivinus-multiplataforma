extends Node2D

const GRAVITY := 1800.0
const FLOOR_Y := 560.0
const PLAYER_SIZE := Vector2(34, 56)
const WORLD_W := 3600.0
const LEGACY_SAVE_PATH := "user://aesdivinus_save.json"
const DB_PATH := "user://aesdivinus_db.json"
const BUILD_VERSION := "1.4.0"
const DEVELOPER_NAME := "Espíritos dos jogos"
const DEVELOPER_MOTTO := "Uma empresa pode ter dinheiro e prédios, mas nós temos o espírito."

var maps := [
	{
		"id": "wood_forest_01",
		"title": "Floresta Wood 1.1",
		"goal": "Aprenda exploração, salto e interação.",
		"spawn": Vector2(120, FLOOR_Y),
		"enemies": [
			{"name": "Homem Corrupto", "type": "barbarian", "pos": Vector2(880, FLOOR_Y), "hp": 45},
			{"name": "Batedor", "type": "barbarian", "pos": Vector2(1480, FLOOR_Y), "hp": 40},
			{"name": "Servus Belli Larva", "type": "servi", "pos": Vector2(2140, FLOOR_Y), "hp": 58}
		],
		"items": [
			{"name": "Aes Divinus", "pos": Vector2(560, FLOOR_Y - 20), "amount": 2, "taken": false}
		],
		"npcs": [
			{"name": "Ethan", "pos": Vector2(310, FLOOR_Y), "lines": ["William, a trilha escureceu cedo demais.", "Mantenha a espada pronta. A floresta nos observa."]}
		],
		"message": "William entra na floresta com seus companheiros."
	},
	{
		"id": "wood_forest_02",
		"title": "Floresta Wood 1.2",
		"goal": "Sobreviva a emboscada e derrote o Canis Ferox.",
		"spawn": Vector2(120, FLOOR_Y),
		"enemies": [
			{"name": "Bárbaro", "type": "barbarian", "pos": Vector2(760, FLOOR_Y), "hp": 55},
			{"name": "Canis Ferox", "type": "canis", "pos": Vector2(1220, FLOOR_Y), "hp": 80},
			{"name": "Lanceiro", "type": "barbarian", "pos": Vector2(1720, FLOOR_Y), "hp": 60},
			{"name": "Bestia Ignis", "type": "ignis", "pos": Vector2(2300, FLOOR_Y), "hp": 110}
		],
		"items": [
			{"name": "Fragmento de Ferro", "pos": Vector2(980, FLOOR_Y - 20), "amount": 1, "taken": false}
		],
		"npcs": [],
		"message": "O cavalo de William cai. O combate começa."
	},
	{
		"id": "wood_forest_03",
		"title": "Floresta Wood 1.3",
		"goal": "Enfrente o chefe e alcance Gradon.",
		"spawn": Vector2(120, FLOOR_Y),
		"enemies": [
			{"name": "Ogre Larva Belli", "type": "boss", "pos": Vector2(1900, FLOOR_Y), "hp": 260}
		],
		"items": [
			{"name": "Relato Manchado", "pos": Vector2(620, FLOOR_Y - 20), "amount": 1, "taken": false}
		],
		"npcs": [
			{"name": "Donovan", "pos": Vector2(410, FLOOR_Y), "lines": ["A linha caiu. Não tente salvar todos sozinho.", "A coragem também é uma lâmina, príncipe. Use-a."]},
			{"name": "Albert", "pos": Vector2(520, FLOOR_Y), "lines": ["As rotas para Gradon ainda existem.", "Se sobrevivermos, o conselho precisara ouvir isto."]},
			{"name": "Hilda", "pos": Vector2(630, FLOOR_Y), "lines": ["Fique leve nos pes, William.", "A floresta pune quem hesita."]},
			{"name": "Elric", "pos": Vector2(740, FLOOR_Y), "lines": ["A marca reage ao sangue derramado.", "Nao confunda milagre com controle."]}
		],
		"message": "Ao fundo, o exército é engolido pelo caos."
	}
]

var map_index := 0
var enemies: Array = []
var items: Array = []
var npcs: Array = []
var particles: Array = []
var floating_text: Array = []

var player := {
	"pos": Vector2.ZERO,
	"vel": Vector2.ZERO,
	"facing": 1,
	"state": "IDLE",
	"hp": 120,
	"max_hp": 120,
	"base_max_hp": 120,
	"stamina": 100.0,
	"courage": 100.0,
	"loyalty": 50,
	"on_floor": true,
	"invuln": 0.0,
	"lock": 0.0,
	"attack_timer": 0.0,
	"combo": 0,
	"charge": 0.0,
	"special_cd": 0.0,
	"coins": 35,
	"skill_points": 1,
	"instinct_points": 1,
	"equipment": {"weapon": "Espada de Gradon", "tool": "Kit de Campanha", "armor": "Couro militar"},
	"weapon_levels": {"Espada de Gradon": 1},
	"tool_levels": {"Kit de Campanha": 1},
	"skills": {"Forca": 0, "Defesa": 0, "Agilidade": 0, "Fe": 0, "Honra": 0},
	"instincts": {"Sobrevivencia": 0, "Percepcao": 0, "Furia Controlada": 0, "Marca Divina": 0},
	"inventory": {"Aes Divinus": 0, "Fragmento de Ferro": 0, "Relato Manchado": 0, "Racao": 1}
}

var camera_x := 0.0
var screen_shake_power := 0.0
var overlay := ""
var last_overlay := ""
var paused := false
var dialogue := {"active": false, "name": "", "lines": [], "index": 0}
var banner := ""
var banner_timer := 0.0
var boss_mode := false
var game_over := false
var victory := false
var game_started := false
var checkpoint := {"map_index": 0, "pos_x": 120.0}
var auth_screen := "login"
var last_auth_screen := "login"
var transition_timer := 1.0
var transition_duration := 0.9
var transition_title := "A MARCA DESPERTA"
var transition_from := "void"
var transition_to := "login"
var frontend_time := 0.0
var intro_timer := 0.0
var intro_duration := 4.8
var touch_points := {}
var auth_index := 0
var main_menu_index := 0
var inventory_index := 0
var settings_index := 0
var equipment_index := 0
var forge_index := 0
var shop_index := 0
var progression_index := 0
var codex_index := 0
var login_password := ""
var register_password := ""
var auth_message := "Digite seus dados ou entre como convidado."
var current_user_id := ""
var db := {
	"version": BUILD_VERSION,
	"users": {},
	"events": []
}
var character_field_index := 0
var character_type_index := 0
var character_class_index := 0
var character_origin_index := 0
var account := {
	"id": "",
	"email": "convidado@aesdivinus.local",
	"name": "Convidado",
	"logged_in": false,
	"registered": false
}
var character_profile := {
	"name": "William",
	"type": "William",
	"class": "Cavaleiro",
	"origin": "Gradon",
	"created": false
}
var character_type_options := ["William", "Ethan", "Donovan", "Albert", "Hilda", "Elric"]
var class_options := ["Cavaleiro", "Sentinela", "Mercenario", "Lanceiro", "Arqueiro", "Ferreiro", "Estrategista", "Marcado Divino"]
var origin_options := ["Gradon", "Fronteira Wood", "Castelo de Gradon", "Sala do Conselho", "Aposentos Militares", "Forja de Robert Smith", "Casa Exilada", "Ordem Divina"]
var main_menu_options := ["Novo Jogo", "Carregar", "Criar Personagem", "Sistemas", "Sair"]
var system_overlay_order := ["inventory", "equipment", "character", "quests", "map", "forge", "shop", "settings", "codex", "direction", "database"]
var weapon_catalog := {
	"Espada de Gradon": {"type": "sword", "base_damage": 4, "price": 0, "description": "equilibrada e fiel ao prologo"},
	"Lamina de Ferro": {"type": "sword", "base_damage": 8, "price": 80, "description": "boa para combo leve"},
	"Machado de Donovan": {"type": "axe", "base_damage": 13, "price": 130, "description": "lento, pesado e forte"},
	"Lanca de Hilda": {"type": "spear", "base_damage": 10, "price": 110, "description": "alcance longo para controle"},
	"Cajado de Elric": {"type": "staff", "base_damage": 7, "price": 95, "description": "melhora a Marca Divina"},
	"Espada Aes": {"type": "sword", "base_damage": 15, "price": 180, "description": "lamina verde-dourada contra corrompidos"},
	"Lanca Aes": {"type": "spear", "base_damage": 13, "price": 170, "description": "alcance imperial contra monstros"},
	"Alabarda Aes": {"type": "axe", "base_damage": 18, "price": 220, "description": "arma pesada de caca aos abencoados corrompidos"}
}
var tool_catalog := {
	"Kit de Campanha": {"price": 0, "description": "coleta basica e reparos simples"},
	"Picareta de Robert": {"price": 70, "description": "aumenta ganhos de Fragmento de Ferro"},
	"Bolsa de Mercador": {"price": 90, "description": "melhora venda de itens"},
	"Cinzel Divino": {"price": 120, "description": "reduz custo de melhoria rara"}
}
var forge_recipes := [
	{"name": "Lamina de Ferro", "kind": "weapon", "cost": {"Fragmento de Ferro": 2}, "coins": 20},
	{"name": "Machado de Donovan", "kind": "weapon", "cost": {"Fragmento de Ferro": 3, "Aes Divinus": 1}, "coins": 35},
	{"name": "Lanca de Hilda", "kind": "weapon", "cost": {"Fragmento de Ferro": 2, "Aes Divinus": 1}, "coins": 30},
	{"name": "Cajado de Elric", "kind": "weapon", "cost": {"Aes Divinus": 2}, "coins": 45},
	{"name": "Espada Aes", "kind": "weapon", "cost": {"Aes Divinus": 3, "Fragmento de Ferro": 2}, "coins": 80},
	{"name": "Lanca Aes", "kind": "weapon", "cost": {"Aes Divinus": 3, "Fragmento de Ferro": 2}, "coins": 75},
	{"name": "Alabarda Aes", "kind": "weapon", "cost": {"Aes Divinus": 4, "Fragmento de Ferro": 3}, "coins": 110},
	{"name": "Picareta de Robert", "kind": "tool", "cost": {"Fragmento de Ferro": 2}, "coins": 25},
	{"name": "Bolsa de Mercador", "kind": "tool", "cost": {"Relato Manchado": 1, "Fragmento de Ferro": 1}, "coins": 30},
	{"name": "Cinzel Divino", "kind": "tool", "cost": {"Aes Divinus": 2, "Fragmento de Ferro": 1}, "coins": 50}
]
var shop_items := [
	{"name": "Racao", "price": 18, "sell": 7, "description": "consumivel de viagem"},
	{"name": "Aes Divinus", "price": 65, "sell": 26, "description": "material raro para forja"},
	{"name": "Fragmento de Ferro", "price": 32, "sell": 12, "description": "metal para armas e ferramentas"},
	{"name": "Relato Manchado", "price": 45, "sell": 18, "description": "item de lore e troca"}
]
var story_improvements := [
	"Prologo com 3 escolhas claras: salvar companheiro, perseguir inimigo ou proteger civis.",
	"Lealdade e coragem devem alterar dialogos de Ethan, Donovan, Albert, Hilda e Elric.",
	"Gradon deve virar hub com Conselho, Forja, Aposentos Militares e missao principal.",
	"Marcas Divinas precisam ter custo narrativo, nao apenas cooldown de combate.",
	"Cada personagem base deve desbloquear uma perspectiva extra em dialogos e Codex."
]
var gameplay_improvements := [
	"Telegraph visual antes de cada ataque inimigo para o jogador reagir.",
	"Cada acao precisa ter funcao unica: leve para combo, pesado para quebrar defesa, bloqueio para reduzir dano, esquiva para reposicionar.",
	"Tutorial contextual dentro da Floresta Wood, sem depender do README.",
	"Inimigos por arquetipo: patrulheiro, rapido, pesado, distancia e chefe.",
	"Opcoes de acessibilidade: texto maior, alto contraste, remapeamento, indicador visual para sons importantes."
]
var world_lore := {
	"Homis Corruption": "Humanos unidos aos deuses corrompidos ou usados em rituais. Atacam viajantes, soldados isolados e esquadroes nas florestas.",
	"Homis Corruption Barbaros": "Barbaros corrompidos e abencoados por anjos traidores. Usam armaduras simples e avancam nas invasoes para abrir caminho pelo caos.",
	"Aes Divinus": "Minerio divino trazido no fim da era romano-bizantina. E pesado, raro, valioso e usado em joias, cruzes, flechas e armas do imperio grao franco saxao.",
	"Armas Aes": "Espadas, lancas e alabardas de metal esverdeado com dourado. No jogo, Espada Aes, Lanca Aes e Alabarda Aes causam dano extra em corrompidos.",
	"Servi Belli Larvae": "Cadaveres usados pelos barbaros como tropa de choque. Caminham com restos de roupas e atacam para distrair exercitos.",
	"Ogre Larva Belli": "Evolucao dos Servi apos mortes ou alteracoes barbaras. Sao maiores, mutilados, com armas misturadas a carne e devastadores em batalha.",
	"Praecones Caesarum": "Arautos dos anjos traidores. Podem ser capitaes barbaros ou lordes que abandonaram a humanidade para virar vozes profanas.",
	"Marca de Bellinis": "Marca de carne queimada, musculos expostos e violencia gigante. Seus arautos usam fogo, aco e machados vivos.",
	"Marca de Stipulation": "Marca quase invisivel ligada a sombras, segredos e disfarces. Seus arautos nao possuem sombra e revelam olhos escuros e asas de corvo.",
	"Ab Angelis Signatus": "Marcas dos anjos puros que surgem em crises. Alteram corpo, olhos e destino dos escolhidos com menos tormento que as marcas corruptas.",
	"Marca de Iusdicta": "Marca de justica nas costas, formando asas. O escolhido perde a visao comum e passa a enxergar pecados e corrupcao.",
	"Marca de Thofestoe": "Marca de criacao e forja no antebraco e torso. Ensina uso de materiais, ferramentas, armas e construcoes.",
	"Marca de Gloregni": "Marca de monarcas, reis e principes. Amplifica outras marcas e fortalece lideranca, forca e destino politico.",
	"Marca de Satiae": "Marca de conhecimento nos olhos. Aumenta aprendizado e leitura das pessoas, mas pode gerar arrogancia.",
	"Marca Miseritae": "Marca de vida no torso e antebracos. Cura feridas e protege a vida, mas pode tornar o escolhido fanaticamente pacifista.",
	"A Sanctis Signatus": "Marca historica rarissima que pode receber as cinco bencaos: Iusdicta, Thofestoe, Gloregni, Satiae e Miseritae.",
	"Canis Ferox": "Caes corrompidos usados para caca, rastreio e ataques em bando. No jogo ensinam esquiva e controle de distancia.",
	"Bestia Ignis": "Abominacao ritual com partes de lobo, cao, cabra e serpente. Pode atacar com dentes, chifres, veneno e fogo.",
	"Duques de Gradron": "O principado e dividido entre quatro ducados: Legrand, Michael, Armand e Roberts, cada um com terras, emblemas e ambicoes.",
	"Dinastia Legrand": "Ducado menor de um heroi diplomata. Emblema: ave carregando espada. Fica a direita de Gradron, abaixo de Michael.",
	"Dinastia Michael": "Ducado de sombras, segredos e neutralidade suspeita. Emblema: corvo em floresta escura.",
	"Dinastia Armand": "Principal forca militar do principado. Emblema: cavaleiro erguendo espada contra leao.",
	"Dinastia Roberts": "Fonte de recursos e alimento, marcada por fe conservadora. Emblema: cruz laranja com circulo.",
	"Mercenarios da Floresta sem Luz": "Forca do ducado Michael no Ato 2. Usam mantos, capuzes e ocultacao em sombras.",
	"Salteadores da Floresta Wood": "Ladroes de rotas comerciais que fugiram para Michael e viraram mercenarios protegidos.",
	"Corvus Stipulation": "Corvo gigante de tres olhos criado por ritual de Stipulation. Guardiao aterrorizante do ducado Michael.",
	"Umbrae Maleficae": "Senhoras das sombras e rituais do Ato 3. Manipulam aldeias, medo e sacrificios para Stipulation.",
	"Superiores Umbrae Maleficae": "Lider das Umbrae e porta-voz de Stipulation no ducado Michael.",
	"Mulier Umbris Consumptae": "Mulheres sacrificadas por bencaos sombrias, condenadas a vagar gritando maldicoes.",
	"Qui Decepti Sunt": "Homens enganados por promessas de poder. Tornam-se servos palidos, de olhos escuros, presos a obediencia."
}
var quality_profile_order := ["Compatibilidade", "Baixo", "Medio", "Alto", "Ultra"]
var quality_profiles := {
	"Compatibilidade": {"stars": 6, "hills": 2, "ruins": 1, "trees": 4, "fires": 1, "debris": 1, "particles": 0.25, "transition_fx": false, "description": "CPU/GPU antiga, pouca RAM, notebooks basicos."},
	"Baixo": {"stars": 12, "hills": 3, "ruins": 2, "trees": 6, "fires": 2, "debris": 2, "particles": 0.45, "transition_fx": true, "description": "2 GB RAM, video integrado fraco, processador dual-core."},
	"Medio": {"stars": 20, "hills": 4, "ruins": 3, "trees": 8, "fires": 4, "debris": 4, "particles": 0.70, "transition_fx": true, "description": "4 GB RAM, video integrado moderno ou GPU simples."},
	"Alto": {"stars": 32, "hills": 6, "ruins": 5, "trees": 11, "fires": 7, "debris": 8, "particles": 1.00, "transition_fx": true, "description": "8 GB RAM, GPU dedicada basica/intermediaria."},
	"Ultra": {"stars": 48, "hills": 8, "ruins": 6, "trees": 14, "fires": 10, "debris": 12, "particles": 1.35, "transition_fx": true, "description": "16 GB RAM ou mais, GPU dedicada, CPU moderna."}
}
var game_settings := {
	"quality_profile": "Alto",
	"resolution_scale": 100,
	"target_fps": 60,
	"high_contrast": false,
	"screen_shake": true,
	"particles_enabled": true,
	"animated_background": true,
	"ui_text_size": 17
}
var character_models := {
	"William": {
		"role": "protagonista / cavaleiro",
		"status": "base procedural revisada para Aseprite",
		"body": "#395b7c",
		"secondary": "#233b54",
		"skin": "#d2b48c",
		"hair": "#2b2119",
		"detail": "#d8b45a",
		"weapon": "sword",
		"silhouette": "knight",
		"improve": "produzir william.aseprite com armadura em camadas, espada separada e animacoes completas."
	},
	"Ethan": {
		"role": "companheiro agil / batedor",
		"status": "base procedural revisada para Aseprite",
		"body": "#4f73a6",
		"secondary": "#2d4c73",
		"skin": "#c7b18a",
		"hair": "#6a4a2f",
		"detail": "#7bd0c2",
		"weapon": "short_sword",
		"silhouette": "scout",
		"improve": "produzir ethan.aseprite com capa curta, silhueta de batedor e corrida mais elastica."
	},
	"Donovan": {
		"role": "veterano / defensor pesado",
		"status": "base procedural revisada para Aseprite",
		"body": "#5d5d64",
		"secondary": "#37373d",
		"skin": "#bca17e",
		"hair": "#2a2928",
		"detail": "#9b7c43",
		"weapon": "axe",
		"silhouette": "heavy",
		"improve": "produzir donovan.aseprite com corpo largo, ombreiras e machado em camada separada."
	},
	"Albert": {
		"role": "nobre / estrategista",
		"status": "base procedural revisada para Aseprite",
		"body": "#6d4f8c",
		"secondary": "#3f2c58",
		"skin": "#d0b091",
		"hair": "#d8c17a",
		"detail": "#e8d98b",
		"weapon": "rapier",
		"silhouette": "noble",
		"improve": "produzir albert.aseprite com florete, capa nobre, livro/mapa e pose de comando."
	},
	"Hilda": {
		"role": "guerreira agil / suporte",
		"status": "base procedural revisada para Aseprite",
		"body": "#7b3f61",
		"secondary": "#3f263a",
		"skin": "#c99676",
		"hair": "#1d1b1f",
		"detail": "#d96d8b",
		"weapon": "spear",
		"silhouette": "agile",
		"improve": "produzir hilda.aseprite com tranca, lanca longa e esquiva exclusiva."
	},
	"Elric": {
		"role": "marcado divino / mistico",
		"status": "base procedural revisada para Aseprite",
		"body": "#355f5a",
		"secondary": "#1f3938",
		"skin": "#cab79d",
		"hair": "#e6e6d7",
		"detail": "#6ee7cf",
		"weapon": "staff",
		"silhouette": "mystic",
		"improve": "produzir elric.aseprite com cajado, Marca Divina, glow e conjuracao."
	}
}

var hud: CanvasLayer
var hp_bar: ColorRect
var stamina_bar: ColorRect
var courage_bar: ColorRect
var title_label: Label
var hint_label: Label
var panel_label: Label


func _ready() -> void:
	randomize()
	_ensure_runtime_input_actions()
	_db_load()
	_normalize_player_runtime_data()
	_build_ui()
	_apply_runtime_settings()
	_load_map(0)
	if _has_cmd_arg("--smoke-test"):
		_run_smoke_test()
		return
	set_process(true)
	set_physics_process(true)


func _has_cmd_arg(arg: String) -> bool:
	return arg in OS.get_cmdline_user_args() or arg in OS.get_cmdline_args() or OS.get_environment("AESDIVINUS_SMOKE_TEST") == "1"


func _is_touch_build() -> bool:
	return OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("web")


func _touch_buttons() -> Array[Dictionary]:
	if not game_started or paused or overlay != "" or game_over or victory:
		return [
			{"id": "up", "label": "W", "action": "menu_up", "rect": Rect2(78, 442, 70, 58)},
			{"id": "down", "label": "S", "action": "menu_down", "rect": Rect2(78, 570, 70, 58)},
			{"id": "left", "label": "A", "action": "menu_left", "rect": Rect2(8, 506, 70, 58)},
			{"id": "right", "label": "D", "action": "menu_right", "rect": Rect2(148, 506, 70, 58)},
			{"id": "back", "label": "Q", "action": "divine_mark", "rect": Rect2(1000, 596, 86, 62)},
			{"id": "ok", "label": "E", "action": "interact", "rect": Rect2(1110, 586, 104, 72)}
		]
	return [
		{"id": "left", "label": "<", "action": "move_left", "rect": Rect2(34, 578, 86, 72)},
		{"id": "right", "label": ">", "action": "move_right", "rect": Rect2(140, 578, 86, 72)},
		{"id": "run", "label": "RUN", "action": "run", "rect": Rect2(86, 492, 92, 58)},
		{"id": "jump", "label": "JMP", "action": "jump", "rect": Rect2(1050, 486, 86, 62)},
		{"id": "attack", "label": "ATK", "action": "attack", "rect": Rect2(1146, 568, 92, 72)},
		{"id": "dodge", "label": "DOD", "action": "dodge", "rect": Rect2(944, 568, 92, 72)},
		{"id": "block", "label": "BLK", "action": "block", "rect": Rect2(1044, 568, 92, 72)},
		{"id": "interact", "label": "E", "action": "interact", "rect": Rect2(1148, 474, 72, 62)},
		{"id": "mark", "label": "AES", "action": "divine_mark", "rect": Rect2(942, 474, 86, 62)}
	]


func _handle_touch_input(event: InputEvent) -> void:
	if not _is_touch_build():
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			for button in _touch_buttons():
				var rect: Rect2 = button.rect
				if rect.has_point(touch.position):
					var action := String(button.action)
					touch_points[touch.index] = action
					Input.action_press(action)
					get_viewport().set_input_as_handled()
					return
		else:
			if touch_points.has(touch.index):
				Input.action_release(String(touch_points[touch.index]))
				touch_points.erase(touch.index)
				get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if game_started:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if auth_screen == "character_create":
			_handle_character_name_key(event)
		elif auth_screen in ["login", "register"]:
			_handle_auth_text_key(event)


func _input(event: InputEvent) -> void:
	_handle_touch_input(event)


func _handle_auth_text_key(event: InputEventKey) -> void:
	var editable := _auth_editable_field()
	if editable == "":
		return
	if event.keycode == KEY_BACKSPACE:
		_set_auth_editable_value(editable, _get_auth_editable_value(editable).substr(0, max(0, _get_auth_editable_value(editable).length() - 1)))
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_SPACE:
		if editable == "name":
			_set_auth_editable_value(editable, _get_auth_editable_value(editable) + " ")
		get_viewport().set_input_as_handled()
		return
	var typed := String.chr(event.unicode)
	var allowed := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@._-"
	if editable == "name":
		allowed += "'"
	if typed.length() == 1 and allowed.contains(typed):
		var current := _get_auth_editable_value(editable)
		if current.length() < 36:
			_set_auth_editable_value(editable, current + typed)
		get_viewport().set_input_as_handled()


func _auth_editable_field() -> String:
	if auth_screen == "login":
		if auth_index == 0:
			return "email"
		if auth_index == 1:
			return "login_password"
	elif auth_screen == "register":
		if auth_index == 0:
			return "name"
		if auth_index == 1:
			return "email"
		if auth_index == 2:
			return "register_password"
	return ""


func _get_auth_editable_value(field: String) -> String:
	match field:
		"name":
			return account.name
		"email":
			return account.email
		"login_password":
			return login_password
		"register_password":
			return register_password
	return ""


func _set_auth_editable_value(field: String, value: String) -> void:
	match field:
		"name":
			account.name = value
		"email":
			account.email = value.to_lower()
		"login_password":
			login_password = value
		"register_password":
			register_password = value


func _handle_character_name_key(event: InputEventKey) -> void:
	if character_field_index != 0:
		return
	if event.keycode == KEY_BACKSPACE:
		if character_profile.name.length() > 0:
			character_profile.name = character_profile.name.substr(0, character_profile.name.length() - 1)
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_SPACE:
		_append_character_name(" ")
		get_viewport().set_input_as_handled()
		return
	var typed := String.chr(event.unicode)
	var allowed := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	if typed.length() == 1 and (allowed.contains(typed) or typed in ["-", "'"]):
		_append_character_name(typed)
		get_viewport().set_input_as_handled()


func _append_character_name(value: String) -> void:
	if character_profile.name.length() >= 18:
		return
	character_profile.name += value


func _ensure_runtime_input_actions() -> void:
	var actions := {
		"menu_up": [KEY_W, KEY_UP],
		"menu_down": [KEY_S, KEY_DOWN],
		"menu_left": [KEY_A, KEY_LEFT],
		"menu_right": [KEY_D, KEY_RIGHT],
		"equipment": [KEY_O],
		"character": [KEY_C],
		"quests": [KEY_U],
		"forge": [KEY_F],
		"shop": [KEY_V],
		"settings": [KEY_P],
		"codex": [KEY_R],
		"direction": [KEY_T],
		"database": [KEY_B],
		"quick_save": [KEY_F5]
	}
	for action_name in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for keycode in actions[action_name]:
			var exists := false
			for event in InputMap.action_get_events(action_name):
				if event is InputEventKey and event.keycode == keycode:
					exists = true
					break
			if not exists:
				var event := InputEventKey.new()
				event.keycode = keycode
				InputMap.action_add_event(action_name, event)


func _build_ui() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var hp_bg := _bar_bg(Vector2(22, 22), Vector2(250, 16))
	var st_bg := _bar_bg(Vector2(22, 46), Vector2(210, 12))
	var co_bg := _bar_bg(Vector2(22, 66), Vector2(190, 10))
	hud.add_child(hp_bg)
	hud.add_child(st_bg)
	hud.add_child(co_bg)
	hp_bar = _bar(Vector2(22, 22), Vector2(250, 16), Color("#b53c3c"))
	stamina_bar = _bar(Vector2(22, 46), Vector2(210, 12), Color("#d6b452"))
	courage_bar = _bar(Vector2(22, 66), Vector2(190, 10), Color("#5ca8d8"))
	hud.add_child(hp_bar)
	hud.add_child(stamina_bar)
	hud.add_child(courage_bar)
	title_label = Label.new()
	hint_label = Label.new()
	panel_label = Label.new()
	for label in [title_label, hint_label, panel_label]:
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		hud.add_child(label)
	title_label.position = Vector2(22, 88)
	title_label.add_theme_font_size_override("font_size", 22)
	hint_label.position = Vector2(22, 656)
	hint_label.add_theme_font_size_override("font_size", 15)
	panel_label.position = Vector2(806, 36)
	panel_label.size = Vector2(430, 232)
	panel_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel_label.add_theme_font_size_override("font_size", 16)


func _bar_bg(pos: Vector2, size: Vector2) -> ColorRect:
	return _bar(pos, size, Color("#201d19"))


func _bar(pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = pos
	rect.size = size
	rect.color = color
	return rect


func _load_map(idx: int) -> void:
	map_index = clampi(idx, 0, maps.size() - 1)
	var data: Dictionary = maps[map_index]
	player.pos = data.spawn
	player.vel = Vector2.ZERO
	player.state = "IDLE"
	player.lock = 0
	enemies = []
	items = []
	npcs = []
	for e in data.enemies:
		var enemy: Dictionary = e.duplicate(true)
		enemy.max_hp = enemy.hp
		enemy.vel = Vector2.ZERO
		enemy.state = "PATROL"
		enemy.dir = -1
		enemy.attack_cd = 0.7
		enemy.dead = false
		enemies.append(enemy)
	for item in data.items:
		items.append(item.duplicate(true))
	for npc in data.npcs:
		npcs.append(npc.duplicate(true))
	boss_mode = false
	_show_banner(data.message)


func _physics_process(delta: float) -> void:
	_update_screen_effects(delta)
	if not game_started:
		_handle_frontend_input()
		_update_ui()
		queue_redraw()
		return
	if victory:
		if Input.is_action_just_pressed("interact"):
			_reset_game()
			game_started = false
		_update_ui()
		queue_redraw()
		return
	if game_over:
		if Input.is_action_just_pressed("interact"):
			_respawn_at_checkpoint()
		elif Input.is_action_just_pressed("divine_mark"):
			_reset_game()
		queue_redraw()
		return
	if Input.is_action_just_pressed("ui_cancel"):
		paused = !paused
		_set_overlay("pause" if paused else "")
	if Input.is_action_just_pressed("inventory"):
		_toggle_overlay("inventory")
	if Input.is_action_just_pressed("map"):
		_toggle_overlay("map")
	if Input.is_action_just_pressed("equipment"):
		_toggle_overlay("equipment")
	if Input.is_action_just_pressed("character"):
		_toggle_overlay("character")
	if Input.is_action_just_pressed("quests"):
		_toggle_overlay("quests")
	if Input.is_action_just_pressed("forge"):
		_toggle_overlay("forge")
	if Input.is_action_just_pressed("shop"):
		_toggle_overlay("shop")
	if Input.is_action_just_pressed("settings"):
		_toggle_overlay("settings")
	if Input.is_action_just_pressed("codex"):
		_toggle_overlay("codex")
	if Input.is_action_just_pressed("direction"):
		_toggle_overlay("direction")
	if Input.is_action_just_pressed("database"):
		_toggle_overlay("database")
	if Input.is_action_just_pressed("quick_save"):
		_save_game()
		_show_banner("Jogo salvo.")
	if overlay != "" and _overlay_allows_tab_cycle() and Input.is_action_just_pressed("menu_right"):
		_cycle_overlay(1)
	if overlay != "" and _overlay_allows_tab_cycle() and Input.is_action_just_pressed("menu_left"):
		_cycle_overlay(-1)
	if paused and not dialogue.active:
		_handle_overlay_input()
		_update_ui()
		queue_redraw()
		return
	if dialogue.active:
		if Input.is_action_just_pressed("interact"):
			dialogue.index += 1
			if dialogue.index >= dialogue.lines.size():
				dialogue.active = false
				paused = false
		_update_ui()
		queue_redraw()
		return
	_update_timers(delta)
	_handle_player(delta)
	_update_enemies(delta)
	_update_particles(delta)
	_update_checkpoint()
	_check_map_exit()
	_update_ui()
	queue_redraw()


func _handle_frontend_input() -> void:
	if Input.is_action_just_pressed("menu_up"):
		main_menu_index = wrapi(main_menu_index - 1, 0, main_menu_options.size())
		auth_index = max(0, auth_index - 1)
	if Input.is_action_just_pressed("menu_down"):
		main_menu_index = wrapi(main_menu_index + 1, 0, main_menu_options.size())
		auth_index += 1
	if auth_screen == "login":
		auth_index = clampi(auth_index, 0, 4)
		if Input.is_action_just_pressed("interact"):
			if auth_index == 2:
				if _login_user(account.email, login_password):
					_set_auth_screen("main_menu")
					_show_banner("Login realizado.")
				else:
					_show_banner(auth_message)
			elif auth_index == 3:
				_set_auth_screen("register")
				auth_index = 0
			elif auth_index == 4:
				_guest_login()
				_set_auth_screen("main_menu")
				_show_banner("Entrou como convidado.")
		return
	if auth_screen == "register":
		auth_index = clampi(auth_index, 0, 4)
		if Input.is_action_just_pressed("interact"):
			if auth_index == 3:
				if _register_user(account.name, account.email, register_password):
					_set_auth_screen("character_create")
					auth_index = 0
					_show_banner("Usuario cadastrado no banco local.")
				else:
					_show_banner(auth_message)
			elif auth_index == 4:
				_set_auth_screen("login")
				auth_index = 0
		return
	if auth_screen == "character_create":
		if Input.is_action_just_pressed("menu_up"):
			character_field_index = wrapi(character_field_index - 1, 0, 4)
		if Input.is_action_just_pressed("menu_down"):
			character_field_index = wrapi(character_field_index + 1, 0, 4)
		if Input.is_action_just_pressed("menu_left"):
			_cycle_character_field(-1)
		if Input.is_action_just_pressed("menu_right"):
			_cycle_character_field(1)
		if Input.is_action_just_pressed("divine_mark"):
			_set_auth_screen("main_menu")
		if Input.is_action_just_pressed("interact"):
			if character_profile.name.strip_edges().length() < 2:
				_show_banner("Digite um nome com pelo menos 2 letras.")
				return
			character_profile.name = character_profile.name.strip_edges()
			character_profile.type = character_type_options[character_type_index]
			character_profile.class = class_options[character_class_index]
			character_profile.origin = origin_options[character_origin_index]
			character_profile.created = true
			_apply_character_template()
			_db_upsert_character()
			_record_action("character_created", character_profile.duplicate(true))
			_save_game()
			_set_auth_screen("main_menu")
			_show_banner("Personagem criado.")
		return
	if auth_screen == "systems":
		if Input.is_action_just_pressed("menu_left"):
			_cycle_overlay(-1)
		if Input.is_action_just_pressed("menu_right"):
			_cycle_overlay(1)
		if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("divine_mark"):
			_set_auth_screen("main_menu")
			overlay = ""
		return
	if auth_screen == "main_menu":
		if Input.is_action_just_pressed("interact"):
			_activate_main_menu()
		if Input.is_action_just_pressed("divine_mark"):
			_set_auth_screen("login")
			auth_index = 0


func _activate_main_menu() -> void:
	var selected: String = main_menu_options[main_menu_index]
	if selected == "Novo Jogo":
		if not character_profile.created:
			_set_auth_screen("character_create")
			return
		_reset_game()
		game_started = true
		paused = false
		overlay = ""
		_record_action("new_game_started", {"character": character_profile.duplicate(true)})
		_save_game()
		_show_banner("Prologo iniciado.")
	elif selected == "Carregar":
		_load_save()
		game_started = true
		paused = false
		_record_action("continue_game", {"map_index": map_index})
	elif selected == "Criar Personagem":
		_set_auth_screen("character_create")
	elif selected == "Sistemas":
		_set_auth_screen("systems")
		overlay = "inventory"
	else:
		get_tree().quit()


func _cycle_character_field(direction: int) -> void:
	if character_field_index == 1:
		character_type_index = wrapi(character_type_index + direction, 0, character_type_options.size())
		character_profile.type = character_type_options[character_type_index]
		if character_profile.name in character_type_options:
			character_profile.name = character_profile.type
	elif character_field_index == 2:
		character_class_index = wrapi(character_class_index + direction, 0, class_options.size())
		character_profile.class = class_options[character_class_index]
	elif character_field_index == 3:
		character_origin_index = wrapi(character_origin_index + direction, 0, origin_options.size())
		character_profile.origin = origin_options[character_origin_index]


func _set_auth_screen(name: String) -> void:
	if auth_screen == name:
		return
	last_auth_screen = auth_screen
	auth_screen = name
	_start_transition(_screen_display_name(name), last_auth_screen, name)


func _set_overlay(name: String) -> void:
	if overlay == name:
		return
	last_overlay = overlay
	overlay = name
	_start_transition(_screen_display_name(name), last_overlay, name)


func _start_transition(title: String, from_screen := "", to_screen := "") -> void:
	transition_title = title
	transition_duration = 0.92
	transition_timer = transition_duration
	transition_from = from_screen
	transition_to = to_screen


func _update_screen_effects(delta: float) -> void:
	frontend_time += delta
	intro_timer = minf(intro_duration, intro_timer + delta)
	transition_timer = maxf(0.0, transition_timer - delta)
	screen_shake_power = maxf(0.0, screen_shake_power - delta * 22.0)


func _screen_display_name(name: String) -> String:
	var names := {
		"login": "PORTAO DE GRADON",
		"register": "JURAMENTO",
		"character_create": "FORJA DE HERDEIROS",
		"main_menu": "SALA DO CONSELHO",
		"systems": "ARQUIVOS DE GRADON",
		"pause": "PAUSA",
		"inventory": "INVENTARIO",
		"equipment": "ARSENAL",
		"character": "PERSONAGEM",
		"quests": "MISSOES",
		"map": "MAPA",
		"forge": "FORJA",
		"shop": "MERCADO",
		"settings": "CONFIGURACOES",
		"codex": "CODEX",
		"direction": "DIRECAO",
		"database": "BANCO LOCAL"
	}
	return names.get(name, name.to_upper())


func _apply_character_template() -> void:
	var stats := {
		"William": {"hp": 130, "stamina": 100, "courage": 100, "loyalty": 55},
		"Ethan": {"hp": 115, "stamina": 115, "courage": 90, "loyalty": 60},
		"Donovan": {"hp": 145, "stamina": 85, "courage": 95, "loyalty": 70},
		"Albert": {"hp": 105, "stamina": 95, "courage": 110, "loyalty": 50},
		"Hilda": {"hp": 100, "stamina": 125, "courage": 105, "loyalty": 65},
		"Elric": {"hp": 95, "stamina": 100, "courage": 130, "loyalty": 45}
	}
	var selected: Dictionary = stats.get(character_profile.type, stats["William"])
	player.base_max_hp = int(selected["hp"])
	player.max_hp = int(selected["hp"])
	player.hp = player.max_hp
	player.stamina = float(selected["stamina"])
	player.courage = float(selected["courage"])
	player.loyalty = int(selected["loyalty"])
	_apply_progression_stats()


func _sync_character_indices() -> void:
	character_type_index = max(0, character_type_options.find(character_profile.get("type", "William")))
	character_class_index = max(0, class_options.find(character_profile.get("class", "Cavaleiro")))
	character_origin_index = max(0, origin_options.find(character_profile.get("origin", "Gradon")))


func _normalize_player_runtime_data() -> void:
	var inventory_defaults := {"Aes Divinus": 0, "Fragmento de Ferro": 0, "Relato Manchado": 0, "Racao": 0}
	for key in inventory_defaults.keys():
		if not player.inventory.has(key):
			player.inventory[key] = inventory_defaults[key]
	if not player.has("coins"):
		player.coins = 35
	if not player.has("skill_points"):
		player.skill_points = 0
	if not player.has("instinct_points"):
		player.instinct_points = 0
	if not player.has("base_max_hp"):
		player.base_max_hp = player.max_hp
	if not player.has("equipment") or typeof(player.equipment) != TYPE_DICTIONARY:
		player.equipment = {}
	if not player.equipment.has("weapon") or not weapon_catalog.has(String(player.equipment.weapon)):
		player.equipment.weapon = "Espada de Gradon"
	if not player.equipment.has("tool") or not tool_catalog.has(String(player.equipment.tool)):
		player.equipment.tool = "Kit de Campanha"
	if not player.equipment.has("armor"):
		player.equipment.armor = "Couro militar"
	if not player.has("weapon_levels") or typeof(player.weapon_levels) != TYPE_DICTIONARY:
		player.weapon_levels = {}
	if not player.has("tool_levels") or typeof(player.tool_levels) != TYPE_DICTIONARY:
		player.tool_levels = {}
	if not player.weapon_levels.has("Espada de Gradon"):
		player.weapon_levels["Espada de Gradon"] = 1
	if not player.tool_levels.has("Kit de Campanha"):
		player.tool_levels["Kit de Campanha"] = 1
	var equipped_weapon := String(player.equipment.weapon)
	var equipped_tool := String(player.equipment.tool)
	if weapon_catalog.has(equipped_weapon) and not player.weapon_levels.has(equipped_weapon):
		player.weapon_levels[equipped_weapon] = 1
	if tool_catalog.has(equipped_tool) and not player.tool_levels.has(equipped_tool):
		player.tool_levels[equipped_tool] = 1
	var skill_defaults := {"Forca": 0, "Defesa": 0, "Agilidade": 0, "Fe": 0, "Honra": 0}
	if not player.has("skills") or typeof(player.skills) != TYPE_DICTIONARY:
		player.skills = {}
	for key in skill_defaults.keys():
		if not player.skills.has(key):
			player.skills[key] = skill_defaults[key]
	var instinct_defaults := {"Sobrevivencia": 0, "Percepcao": 0, "Furia Controlada": 0, "Marca Divina": 0}
	if not player.has("instincts") or typeof(player.instincts) != TYPE_DICTIONARY:
		player.instincts = {}
	for key in instinct_defaults.keys():
		if not player.instincts.has(key):
			player.instincts[key] = instinct_defaults[key]
	player.hp = clampi(int(player.hp), 0, int(player.max_hp))


func _db_load() -> void:
	if FileAccess.file_exists(DB_PATH):
		var file := FileAccess.open(DB_PATH, FileAccess.READ)
		if file != null:
			var text := file.get_buffer(file.get_length()).get_string_from_utf8().strip_edges()
			if not text.is_empty():
				var json := JSON.new()
				if json.parse(text) == OK and typeof(json.data) == TYPE_DICTIONARY:
					db = json.data
	if not db.has("users"):
		db.users = {}
	if not db.has("events"):
		db.events = []
	db.version = BUILD_VERSION
	_db_save()


func _db_save() -> void:
	var file := FileAccess.open(DB_PATH, FileAccess.WRITE)
	if file == null:
		auth_message = "Erro ao gravar banco local."
		return
	file.store_string(JSON.stringify(db, "\t"))


func _make_user_id(email: String) -> String:
	return email.strip_edges().to_lower().replace("@", "_at_").replace(".", "_").replace("-", "_")


func _hash_password(value: String) -> String:
	return str(value.hash())


func _register_user(name: String, email: String, password: String) -> bool:
	name = name.strip_edges()
	email = email.strip_edges().to_lower()
	if name.length() < 2:
		auth_message = "Nome precisa ter pelo menos 2 letras."
		return false
	if not email.contains("@") or email.length() < 6:
		auth_message = "Email invalido."
		return false
	if password.length() < 4:
		auth_message = "Senha precisa ter pelo menos 4 caracteres."
		return false
	var user_id := _make_user_id(email)
	if db.users.has(user_id):
		auth_message = "Usuario ja existe. Use login."
		return false
	db.users[user_id] = {
		"id": user_id,
		"name": name,
		"email": email,
		"password_hash": _hash_password(password),
		"created_at": Time.get_datetime_string_from_system(),
		"characters": {},
		"settings": game_settings.duplicate(true),
		"save": {},
		"actions": []
	}
	current_user_id = user_id
	account = {"id": user_id, "email": email, "name": name, "logged_in": true, "registered": true}
	auth_message = "Cadastro salvo no banco local."
	_record_action("user_registered", {"email": email, "name": name})
	_db_save()
	return true


func _login_user(email: String, password: String) -> bool:
	email = email.strip_edges().to_lower()
	var user_id := _make_user_id(email)
	if not db.users.has(user_id):
		auth_message = "Usuario nao encontrado."
		return false
	var user: Dictionary = db.users[user_id]
	if String(user.get("password_hash", "")) != _hash_password(password):
		auth_message = "Senha incorreta."
		return false
	current_user_id = user_id
	account = {"id": user_id, "email": user.email, "name": user.name, "logged_in": true, "registered": true}
	auth_message = "Login salvo no banco local."
	_record_action("user_login", {"email": email})
	_load_save()
	return true


func _guest_login() -> void:
	var user_id := "guest"
	if not db.users.has(user_id):
		db.users[user_id] = {
			"id": user_id,
			"name": "Convidado",
			"email": "convidado@aesdivinus.local",
			"password_hash": "",
			"created_at": Time.get_datetime_string_from_system(),
			"characters": {},
			"settings": game_settings.duplicate(true),
			"save": {},
			"actions": []
		}
	current_user_id = user_id
	account = {"id": user_id, "email": "convidado@aesdivinus.local", "name": "Convidado", "logged_in": true, "registered": false}
	auth_message = "Modo convidado salvo no banco local."
	_record_action("guest_login", {})
	_load_save()


func _current_user() -> Dictionary:
	if current_user_id == "" or not db.users.has(current_user_id):
		_guest_login()
	return db.users[current_user_id]


func _db_upsert_character() -> void:
	var user: Dictionary = _current_user()
	var character_id: String = character_profile.name.strip_edges().to_lower().replace(" ", "_")
	user.characters[character_id] = character_profile.duplicate(true)
	db.users[current_user_id] = user
	_db_save()


func _record_action(action_type: String, payload: Dictionary) -> void:
	var event := {
		"time": Time.get_datetime_string_from_system(),
		"user_id": current_user_id,
		"action": action_type,
		"payload": payload
	}
	db.events.append(event)
	if current_user_id != "" and db.users.has(current_user_id):
		var user: Dictionary = db.users[current_user_id]
		if not user.has("actions"):
			user.actions = []
		user.actions.append(event)
		db.users[current_user_id] = user


func _toggle_overlay(name: String) -> void:
	_set_overlay("" if overlay == name else name)
	paused = overlay != ""


func _cycle_overlay(direction: int) -> void:
	if overlay == "":
		_set_overlay(system_overlay_order[0])
		paused = true
		return
	var idx := system_overlay_order.find(overlay)
	if idx < 0:
		idx = 0
	_set_overlay(system_overlay_order[wrapi(idx + direction, 0, system_overlay_order.size())])
	paused = true


func _overlay_allows_tab_cycle() -> bool:
	return not (overlay in ["inventory", "equipment", "character", "forge", "shop", "settings", "codex"])


func _handle_overlay_input() -> void:
	if overlay == "pause" and Input.is_action_just_pressed("interact"):
		paused = false
		_set_overlay("")
	elif overlay == "inventory":
		_handle_inventory_input()
	elif overlay == "settings":
		_handle_settings_input()
	elif overlay == "equipment":
		_handle_equipment_input()
	elif overlay == "character":
		_handle_progression_input()
	elif overlay == "forge":
		_handle_forge_input()
	elif overlay == "shop":
		_handle_shop_input()
	elif overlay == "codex":
		_handle_codex_input()


func _handle_inventory_input() -> void:
	var rows: Array[String] = _inventory_rows()
	if rows.is_empty():
		return
	if Input.is_action_just_pressed("menu_up"):
		inventory_index = wrapi(inventory_index - 1, 0, rows.size())
	if Input.is_action_just_pressed("menu_down"):
		inventory_index = wrapi(inventory_index + 1, 0, rows.size())
	if Input.is_action_just_pressed("interact"):
		_use_inventory_item(rows[inventory_index])


func _inventory_rows() -> Array[String]:
	var rows: Array[String] = []
	for key in player.inventory.keys():
		if int(player.inventory.get(key, 0)) > 0:
			rows.append(String(key))
	return rows


func _use_inventory_item(item_name: String) -> void:
	if int(player.inventory.get(item_name, 0)) <= 0:
		return
	match item_name:
		"Racao":
			if player.hp >= player.max_hp:
				_show_banner("Vida ja esta cheia.")
				return
			player.inventory[item_name] = int(player.inventory.get(item_name, 0)) - 1
			player.hp = mini(player.max_hp, player.hp + 35)
			_record_action("item_used", {"item": item_name, "effect": "heal"})
			_save_game()
			_show_banner("Racao usada. Vida recuperada.")
		"Aes Divinus":
			if player.courage >= 100:
				_show_banner("Coragem ja esta cheia.")
				return
			player.inventory[item_name] = int(player.inventory.get(item_name, 0)) - 1
			player.courage = minf(100, player.courage + 28 + int(player.skills.get("Fe", 0)) * 3)
			_record_action("item_used", {"item": item_name, "effect": "courage"})
			_save_game()
			_show_banner("Aes Divinus consumido. Coragem restaurada.")
		_:
			_show_banner("%s e material de forja ou venda." % item_name)


func _handle_equipment_input() -> void:
	var rows: Array[String] = _equipment_rows()
	if Input.is_action_just_pressed("menu_up"):
		equipment_index = wrapi(equipment_index - 1, 0, rows.size())
	if Input.is_action_just_pressed("menu_down"):
		equipment_index = wrapi(equipment_index + 1, 0, rows.size())
	if Input.is_action_just_pressed("interact"):
		var selected := rows[equipment_index]
		if weapon_catalog.has(selected):
			player.equipment.weapon = selected
		elif tool_catalog.has(selected):
			player.equipment.tool = selected
		_record_action("equipment_changed", player.equipment.duplicate(true))
		_save_game()
		_show_banner("%s equipado." % selected)


func _handle_progression_input() -> void:
	var rows: Array[String] = _progression_rows()
	if Input.is_action_just_pressed("menu_up"):
		progression_index = wrapi(progression_index - 1, 0, rows.size())
	if Input.is_action_just_pressed("menu_down"):
		progression_index = wrapi(progression_index + 1, 0, rows.size())
	if Input.is_action_just_pressed("interact"):
		_upgrade_progression(rows[progression_index])


func _handle_forge_input() -> void:
	if Input.is_action_just_pressed("menu_up"):
		forge_index = wrapi(forge_index - 1, 0, forge_recipes.size())
	if Input.is_action_just_pressed("menu_down"):
		forge_index = wrapi(forge_index + 1, 0, forge_recipes.size())
	if Input.is_action_just_pressed("interact"):
		_craft_selected_recipe()
	if Input.is_action_just_pressed("divine_mark"):
		_upgrade_equipped_item()


func _handle_shop_input() -> void:
	if Input.is_action_just_pressed("menu_up"):
		shop_index = wrapi(shop_index - 1, 0, shop_items.size())
	if Input.is_action_just_pressed("menu_down"):
		shop_index = wrapi(shop_index + 1, 0, shop_items.size())
	if Input.is_action_just_pressed("interact"):
		_buy_selected_shop_item()
	if Input.is_action_just_pressed("divine_mark"):
		_sell_selected_shop_item()


func _handle_codex_input() -> void:
	var rows: Array = world_lore.keys()
	if rows.is_empty():
		return
	if Input.is_action_just_pressed("menu_up"):
		codex_index = wrapi(codex_index - 1, 0, rows.size())
	if Input.is_action_just_pressed("menu_down"):
		codex_index = wrapi(codex_index + 1, 0, rows.size())


func _equipment_rows() -> Array[String]:
	var rows: Array[String] = []
	for name in player.weapon_levels.keys():
		rows.append(String(name))
	for name in player.tool_levels.keys():
		rows.append(String(name))
	if rows.is_empty():
		rows.append("Espada de Gradon")
	return rows


func _progression_rows() -> Array[String]:
	var rows: Array[String] = []
	for key in player.skills.keys():
		rows.append("skill:" + String(key))
	for key in player.instincts.keys():
		rows.append("instinct:" + String(key))
	return rows


func _upgrade_progression(row: String) -> void:
	var parts := row.split(":")
	if parts.size() != 2:
		return
	var kind := String(parts[0])
	var name := String(parts[1])
	if kind == "skill":
		if int(player.skill_points) <= 0:
			_show_banner("Sem pontos de habilidade.")
			return
		if int(player.skills.get(name, 0)) >= 5:
			_show_banner("%s ja esta no nivel maximo." % name)
			return
		player.skill_points = int(player.skill_points) - 1
		player.skills[name] = int(player.skills.get(name, 0)) + 1
	else:
		if int(player.instinct_points) <= 0:
			_show_banner("Sem pontos de instinto.")
			return
		if int(player.instincts.get(name, 0)) >= 5:
			_show_banner("%s ja esta no nivel maximo." % name)
			return
		player.instinct_points = int(player.instinct_points) - 1
		player.instincts[name] = int(player.instincts.get(name, 0)) + 1
	_apply_progression_stats()
	_record_action("progression_upgrade", {"kind": kind, "name": name})
	_save_game()
	_show_banner("%s melhorado." % name)


func _craft_selected_recipe() -> void:
	var recipe: Dictionary = forge_recipes[forge_index]
	var name := String(recipe.name)
	if (recipe.kind == "weapon" and player.weapon_levels.has(name)) or (recipe.kind == "tool" and player.tool_levels.has(name)):
		_show_banner("%s ja existe. Use Q para melhorar nivel." % name)
		return
	if int(player.coins) < int(recipe.coins):
		_record_action("forge_failed", {"reason": "coins", "item": recipe.name})
		_show_banner("Moedas insuficientes.")
		return
	var cost: Dictionary = recipe.cost
	for item in cost.keys():
		if int(player.inventory.get(item, 0)) < int(cost[item]):
			_record_action("forge_failed", {"reason": "materials", "item": recipe.name})
			_show_banner("Materiais insuficientes.")
			return
	player.coins = int(player.coins) - int(recipe.coins)
	for item in cost.keys():
		player.inventory[item] = int(player.inventory.get(item, 0)) - int(cost[item])
	if recipe.kind == "weapon":
		player.weapon_levels[name] = max(1, int(player.weapon_levels.get(name, 0)))
		player.equipment.weapon = name
	elif recipe.kind == "tool":
		player.tool_levels[name] = max(1, int(player.tool_levels.get(name, 0)))
		player.equipment.tool = name
	player.inventory[name] = int(player.inventory.get(name, 0)) + 1
	_record_action("forge_success", {"item": name, "kind": recipe.kind})
	_save_game()
	_show_banner("%s criado e equipado." % name)


func _upgrade_equipped_item() -> void:
	var weapon := String(player.equipment.get("weapon", "Espada de Gradon"))
	var tool := String(player.equipment.get("tool", "Kit de Campanha"))
	var target := weapon if weapon_catalog.has(weapon) else tool
	var levels: Dictionary = player.weapon_levels if weapon_catalog.has(target) else player.tool_levels
	var level := int(levels.get(target, 1))
	if level >= 5:
		_show_banner("%s ja esta no nivel maximo." % target)
		return
	var coin_cost := 35 + level * 25
	var iron_cost := 1 + level
	var aes_cost := 1 if level >= 3 else 0
	if int(player.coins) < coin_cost or int(player.inventory.get("Fragmento de Ferro", 0)) < iron_cost or int(player.inventory.get("Aes Divinus", 0)) < aes_cost:
		_show_banner("Custo para melhorar: %d moedas, Ferro x%d, Aes x%d." % [coin_cost, iron_cost, aes_cost])
		return
	player.coins = int(player.coins) - coin_cost
	player.inventory["Fragmento de Ferro"] = int(player.inventory.get("Fragmento de Ferro", 0)) - iron_cost
	player.inventory["Aes Divinus"] = int(player.inventory.get("Aes Divinus", 0)) - aes_cost
	levels[target] = level + 1
	_record_action("item_upgraded", {"item": target, "level": level + 1})
	_save_game()
	_show_banner("%s subiu para nivel %d." % [target, level + 1])


func _buy_selected_shop_item() -> void:
	var item: Dictionary = shop_items[shop_index]
	if int(player.coins) < int(item.price):
		_show_banner("Moedas insuficientes.")
		return
	player.coins = int(player.coins) - int(item.price)
	player.inventory[item.name] = int(player.inventory.get(item.name, 0)) + 1
	_record_action("shop_buy", {"item": item.name, "price": item.price})
	_save_game()
	_show_banner("%s comprado." % item.name)


func _sell_selected_shop_item() -> void:
	var item: Dictionary = shop_items[shop_index]
	if int(player.inventory.get(item.name, 0)) <= 0:
		_show_banner("Voce nao tem %s para vender." % item.name)
		return
	var bonus := 1.0 + int(player.tool_levels.get("Bolsa de Mercador", 0)) * 0.08
	var value := int(round(float(item.sell) * bonus))
	player.inventory[item.name] = int(player.inventory.get(item.name, 0)) - 1
	player.coins = int(player.coins) + value
	_record_action("shop_sell", {"item": item.name, "value": value})
	_save_game()
	_show_banner("%s vendido por %d moedas." % [item.name, value])


func _apply_progression_stats() -> void:
	var hp_bonus := int(player.skills.get("Defesa", 0)) * 8 + int(player.instincts.get("Sobrevivencia", 0)) * 6
	var base_hp := int(player.get("base_max_hp", player.max_hp))
	var old_max := int(player.max_hp)
	player.max_hp = base_hp + hp_bonus
	if player.max_hp > old_max:
		player.hp = mini(player.hp + (player.max_hp - old_max), player.max_hp)
	else:
		player.hp = mini(player.hp, player.max_hp)


func _handle_settings_input() -> void:
	var rows: Array[String] = _settings_rows()
	if Input.is_action_just_pressed("menu_up"):
		settings_index = wrapi(settings_index - 1, 0, rows.size())
	if Input.is_action_just_pressed("menu_down"):
		settings_index = wrapi(settings_index + 1, 0, rows.size())
	if Input.is_action_just_pressed("menu_left"):
		_adjust_setting(rows[settings_index], -1)
	if Input.is_action_just_pressed("menu_right"):
		_adjust_setting(rows[settings_index], 1)
	if Input.is_action_just_pressed("interact"):
		_apply_runtime_settings()
		_record_action("settings_saved", game_settings.duplicate(true))
		_save_game()
		_show_banner("Configuracoes salvas no banco.")


func _settings_rows() -> Array[String]:
	return ["quality_profile", "resolution_scale", "target_fps", "ui_text_size", "high_contrast", "screen_shake", "particles_enabled", "animated_background"]


func _adjust_setting(key: String, direction: int) -> void:
	match key:
		"quality_profile":
			var idx: int = quality_profile_order.find(String(game_settings.quality_profile))
			game_settings.quality_profile = quality_profile_order[wrapi(idx + direction, 0, quality_profile_order.size())]
		"resolution_scale":
			game_settings.resolution_scale = clampi(int(game_settings.resolution_scale) + direction * 10, 50, 100)
		"target_fps":
			var fps_values: Array[int] = [30, 45, 60, 75, 120, 144]
			var fps_idx: int = max(0, fps_values.find(int(game_settings.target_fps)))
			game_settings.target_fps = fps_values[wrapi(fps_idx + direction, 0, fps_values.size())]
		"ui_text_size":
			game_settings.ui_text_size = clampi(int(game_settings.ui_text_size) + direction, 14, 22)
		"high_contrast", "screen_shake", "particles_enabled", "animated_background":
			game_settings[key] = not bool(game_settings[key])
	_apply_runtime_settings()


func _apply_runtime_settings() -> void:
	Engine.max_fps = int(game_settings.target_fps)
	if panel_label != null:
		panel_label.add_theme_font_size_override("font_size", int(game_settings.ui_text_size))


func _quality_profile() -> Dictionary:
	var selected := String(game_settings.get("quality_profile", "Alto"))
	if not quality_profiles.has(selected):
		selected = "Alto"
		game_settings.quality_profile = selected
	return quality_profiles[selected]


func _update_timers(delta: float) -> void:
	player.invuln = maxf(0, player.invuln - delta)
	player.lock = maxf(0, player.lock - delta)
	player.attack_timer = maxf(0, player.attack_timer - delta)
	player.special_cd = maxf(0, player.special_cd - delta)
	banner_timer = maxf(0, banner_timer - delta)
	player.stamina = minf(100, player.stamina + 18 * delta)
	player.courage = clampf(player.courage + 2 * delta, 0, 100)
	for text in floating_text:
		text.life -= delta
		text.pos.y -= 26 * delta
	floating_text = floating_text.filter(func(t): return t.life > 0)


func _handle_player(delta: float) -> void:
	var dir: float = Input.get_axis("move_left", "move_right")
	var can_move: bool = player.lock <= 0
	var speed := 185.0
	if Input.is_action_pressed("run") and absf(dir) > 0 and player.stamina > 0:
		speed = 300.0
		player.stamina = maxf(0, player.stamina - 20 * delta)
	if dir != 0:
		player.facing = signi(dir)
	if can_move:
		player.vel.x = dir * speed
	else:
		player.vel.x = move_toward(player.vel.x, 0, 900 * delta)
	if Input.is_action_just_pressed("jump") and player.on_floor and can_move:
		player.vel.y = -640
		player.on_floor = false
		player.state = "JUMP"
	if Input.is_action_just_pressed("dodge") and player.stamina >= 22 and can_move:
		player.state = "DODGE"
		player.lock = 0.24
		player.invuln = 0.32
		player.stamina -= 22
		player.vel.x = player.facing * 620
		_spawn_spark(player.pos + Vector2(0, -24), Color("#b6d6e8"))
	if Input.is_action_just_pressed("divine_mark") and player.special_cd <= 0 and player.courage >= 25:
		_divine_mark()
	if Input.is_action_just_pressed("interact"):
		_interact()
	if Input.is_action_pressed("attack") and player.lock <= 0:
		player.charge = minf(1.5, player.charge + delta)
	if Input.is_action_just_released("attack") and player.lock <= 0:
		if player.charge > 0.55:
			_attack(true)
		else:
			_attack(false)
		player.charge = 0
	if not Input.is_action_pressed("attack"):
		player.charge = 0
	player.vel.y += GRAVITY * delta
	player.pos += player.vel * delta
	if player.pos.y >= FLOOR_Y:
		if not player.on_floor and player.vel.y > 360:
			player.state = "LAND"
			player.lock = minf(player.lock, 0.08)
		player.pos.y = FLOOR_Y
		player.vel.y = 0
		player.on_floor = true
	else:
		player.on_floor = false
	player.pos.x = clampf(player.pos.x, 40, WORLD_W - 40)
	_pick_state(dir, speed)
	camera_x = clampf(player.pos.x - 640, 0, WORLD_W - 1280)
	if bool(game_settings.screen_shake) and screen_shake_power > 0:
		camera_x = clampf(camera_x + randf_range(-screen_shake_power, screen_shake_power), 0, WORLD_W - 1280)


func _pick_state(dir: float, speed: float) -> void:
	if player.hp <= 0:
		player.state = "DEAD"
	elif player.lock > 0 and player.state in ["ATTACK", "HEAVY_ATTACK", "DODGE", "SPECIAL", "HURT", "LAND"]:
		pass
	elif Input.is_action_pressed("block") and player.on_floor and player.stamina > 0:
		player.state = "BLOCK"
		player.stamina = maxf(0, player.stamina - 10 * get_physics_process_delta_time())
	elif not player.on_floor:
		player.state = "JUMP" if player.vel.y < 0 else "FALL"
	elif absf(dir) > 0:
		player.state = "RUN" if speed > 200 else "WALK"
	else:
		player.state = "IDLE"


func _attack(heavy: bool) -> void:
	if player.stamina < (28 if heavy else 8):
		_float_text(player.pos + Vector2(0, -78), "SEM STAMINA", Color("#d6b452"))
		return
	var is_air: bool = not player.on_floor
	player.combo = 1 if heavy or is_air else (player.combo % 3) + 1
	player.state = "HEAVY_ATTACK" if heavy else ("ATTACK" if not is_air else "AIR_ATTACK")
	player.lock = 0.42 if heavy else 0.24
	player.attack_timer = 0.18
	player.stamina = maxf(0, player.stamina - (28 if heavy else 10))
	var reach: int = 82 if not heavy else 118
	var damage: int = 32 if heavy else 18 + player.combo * 4
	var weapon_name := String(player.equipment.get("weapon", "Espada de Gradon"))
	var weapon_level := int(player.weapon_levels.get(weapon_name, 1))
	var weapon_data: Dictionary = weapon_catalog.get(weapon_name, weapon_catalog["Espada de Gradon"])
	damage += int(weapon_data.base_damage) + weapon_level * 3 + int(player.skills.get("Forca", 0)) * 3
	reach += int(player.skills.get("Agilidade", 0)) * 3
	if weapon_data.type == "spear":
		reach += 18
	elif weapon_data.type == "axe" and heavy:
		damage += 10
	elif weapon_data.type == "staff":
		player.courage = minf(100, player.courage + 1.5)
	if is_air:
		damage += 8
	var hit_center: Vector2 = player.pos + Vector2(player.facing * reach, -30)
	for enemy in enemies:
		if enemy.dead:
			continue
		if hit_center.distance_to(enemy.pos + Vector2(0, -28)) < reach:
			var final_damage := damage
			if weapon_name.contains("Aes") and _is_corrupted_enemy(enemy):
				final_damage += 18 + weapon_level * 3
				_float_text(enemy.pos + Vector2(0, -106), "AES", Color("#79d7a5"))
				_spawn_spark(enemy.pos + Vector2(0, -36), Color("#79d7a5"))
			_damage_enemy(enemy, final_damage, player.facing)
	_spawn_spark(hit_center, Color("#f0d06a"))


func _is_corrupted_enemy(enemy: Dictionary) -> bool:
	return String(enemy.get("type", "")) in ["barbarian", "servi", "ignis", "canis", "boss"]


func _damage_enemy(enemy: Dictionary, amount: int, dir: int) -> void:
	enemy.hp -= amount
	enemy.state = "HURT"
	enemy.vel.x = dir * 180
	_float_text(enemy.pos + Vector2(0, -70), str(amount), Color("#f5df8e"))
	if enemy.hp <= 0:
		enemy.dead = true
		enemy.state = "DEAD"
		var coin_reward := 10
		if enemy.type == "canis":
			coin_reward = 16
		elif enemy.type == "servi":
			coin_reward = 14
		elif enemy.type == "ignis":
			coin_reward = 28
		elif enemy.type == "boss":
			coin_reward = 75
		coin_reward += int(player.instincts.get("Percepcao", 0)) * 2
		player.coins = int(player.coins) + coin_reward
		player.skill_points = int(player.skill_points) + (1 if randi() % 3 == 0 else 0)
		player.instinct_points = int(player.instinct_points) + (1 if enemy.type == "boss" else 0)
		player.courage = minf(100, player.courage + 8 + int(player.instincts.get("Furia Controlada", 0)) * 2)
		if int(player.tool_levels.get("Picareta de Robert", 0)) > 0 and randi() % 2 == 0:
			player.inventory["Fragmento de Ferro"] = int(player.inventory.get("Fragmento de Ferro", 0)) + 1
		_float_text(enemy.pos + Vector2(0, -94), "+%d moedas" % coin_reward, Color("#d8b45a"))
		if enemy.type == "boss":
			_show_banner("William cai de joelhos, mas a rota para Gradon se abre.")
			player.loyalty += 5
	else:
		_spawn_spark(enemy.pos + Vector2(0, -35), Color("#c74747"))


func _divine_mark() -> void:
	player.state = "SPECIAL"
	player.lock = 0.55
	player.special_cd = 8.0
	player.courage -= 25
	_record_action("divine_mark_used", {"map": maps[map_index].id, "courage": player.courage})
	for enemy in enemies:
		if enemy.dead:
			continue
		if player.pos.distance_to(enemy.pos) < 290:
			_damage_enemy(enemy, 42 + int(player.skills.get("Fe", 0)) * 5 + int(player.instincts.get("Marca Divina", 0)) * 6, signi(enemy.pos.x - player.pos.x))
	if bool(game_settings.particles_enabled):
		var profile: Dictionary = _quality_profile()
		var count: int = max(2, int(round(18.0 * float(profile.particles) * _graphics_load_factor())))
		for i in range(count):
			particles.append({"pos": player.pos + Vector2(randf_range(-40, 40), randf_range(-80, -10)), "vel": Vector2(randf_range(-70, 70), randf_range(-130, -20)), "life": randf_range(0.35, 0.9), "color": Color("#6ee7cf")})


func _interact() -> void:
	for npc in npcs:
		if absf(npc.pos.x - player.pos.x) < 90:
			dialogue = {"active": true, "name": npc.name, "lines": npc.lines, "index": 0}
			paused = true
			return
	for item in items:
		if not item.taken and absf(item.pos.x - player.pos.x) < 70:
			item.taken = true
			player.inventory[item.name] = player.inventory.get(item.name, 0) + item.amount
			_record_action("item_collected", {"item": item.name, "amount": item.amount, "map": maps[map_index].id})
			_save_game()
			_show_banner("%s x%d coletado." % [item.name, item.amount])
			return


func _update_enemies(delta: float) -> void:
	boss_mode = false
	for enemy in enemies:
		if enemy.dead:
			continue
		var dist: float = player.pos.x - enemy.pos.x
		var abs_dist: float = absf(dist)
		if enemy.type == "boss" and abs_dist < 850:
			boss_mode = true
		enemy.attack_cd -= delta
		if abs_dist < 620:
			enemy.state = "CHASE"
			enemy.dir = signi(dist)
			var speed := 96.0
			if enemy.type == "canis":
				speed = 172.0
			elif enemy.type == "servi":
				speed = 78.0
			elif enemy.type == "ignis":
				speed = 148.0
			elif enemy.type == "boss":
				speed = 78.0
			enemy.vel.x = enemy.dir * speed
		else:
			enemy.state = "PATROL"
			enemy.vel.x = enemy.dir * 55
			if enemy.pos.x < 120 or enemy.pos.x > WORLD_W - 120:
				enemy.dir *= -1
		if abs_dist < (92 if enemy.type != "boss" else 145) and enemy.attack_cd <= 0:
			_enemy_attack(enemy)
		enemy.pos.x += enemy.vel.x * delta
		enemy.pos.x = clampf(enemy.pos.x, 40, WORLD_W - 40)


func _enemy_attack(enemy: Dictionary) -> void:
	enemy.state = "ATTACK"
	enemy.attack_cd = 1.25
	if enemy.type == "canis":
		enemy.attack_cd = 0.85
	elif enemy.type == "servi":
		enemy.attack_cd = 1.45
	elif enemy.type == "ignis":
		enemy.attack_cd = 1.05
	elif enemy.type == "boss":
		enemy.attack_cd = 1.8
	var damage := 14
	if enemy.type == "canis":
		damage = 18
	elif enemy.type == "servi":
		damage = 16
	elif enemy.type == "ignis":
		damage = 24
	elif enemy.type == "boss":
		damage = 30
	if player.invuln > 0:
		return
	if player.state == "BLOCK" and signi(enemy.pos.x - player.pos.x) == player.facing and player.stamina > 8:
		player.stamina -= maxf(6, 14 - int(player.skills.get("Defesa", 0)) * 1.5)
		_float_text(player.pos + Vector2(0, -78), "BLOQUEIO", Color("#9fd6ff"))
		return
	_damage_player(damage, signi(player.pos.x - enemy.pos.x))


func _damage_player(amount: int, dir: int) -> void:
	amount = maxi(1, amount - int(player.skills.get("Defesa", 0)) * 2 - int(player.instincts.get("Sobrevivencia", 0)))
	player.hp -= amount
	player.courage = maxf(0, player.courage - amount * 0.45)
	player.vel.x = dir * 260
	if bool(game_settings.screen_shake):
		screen_shake_power = minf(16.0, screen_shake_power + amount * 0.25)
	player.state = "HURT"
	player.lock = 0.32
	player.invuln = 0.55
	_float_text(player.pos + Vector2(0, -86), "-%d" % amount, Color("#ff9090"))
	if player.hp <= 0:
		player.hp = 0
		player.state = "DEAD"
		game_over = true
		_record_action("player_dead", {"map": maps[map_index].id})
		_save_game()


func _check_map_exit() -> void:
	var living := enemies.filter(func(e): return not e.dead)
	if player.pos.x > WORLD_W - 140 and living.is_empty():
		if map_index < maps.size() - 1:
			_load_map(map_index + 1)
			checkpoint = {"map_index": map_index, "pos_x": player.pos.x}
			_record_action("map_changed", {"map_index": map_index, "map": maps[map_index].id})
			_save_game()
		else:
			victory = true
			_record_action("prologue_completed", {"map": maps[map_index].id})
			_save_game()
			_show_banner("Prologo concluido: Gradon aguarda William.")


func _update_checkpoint() -> void:
	if checkpoint.get("map_index", -1) != map_index and player.pos.x > 420:
		checkpoint = {"map_index": map_index, "pos_x": player.pos.x}
		_record_action("checkpoint_saved", checkpoint.duplicate(true))
		_save_game()
	elif checkpoint.get("map_index", -1) == map_index and player.pos.x > float(checkpoint.get("pos_x", 120.0)) + 650:
		checkpoint = {"map_index": map_index, "pos_x": player.pos.x}
		_record_action("checkpoint_saved", checkpoint.duplicate(true))
		_save_game()


func _update_particles(delta: float) -> void:
	for p in particles:
		p.life -= delta
		p.pos += p.vel * delta
		p.vel.y += 360 * delta
	particles = particles.filter(func(p): return p.life > 0)


func _update_ui() -> void:
	hp_bar.size.x = 250 * player.hp / player.max_hp
	stamina_bar.size.x = 210 * player.stamina / 100.0
	courage_bar.size.x = 190 * player.courage / 100.0
	var data: Dictionary = maps[map_index]
	title_label.text = "AESDIVINUS | %s" % auth_screen if not game_started else "%s | %s" % [data.title, player.state]
	hint_label.text = _hint_text()
	if not game_started:
		panel_label.position = Vector2(812, 34)
		panel_label.size = Vector2(424, 224)
		panel_label.add_theme_font_size_override("font_size", 15)
	else:
		panel_label.position = Vector2(790, 24)
		panel_label.size = Vector2(460, 250)
		panel_label.add_theme_font_size_override("font_size", int(game_settings.ui_text_size))
	panel_label.text = _panel_text()


func _hint_text() -> String:
	if not game_started:
		if auth_screen == "character_create":
			return "A/D classe | Q origem | E confirmar"
		if auth_screen == "systems":
			return "A/D trocar sistema | Q/Esc voltar"
		return "W/S selecionar | E confirmar | Q voltar"
	if victory:
		return "PROLOGO CONCLUIDO | E voltar ao titulo"
	if game_over:
		return "GAME OVER | E checkpoint | Q reiniciar"
	if dialogue.active:
		return "E para avançar diálogo"
	if overlay != "":
		if overlay in ["inventory", "equipment", "character", "forge", "shop", "settings", "codex"]:
			return "W/S selecionar | E confirmar/usar | Q acao secundaria quando indicada | Esc/atalho volta"
		return "A/D trocar aba | E acao da tela | Esc/atalho para voltar"
	for npc in npcs:
		if absf(npc.pos.x - player.pos.x) < 90:
			return "E Interagir"
	for item in items:
		if not item.taken and absf(item.pos.x - player.pos.x) < 70:
			return "E Coletar"
	return "A/D mover | Shift correr | Espaco pular | J atacar | K esquivar | L bloquear | Q Marca Divina | I/O/C/U/M/F/V/P/R/T/B telas"


func _panel_text() -> String:
	if not game_started:
		return _frontend_panel_text()
	if victory:
		return "GRADON\n\nWilliam sobreviveu ao prologo da Floresta Wood.\n\nInventario preservado, checkpoint salvo, rota pronta para os proximos capitulos."
	if dialogue.active:
		return "%s\n\n%s" % [dialogue.name, dialogue.lines[dialogue.index]]
	if overlay == "pause":
		return "PAUSA\n\nE - Continuar\nI - Inventario\nO - Equipamentos\nC - Personagem\nU - Missoes\nM - Mapa\nF - Forja\nV - Mercado\nP - Configuracoes\nR - Codex\nT - Direcao\nB - Banco\nF5 - Salvar rapido"
	if overlay == "inventory":
		return _inventory_panel_text()
	if overlay == "equipment":
		return _equipment_panel_text()
	if overlay == "character":
		return _character_panel_text()
	if overlay == "quests":
		return _quests_panel_text()
	if overlay == "map":
		return _map_panel_text()
	if overlay == "forge":
		return _forge_panel_text()
	if overlay == "shop":
		return _shop_panel_text()
	if overlay == "settings":
		return _settings_panel_text()
	if overlay == "codex":
		return _codex_panel_text()
	if overlay == "direction":
		return _direction_panel_text()
	if overlay == "database":
		return _database_panel_text()
	var living := enemies.filter(func(e): return not e.dead).size()
	var text := "%s\nInimigos restantes: %d\nLealdade: %d\nMarca Divina: %s" % [maps[map_index].goal, living, player.loyalty, "pronta" if player.special_cd <= 0 else "%.1fs" % player.special_cd]
	if banner_timer > 0:
		text += "\n\n" + banner
	return text


func _frontend_panel_text() -> String:
	if auth_screen == "login":
		var options := [
			"Email: %s" % account.email,
			"Senha: %s" % _mask_text(login_password),
			"Entrar",
			"Cadastrar novo usuario",
			"Entrar como convidado"
		]
		return "PORTAO DE GRADON\n\n%s\n\nConta: %s\nStatus: %s" % [
			_menu_lines(options, auth_index),
			account.email,
			auth_message
		]
	if auth_screen == "register":
		var options := [
			"Nome: %s" % account.name,
			"Email: %s" % account.email,
			"Senha: %s" % _mask_text(register_password),
			"Criar usuario",
			"Voltar ao login"
		]
		return "JURAMENTO\n\n%s\n\nBanco: %s\n\nO cadastro cria usuario, personagem, save e historico de acoes em user://aesdivinus_db.json." % [
			_menu_lines(options, auth_index),
			auth_message
		]
	if auth_screen == "character_create":
		var preview: Dictionary = character_models[character_type_options[character_type_index]]
		var fields := [
			"Nome: %s%s" % [character_profile.name, "_" if character_field_index == 0 else ""],
			"Personagem base: < %s >" % character_type_options[character_type_index],
			"Classe: < %s >" % class_options[character_class_index],
			"Origem: < %s >" % origin_options[character_origin_index]
		]
		return "CRIACAO DE PERSONAGEM\n\n%s\n\nModelo: %s\nSilhueta: %s\nArma visual: %s\n\nW/S escolhe campo\nDigite para alterar Nome\nA/D muda personagem, classe ou origem\nE confirma | Q volta\n\nPersonagens do documento: William, Ethan, Donovan, Albert, Hilda, Elric." % [
			_menu_lines(fields, character_field_index),
			preview.role,
			preview.silhouette,
			preview.weapon
		]
	if auth_screen == "systems":
		return "SISTEMAS DO JOGO\n\nAba atual: %s\n\n%s\n\nA/D troca tela aqui | Q volta ao menu." % [overlay.to_upper(), _panel_text_for_overlay(overlay)]
	var account_status := "logado" if account.logged_in else "sem login"
	return "SALA DO CONSELHO\n\n%s\n\nConta: %s\nPersonagem: %s (%s), %s de %s\nBuild: %s\n\nCada tela tem uma runa propria, mas todas seguem o mesmo tema: floresta, espada, divino e ruina." % [
		_menu_lines(main_menu_options, main_menu_index),
		account_status,
		character_profile.name,
		character_profile.type,
		character_profile.class,
		character_profile.origin,
		BUILD_VERSION
	]


func _panel_text_for_overlay(name: String) -> String:
	match name:
		"inventory":
			return _inventory_panel_text()
		"equipment":
			return _equipment_panel_text()
		"character":
			return _character_panel_text()
		"quests":
			return _quests_panel_text()
		"map":
			return _map_panel_text()
		"forge":
			return _forge_panel_text()
		"shop":
			return _shop_panel_text()
		"settings":
			return _settings_panel_text()
		"codex":
			return _codex_panel_text()
		"direction":
			return _direction_panel_text()
		"database":
			return _database_panel_text()
	return "Sistema nao selecionado."


func _menu_lines(options: Array, selected_index: int) -> String:
	var lines: Array[String] = []
	for i in range(options.size()):
		lines.append(("%s %s" % [">" if i == selected_index else " ", options[i]]))
	return "\n".join(lines)


func _mask_text(value: String) -> String:
	if value.is_empty():
		return "_"
	return "*".repeat(value.length())


func _inventory_panel_text() -> String:
	var lines := ["INVENTARIO", "", "Moedas de Gradon: %d" % int(player.coins), "Funcao: materiais, consumiveis, armas, ferramentas e itens de missao.", ""]
	var rows: Array[String] = _inventory_rows()
	if rows.is_empty():
		lines.append("Inventario vazio.")
	else:
		inventory_index = clampi(inventory_index, 0, rows.size() - 1)
		for i in range(rows.size()):
			var key := rows[i]
			lines.append("%s %s: %s" % [">" if i == inventory_index else " ", key, player.inventory[key]])
	lines.append("")
	lines.append("Ganhe moedas derrotando inimigos, vendendo itens ou achando tesouros.")
	lines.append("W/S escolhe | E usa consumivel | Materiais vao para Forja ou Mercado.")
	return "\n".join(lines)


func _equipment_panel_text() -> String:
	var rows: Array[String] = _equipment_rows()
	equipment_index = clampi(equipment_index, 0, rows.size() - 1)
	var lines := ["ARSENAL", "", "Arma: %s Nv.%d" % [player.equipment.weapon, int(player.weapon_levels.get(player.equipment.weapon, 1))], "Ferramenta: %s Nv.%d" % [player.equipment.tool, int(player.tool_levels.get(player.equipment.tool, 1))], "Armadura: %s" % player.equipment.armor, ""]
	for i in range(rows.size()):
		var name := rows[i]
		var marker := ">" if i == equipment_index else " "
		var kind := "arma" if weapon_catalog.has(name) else "ferramenta"
		var level := int(player.weapon_levels.get(name, player.tool_levels.get(name, 1)))
		lines.append("%s %s Nv.%d (%s)" % [marker, name, level, kind])
	lines.append("")
	lines.append("W/S escolhe | E equipa | F abre Forja | A/D troca aba")
	return "\n".join(lines)


func _character_panel_text() -> String:
	var rows: Array[String] = _progression_rows()
	progression_index = clampi(progression_index, 0, rows.size() - 1)
	var lines := ["PERSONAGEM", "", "Nome: %s | %s de %s" % [character_profile.name, character_profile.class, character_profile.origin], "Base: %s" % character_profile.type, "Vida: %d/%d | Stamina: %d | Coragem: %d | Lealdade: %d" % [player.hp, player.max_hp, int(player.stamina), int(player.courage), player.loyalty], "Pontos de habilidade: %d | Pontos de instinto: %d" % [int(player.skill_points), int(player.instinct_points)], ""]
	for i in range(rows.size()):
		var row := rows[i]
		var parts := row.split(":")
		var kind := String(parts[0])
		var name := String(parts[1])
		var value := int(player.skills.get(name, 0)) if kind == "skill" else int(player.instincts.get(name, 0))
		var label := "Habilidade" if kind == "skill" else "Instinto"
		lines.append("%s %s - %s Nv.%d/5" % [">" if i == progression_index else " ", label, name, value])
	lines.append("")
	lines.append("E melhora selecionado. Habilidades: combate/defesa. Instintos: recompensas/sobrevivencia/Marca.")
	return "\n".join(lines)


func _quests_panel_text() -> String:
	var current: Dictionary = maps[map_index]
	var living := enemies.filter(func(e): return not e.dead).size()
	return "MISSOES\n\nPrincipal: Sobreviver ao prologo da Floresta Wood.\nObjetivo atual: %s\nInimigos restantes: %d\n\nGanchos de historia:\n- Salvar companheiro aumenta lealdade.\n- Investigar cadaveres revela a origem da Marca Divina.\n- Chegar a Gradon abre Conselho, Forja e intriga politica.\n\nGanchos de jogabilidade:\n- Canis Ferox ensina esquiva.\n- Barbaro pesado ensina ataque carregado.\n- Ogre ensina pulo, bloqueio e leitura de telegraph." % [current.goal, living]


func _map_panel_text() -> String:
	var lines := ["MAPA", ""]
	for i in range(maps.size()):
		lines.append("%s %s" % [">" if i == map_index else " ", maps[i].title])
	lines.append("  Gradon")
	lines.append("")
	lines.append("Funcoes: teleporte por checkpoint, limites de camera, saidas entre areas.")
	return "\n".join(lines)


func _forge_panel_text() -> String:
	forge_index = clampi(forge_index, 0, forge_recipes.size() - 1)
	var lines := ["FORJA", "", "Ferreiro: Robert Smith | Moedas: %d" % int(player.coins), "E cria receita | Q melhora arma equipada", ""]
	for i in range(forge_recipes.size()):
		var recipe: Dictionary = forge_recipes[i]
		var marker := ">" if i == forge_index else " "
		lines.append("%s %s (%s) - %d moedas + %s" % [marker, recipe.name, recipe.kind, int(recipe.coins), _cost_text(recipe.cost)])
	lines.append("")
	lines.append("Melhoria equipada: aumenta dano/utilidade ate nivel 5.")
	return "\n".join(lines)


func _shop_panel_text() -> String:
	shop_index = clampi(shop_index, 0, shop_items.size() - 1)
	var lines := ["MERCADO DE GRADON", "", "Moedas: %d" % int(player.coins), "E compra | Q vende | Tudo e moeda interna do jogo", ""]
	for i in range(shop_items.size()):
		var item: Dictionary = shop_items[i]
		var owned := int(player.inventory.get(item.name, 0))
		lines.append("%s %s | compra %d | vende %d | seu: %d" % [">" if i == shop_index else " ", item.name, int(item.price), int(item.sell), owned])
	lines.append("")
	lines.append("Use venda para limpar inventario e comprar materiais para novas armas/ferramentas.")
	return "\n".join(lines)


func _cost_text(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for key in cost.keys():
		parts.append("%s x%d" % [key, int(cost[key])])
	return ", ".join(parts)


func _settings_panel_text() -> String:
	var rows: Array[String] = _settings_rows()
	settings_index = clampi(settings_index, 0, rows.size() - 1)
	var profile: Dictionary = _quality_profile()
	var labels := {
		"quality_profile": "Preset de hardware",
		"resolution_scale": "Escala de resolucao",
		"target_fps": "Limite de FPS",
		"ui_text_size": "Tamanho do texto",
		"high_contrast": "Alto contraste",
		"screen_shake": "Impacto de camera",
		"particles_enabled": "Particulas",
		"animated_background": "Cenario animado"
	}
	var lines := ["CONFIGURACOES", ""]
	lines.append("Perfil: %s" % profile.description)
	lines.append("Use W/S para escolher e A/D para alterar.")
	lines.append("")
	for i in range(rows.size()):
		var key: String = rows[i]
		var marker := ">" if i == settings_index else " "
		lines.append("%s %s: %s" % [marker, labels[key], _setting_value_text(key)])
	lines.append("")
	lines.append("E - salvar no banco local | P/Esc - voltar")
	return "\n".join(lines)


func _setting_value_text(key: String) -> String:
	match key:
		"quality_profile":
			return String(game_settings.quality_profile)
		"resolution_scale":
			return "%d%%" % int(game_settings.resolution_scale)
		"target_fps":
			return "%d FPS" % int(game_settings.target_fps)
		"ui_text_size":
			return "%d px" % int(game_settings.ui_text_size)
		"high_contrast", "screen_shake", "particles_enabled", "animated_background":
			return "ligado" if bool(game_settings[key]) else "desligado"
	return "-"


func _codex_panel_text() -> String:
	var lines := ["CODEX / LORE + MODELAGEM", ""]
	lines.append("W/S navega pelas entradas do mundo.")
	var lore_keys: Array = world_lore.keys()
	if not lore_keys.is_empty():
		codex_index = clampi(codex_index, 0, lore_keys.size() - 1)
		var start: int = clampi(codex_index - 3, 0, max(0, lore_keys.size() - 8))
		var end: int = mini(lore_keys.size(), start + 8)
		for i in range(start, end):
			var key := String(lore_keys[i])
			lines.append("%s %s" % [">" if i == codex_index else " ", key])
		var selected_key := String(lore_keys[codex_index])
		lines.append("")
		lines.append("%s:" % selected_key)
		lines.append(String(world_lore[selected_key]))
	lines.append("")
	lines.append("Total de entradas: %d | Personagens modelados: %d" % [lore_keys.size(), character_type_options.size()])
	lines.append("Ato 2/3 ja registrado como lore: duques, Michael, Corvus, Umbrae, Mulier e Qui Decepti.")
	return "\n".join(lines)


func _direction_panel_text() -> String:
	var lines := ["DIRECAO / HISTORIA + GAMEPLAY", ""]
	lines.append("Melhorias de historia:")
	for item in story_improvements:
		lines.append("- " + item)
	lines.append("")
	lines.append("Melhorias de jogabilidade:")
	for item in gameplay_improvements:
		lines.append("- " + item)
	lines.append("")
	lines.append("Prioridade atual: transformar Floresta Wood em tutorial jogavel com escolhas de consequencia curta.")
	lines.append("Pesquisa aplicada: consequencias sem overscope, combate risco/recompensa, feedback visual e acessibilidade.")
	return "\n".join(lines)


func _database_panel_text() -> String:
	var user_count: int = db.users.keys().size()
	var event_count: int = db.events.size()
	var current: Dictionary = _current_user()
	var character_count: int = 0
	if current.has("characters"):
		character_count = current.characters.keys().size()
	var has_save: bool = current.has("save") and not Dictionary(current.save).is_empty()
	return "BANCO DE DADOS LOCAL\n\nArquivo: user://aesdivinus_db.json\nUsuarios: %d\nUsuario atual: %s\nPersonagens do usuario: %d\nSave atual: %s\nEventos registrados: %d\n\nSalva: cadastro, login, personagem, inventario, moedas, arsenal, niveis, habilidades, instintos, mercado, forja, mapa, checkpoint, configuracoes e acoes importantes.\n\nAtalho: B" % [
		user_count,
		account.email,
		character_count,
		"sim" if has_save else "nao",
		event_count
	]


func _draw() -> void:
	_draw_background()
	if not game_started:
		_draw_frontend_stage()
		_draw_overlays()
		_draw_title_logo()
		return
	_draw_world()
	_draw_player()
	_draw_overlays()


func _draw_background() -> void:
	var profile: Dictionary = _quality_profile()
	var load_factor := _graphics_load_factor()
	var motion := 1.0 if bool(game_settings.animated_background) else 0.0
	var contrast := bool(game_settings.high_contrast)
	var sky: Color = [Color("#121519"), Color("#161b1e"), Color("#100f14")][map_index]
	if contrast:
		sky = sky.darkened(0.22)
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), sky)
	var mark_x := 1060 - camera_x * 0.04 * motion
	draw_circle(Vector2(mark_x, 92), 44, Color("#d8b45a", 0.22 if contrast else 0.16))
	draw_arc(Vector2(mark_x, 92), 50, 0, TAU, 64, Color("#6ee7cf", 0.34 if contrast else 0.25), 2)
	for i in range(0, max(4, int(round(float(profile.stars) * load_factor)))):
		var sx := fmod(i * 97.0 - camera_x * 0.08 * motion, 1280.0)
		var sy := 34 + (i * 37) % 190
		draw_rect(Rect2(sx, sy, 2, 2), Color("#f6e7b1", 0.45 + 0.07 * (i % 3) if contrast else 0.25 + 0.05 * (i % 3)))
	var hill_offset := -fmod(camera_x * 0.18 * motion, 320)
	for i in range(-1, max(1, int(round(float(profile.hills) * load_factor)))):
		var hx := hill_offset + i * 320
		draw_polygon(PackedVector2Array([Vector2(hx - 80, 560), Vector2(hx + 120, 300), Vector2(hx + 360, 560)]), PackedColorArray([Color("#203b2e") if contrast else Color("#1b2b25")]))
	var ruin_offset := -fmod(camera_x * 0.35 * motion, 520)
	for i in range(-1, max(1, int(round(float(profile.ruins) * load_factor)))):
		var rx := ruin_offset + i * 520 + 120
		draw_rect(Rect2(rx, 360, 38, 200), Color("#3d413b") if contrast else Color("#2d302d"))
		draw_rect(Rect2(rx + 52, 410, 30, 150), Color("#303831") if contrast else Color("#252a27"))
		draw_line(Vector2(rx - 12, 360), Vector2(rx + 72, 335), Color("#5b5d50") if contrast else Color("#3a3b34"), 7)
	var tree_offset := -fmod(camera_x * 0.55 * motion, 180)
	for i in range(-1, max(3, int(round(float(profile.trees) * load_factor)))):
		var x2 := tree_offset + i * 180
		var tree_color := Color("#31523d") if contrast else Color("#26372d")
		if map_index == 1:
			tree_color = Color("#4a382f") if contrast else Color("#342d2a")
		draw_polygon(PackedVector2Array([Vector2(x2, 560), Vector2(x2 + 80, 255), Vector2(x2 + 160, 560)]), PackedColorArray([tree_color]))
		draw_rect(Rect2(x2 + 73, 390, 14, 170), Color("#231f19"))
	if map_index == 1:
		for i in range(0, max(1, int(round(float(profile.fires) * load_factor)))):
			var fx := fmod(i * 210.0 - camera_x * 0.65 * motion, 1380.0) - 50
			draw_rect(Rect2(fx, FLOOR_Y - 26, 18, 26), Color("#7d3025"))
			draw_polygon(PackedVector2Array([Vector2(fx - 6, FLOOR_Y - 26), Vector2(fx + 9, FLOOR_Y - 62), Vector2(fx + 24, FLOOR_Y - 26)]), PackedColorArray([Color("#ffd66d", 0.88) if contrast else Color("#d8b45a", 0.72)]))
	elif map_index == 2:
		for i in range(0, max(1, int(round(float(profile.debris) * load_factor)))):
			var bx := fmod(i * 240.0 - camera_x * 0.75 * motion, 1400.0) - 80
			draw_line(Vector2(bx, FLOOR_Y - 15), Vector2(bx + 56, FLOOR_Y - 58), Color("#4b3a2a"), 5)
			draw_rect(Rect2(bx + 45, FLOOR_Y - 76, 14, 24), Color("#5d5d64"))
	draw_rect(Rect2(0, FLOOR_Y, 1280, 160), Color("#33271d") if contrast else Color("#28211c"))
	for i in range(0, 16):
		draw_rect(Rect2(i * 86 - fmod(camera_x, 86), FLOOR_Y + 8 + (i % 3) * 6, 34, 6), Color("#3a3024"))
	draw_rect(Rect2(0, FLOOR_Y, 1280, 8), Color("#8f6b28"))


func _draw_world() -> void:
	var exit_x := WORLD_W - camera_x - 100
	draw_rect(Rect2(exit_x, FLOOR_Y - 110, 55, 110), Color("#3d3428"))
	draw_rect(Rect2(exit_x + 14, FLOOR_Y - 90, 27, 90), Color("#0f1112"))
	for item in items:
		if item.taken:
			continue
		var p: Vector2 = item.pos - Vector2(camera_x, 0)
		draw_rect(Rect2(p.x - 10, p.y - 18, 20, 18), Color("#d8b45a"))
		draw_rect(Rect2(p.x - 5, p.y - 27, 10, 9), Color("#75d8c5"))
	for npc in npcs:
		_draw_character_model(npc.name, npc.pos - Vector2(camera_x, 0), 1)
		_draw_name(npc.name, npc.pos - Vector2(camera_x, 82))
	for enemy in enemies:
		if enemy.dead:
			continue
		var color := Color("#8f3f38")
		if enemy.type == "canis":
			color = Color("#5f6654")
		elif enemy.type == "servi":
			color = Color("#6b655a")
		elif enemy.type == "ignis":
			color = Color("#9b4a24")
		elif enemy.type == "boss":
			color = Color("#704b32")
		var scale := 1.0 if enemy.type != "boss" else 2.0
		_draw_humanoid(enemy.pos - Vector2(camera_x, 0), color, Color("#bca17e"), enemy.dir, scale)
		_draw_enemy_bar(enemy)
	for p in particles:
		draw_rect(Rect2(p.pos.x - camera_x, p.pos.y, 4, 4), p.color)
	for text in floating_text:
		draw_string(ThemeDB.fallback_font, text.pos - Vector2(camera_x, 0), text.value, HORIZONTAL_ALIGNMENT_CENTER, 80, 18, text.color)


func _draw_player() -> void:
	var p: Vector2 = player.pos - Vector2(camera_x, 0)
	_draw_character_model(character_profile.get("type", "William"), p, player.facing, 1.0, player.state)
	_draw_character_weapon(p, player.facing, 1.0, _equipped_weapon_visual_type(), player.state)
	if player.state == "BLOCK":
		draw_rect(Rect2(p.x + player.facing * 24 - 8, p.y - 50, 16, 36), Color("#8e7749"))
	if player.charge > 0:
		draw_arc(p + Vector2(0, -45), 34, 0, TAU * minf(1, player.charge / 1.5), 18, Color("#6ee7cf"), 4)


func _draw_character_model(model_name: String, p: Vector2, facing: int, scale := 1.0, state := "IDLE") -> void:
	var model: Dictionary = character_models.get(model_name, character_models["William"])
	var body := Color(model.body)
	if state == "BLOCK":
		body = Color(model.secondary).lightened(0.15)
	elif state in ["ATTACK", "HEAVY_ATTACK", "AIR_ATTACK", "SPECIAL"]:
		body = Color(model.body).lightened(0.14)
	elif state == "HURT":
		body = Color("#b74747")
	_draw_humanoid(p, body, Color(model.skin), facing, scale)
	_draw_character_details(p, facing, scale, model)
	_draw_character_weapon(p, facing, scale, model.weapon, state)


func _draw_character_details(p: Vector2, facing: int, scale: float, model: Dictionary) -> void:
	var w := PLAYER_SIZE.x * scale
	var h := PLAYER_SIZE.y * scale
	var secondary := Color(model.secondary)
	var hair := Color(model.hair)
	var detail := Color(model.detail)
	var silhouette := String(model.silhouette)
	draw_rect(Rect2(p.x - w * 0.26, p.y - h - 26 * scale, w * 0.52, 9 * scale), hair)
	draw_rect(Rect2(p.x - w * 0.30, p.y - h - 18 * scale, w * 0.18, 13 * scale), hair)
	draw_rect(Rect2(p.x - w * 0.38, p.y - h * 0.84, w * 0.76, 7 * scale), secondary)
	draw_rect(Rect2(p.x - w * 0.18, p.y - h * 0.72, w * 0.36, 5 * scale), detail)
	if silhouette == "knight":
		draw_rect(Rect2(p.x - w * 0.48, p.y - h * 0.88, w * 0.22, 18 * scale), secondary)
		draw_rect(Rect2(p.x + w * 0.26, p.y - h * 0.88, w * 0.22, 18 * scale), secondary)
	elif silhouette == "scout":
		draw_rect(Rect2(p.x - w * 0.50, p.y - h * 0.72, w * 0.22, 22 * scale), detail.darkened(0.2))
		draw_line(p + Vector2(-facing * 18, -34) * scale, p + Vector2(-facing * 40, -54) * scale, detail, 3 * scale)
	elif silhouette == "heavy":
		draw_rect(Rect2(p.x - w * 0.55, p.y - h * 0.92, w * 0.30, 24 * scale), secondary)
		draw_rect(Rect2(p.x + w * 0.25, p.y - h * 0.92, w * 0.30, 24 * scale), secondary)
		draw_rect(Rect2(p.x - w * 0.42, p.y - h * 0.56, w * 0.84, 8 * scale), detail)
	elif silhouette == "noble":
		draw_rect(Rect2(p.x - w * 0.44, p.y - h * 0.58, w * 0.88, 28 * scale), secondary)
		draw_rect(Rect2(p.x - w * 0.20, p.y - h - 31 * scale, w * 0.40, 5 * scale), detail)
	elif silhouette == "agile":
		draw_rect(Rect2(p.x - w * 0.18, p.y - h - 22 * scale, w * 0.16, 34 * scale), hair)
		draw_rect(Rect2(p.x + w * 0.18, p.y - h * 0.50, w * 0.18, 25 * scale), detail.darkened(0.1))
	elif silhouette == "mystic":
		draw_rect(Rect2(p.x - w * 0.42, p.y - h * 0.56, w * 0.84, 34 * scale), secondary)
		draw_rect(Rect2(p.x - 3 * scale, p.y - h * 0.96, 6 * scale, 6 * scale), detail)


func _draw_character_weapon(p: Vector2, facing: int, scale: float, weapon: String, state: String) -> void:
	var active := state in ["ATTACK", "HEAVY_ATTACK", "AIR_ATTACK"]
	var reach := 72 if active else 42
	var color := Color("#d8d8cc")
	match weapon:
		"sword":
			draw_line(p + Vector2(facing * 22, -35) * scale, p + Vector2(facing * reach, -45) * scale, color, 5 * scale)
		"short_sword":
			draw_line(p + Vector2(facing * 20, -34) * scale, p + Vector2(facing * 52, -42) * scale, color, 4 * scale)
		"axe":
			var end := p + Vector2(facing * 56, -46) * scale
			draw_line(p + Vector2(facing * 18, -30) * scale, end, Color("#8b6b45"), 5 * scale)
			draw_rect(Rect2(end.x - 6 * scale, end.y - 9 * scale, 12 * scale, 13 * scale), color)
		"rapier":
			draw_line(p + Vector2(facing * 18, -36) * scale, p + Vector2(facing * 82, -39) * scale, color, 2 * scale)
			draw_rect(Rect2(p.x + facing * 16 * scale - 3 * scale, p.y - 39 * scale, 8 * scale, 8 * scale), Color("#e8d98b"))
		"spear":
			draw_line(p + Vector2(facing * 16, -28) * scale, p + Vector2(facing * 92, -58) * scale, Color("#8b6b45"), 4 * scale)
			draw_rect(Rect2(p.x + facing * 92 * scale - 4 * scale, p.y - 62 * scale, 8 * scale, 8 * scale), color)
		"staff":
			draw_line(p + Vector2(facing * 18, -18) * scale, p + Vector2(facing * 44, -70) * scale, Color("#8b6b45"), 4 * scale)
			draw_rect(Rect2(p.x + facing * 44 * scale - 5 * scale, p.y - 76 * scale, 10 * scale, 10 * scale), Color("#6ee7cf"))


func _equipped_weapon_visual_type() -> String:
	var weapon_name := String(player.equipment.get("weapon", "Espada de Gradon"))
	var weapon_data: Dictionary = weapon_catalog.get(weapon_name, weapon_catalog["Espada de Gradon"])
	return String(weapon_data.get("type", "sword"))


func _draw_humanoid(p: Vector2, body: Color, skin: Color, facing: int, scale := 1.0) -> void:
	var w := PLAYER_SIZE.x * scale
	var h := PLAYER_SIZE.y * scale
	draw_rect(Rect2(p.x - w * 0.36, p.y - h, w * 0.72, h * 0.64), body)
	draw_rect(Rect2(p.x - w * 0.24, p.y - h - 20 * scale, w * 0.48, 20 * scale), skin)
	draw_rect(Rect2(p.x + facing * w * 0.12, p.y - h - 14 * scale, 5 * scale, 5 * scale), Color("#14100d"))
	draw_rect(Rect2(p.x - w * 0.32, p.y - h * 0.36, w * 0.22, h * 0.36), Color("#181716"))
	draw_rect(Rect2(p.x + w * 0.10, p.y - h * 0.36, w * 0.22, h * 0.36), Color("#181716"))


func _draw_enemy_bar(enemy: Dictionary) -> void:
	var p: Vector2 = enemy.pos - Vector2(camera_x, 0)
	var width := 58.0 if enemy.type != "boss" else 180.0
	draw_rect(Rect2(p.x - width / 2, p.y - 92, width, 6), Color("#201d19"))
	draw_rect(Rect2(p.x - width / 2, p.y - 92, width * maxf(enemy.hp, 0) / enemy.max_hp, 6), Color("#b53c3c"))
	if enemy.type == "boss":
		draw_string(ThemeDB.fallback_font, Vector2(485, 40), enemy.name, HORIZONTAL_ALIGNMENT_CENTER, 310, 24, Color("#ead7a1"))


func _draw_name(value: String, p: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, p, value, HORIZONTAL_ALIGNMENT_CENTER, 120, 18, Color("#e8ddc0"))


func _draw_overlays() -> void:
	if paused or game_over or victory or not game_started:
		draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0, 0, 0, 0.35))
	if paused or victory or not game_started:
		_draw_screen_panel(Rect2(772, 14, 492, 272), overlay if game_started else auth_screen)
	if boss_mode:
		draw_rect(Rect2(420, 62, 440, 12), Color("#201d19"))
		var boss := enemies.filter(func(e): return e.type == "boss" and not e.dead)
		if not boss.is_empty():
			draw_rect(Rect2(420, 62, 440 * boss[0].hp / boss[0].max_hp, 12), Color("#9b2d2d"))
	if transition_timer > 0:
		_draw_transition()
	_draw_touch_controls()


func _draw_touch_controls() -> void:
	if not _is_touch_build():
		return
	for button in _touch_buttons():
		var rect: Rect2 = button.rect
		var action := String(button.action)
		var pressed := Input.is_action_pressed(action)
		var color := Color("#d8b45a", 0.34 if pressed else 0.20)
		var border := Color("#f6e7b1", 0.82 if pressed else 0.48)
		draw_rect(rect, Color("#050605", 0.48))
		draw_rect(rect, color)
		draw_rect(rect, border, false, 2)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.62), String(button.label), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 18, Color("#f6e7b1"))


func _draw_frontend_stage() -> void:
	var t := frontend_time
	var intro := clampf(intro_timer / intro_duration, 0.0, 1.0)
	var reveal := _ease_out_cubic(intro)
	var accent := _screen_accent(auth_screen)
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#060807", 0.22))
	draw_rect(Rect2(0, 0, 1280, 720), Color(accent.r, accent.g, accent.b, 0.05 + 0.05 * sin(t * 0.9)))
	var moon := Vector2(1030, 116)
	draw_circle(moon, 58 + sin(t * 0.55) * 2.0, Color("#d8b45a", 0.15))
	draw_arc(moon, 68, 0, TAU, 72, Color("#6ee7cf", 0.18), 2)
	for i in range(10):
		var y := 272 + i * 28
		var x := fmod(i * 173.0 - t * (10.0 + i * 0.6), 1440.0) - 80
		draw_rect(Rect2(x, y, 160 + i * 8, 5), Color("#d8d8cc", 0.035 + 0.004 * i))
	for i in range(5):
		var x2 := 92 + i * 116
		var top := 240 + sin(t * 0.7 + i) * 8
		draw_line(Vector2(x2, 638), Vector2(x2, top), Color("#30241b"), 6)
		draw_polygon(PackedVector2Array([Vector2(x2 + 3, top), Vector2(x2 + 74, top + 18), Vector2(x2 + 3, top + 42)]), PackedColorArray([accent.darkened(0.35)]))
		draw_line(Vector2(x2 + 16, top + 17), Vector2(x2 + 55, top + 28), Color("#d8b45a", 0.5), 2)
	var gate_x := lerpf(-280.0, 0.0, reveal)
	draw_rect(Rect2(gate_x, 306, 176, 288), Color("#17120e"))
	draw_rect(Rect2(gate_x + 48, 366, 80, 228), Color("#080908"))
	draw_arc(Vector2(gate_x + 88, 366), 40, PI, TAU, 28, Color("#473923"), 5)
	var hero_pos := Vector2(348, 594)
	_draw_character_model(character_profile.get("type", "William"), hero_pos, 1, 1.05, "IDLE")
	draw_line(hero_pos + Vector2(31, -50), hero_pos + Vector2(96, -93), Color("#d8d8cc", 0.78), 5)
	var pulse := 1.0 + sin(t * 2.2) * 0.07
	_draw_divine_star(Vector2(232, 132), 36 * pulse)
	draw_arc(Vector2(232, 132), 76 + sin(t) * 8, 0, TAU, 56, Color("#6ee7cf", 0.18), 2)
	_draw_screen_path_runes(auth_screen, accent)
	if intro < 0.96:
		var veil := 1.0 - _ease_out_cubic(clampf(intro * 1.22, 0.0, 1.0))
		draw_rect(Rect2(0, 0, 1280, 720), Color("#050403", veil * 0.76))


func _draw_screen_path_runes(screen_name: String, accent: Color) -> void:
	var names: Array[String] = ["login", "register", "character_create", "main_menu", "systems"]
	var selected: int = max(0, names.find(screen_name))
	var start := Vector2(770, 330)
	for i in range(names.size()):
		var p := start + Vector2(i * 76, 0)
		var active: bool = i <= selected
		draw_line(p + Vector2(-32, 0), p + Vector2(32, 0), Color("#5b4a2c", 0.35), 2)
		if active:
			_draw_divine_star(p, 8 + i)
		else:
			draw_circle(p, 6, Color("#3b3429", 0.8))
		if i == selected:
			draw_arc(p, 20 + sin(frontend_time * 2.4) * 2, 0, TAU, 28, accent, 2)


func _draw_screen_panel(rect: Rect2, screen_name: String) -> void:
	var accent := _screen_accent(screen_name)
	var paper := _screen_paper_color(screen_name)
	draw_rect(rect, paper)
	draw_rect(rect, accent.darkened(0.45), false, 3)
	draw_rect(Rect2(rect.position + Vector2(8, 8), rect.size - Vector2(16, 16)), accent, false, 1)
	draw_rect(Rect2(rect.position + Vector2(14, 14), Vector2(rect.size.x - 28, 32)), accent.darkened(0.55), true)
	draw_line(rect.position + Vector2(18, rect.size.y - 10), rect.position + Vector2(rect.size.x - 18, rect.size.y - 10), accent, 2)
	for i in range(4):
		var corner: Vector2 = [
			rect.position + Vector2(12, 12),
			rect.position + Vector2(rect.size.x - 28, 12),
			rect.position + Vector2(12, rect.size.y - 28),
			rect.position + rect.size - Vector2(28, 28)
		][i]
		_draw_divine_star(corner + Vector2(8, 8), 8)
	_draw_screen_sigil(rect, screen_name, accent)


func _screen_paper_color(screen_name: String) -> Color:
	var alpha := 0.84
	match screen_name:
		"login":
			return Color("#101612", alpha)
		"register":
			return Color("#15110d", alpha)
		"character_create":
			return Color("#0d1719", alpha)
		"main_menu":
			return Color("#17130d", alpha)
		"systems":
			return Color("#0c1515", alpha)
		"settings":
			return Color("#0d1319", alpha)
		"forge":
			return Color("#1a100b", alpha)
	return Color("#11130f", alpha)


func _draw_screen_sigil(rect: Rect2, screen_name: String, accent: Color) -> void:
	var base := rect.position + Vector2(rect.size.x - 58, 58)
	match screen_name:
		"login":
			draw_rect(Rect2(base.x - 16, base.y - 22, 32, 44), accent, false, 3)
			draw_arc(base + Vector2(0, -22), 18, PI, TAU, 24, accent, 3)
			draw_circle(base, 4, accent)
		"register":
			draw_line(base + Vector2(-22, 18), base + Vector2(20, -18), accent, 4)
			draw_line(base + Vector2(-18, -10), base + Vector2(18, 22), accent.darkened(0.1), 3)
			_draw_divine_star(base + Vector2(20, -20), 7)
		"character_create":
			_draw_humanoid(base + Vector2(0, 24), accent.darkened(0.25), Color("#d2b48c"), 1, 0.72)
			draw_arc(base + Vector2(0, 0), 34, 0, TAU, 36, accent, 2)
		"main_menu":
			draw_polygon(PackedVector2Array([base + Vector2(0, -34), base + Vector2(28, -8), base + Vector2(18, 28), base + Vector2(-18, 28), base + Vector2(-28, -8)]), PackedColorArray([accent.darkened(0.55)]))
			draw_polygon(PackedVector2Array([base + Vector2(0, -26), base + Vector2(18, -6), base + Vector2(11, 18), base + Vector2(-11, 18), base + Vector2(-18, -6)]), PackedColorArray([accent]))
		"systems":
			for i in range(3):
				draw_rect(Rect2(base.x - 26 + i * 18, base.y - 22 + i * 5, 32, 44), Color(accent.r, accent.g, accent.b, 0.28), false, 2)
			_draw_divine_star(base + Vector2(10, 10), 9)
		"settings":
			for i in range(3):
				var y := base.y - 20 + i * 18
				draw_line(Vector2(base.x - 28, y), Vector2(base.x + 26, y), accent, 3)
				draw_circle(Vector2(base.x - 8 + i * 14, y), 6, accent.darkened(0.25))
		"forge":
			draw_line(base + Vector2(-24, 24), base + Vector2(22, -20), accent, 5)
			draw_line(base + Vector2(-18, -18), base + Vector2(24, 24), accent.darkened(0.25), 4)
		"shop":
			draw_circle(base + Vector2(-12, 0), 13, Color("#d8b45a"))
			draw_circle(base + Vector2(12, 0), 13, Color("#9b7c43"))
			draw_rect(Rect2(base.x - 28, base.y + 18, 56, 8), accent.darkened(0.25))
		_:
			_draw_divine_star(base, 18)


func _screen_accent(screen_name: String) -> Color:
	var accents := {
		"login": Color("#d8b45a"),
		"register": Color("#9b7c43"),
		"character_create": Color("#6ee7cf"),
		"main_menu": Color("#f6e7b1"),
		"systems": Color("#76d9c8"),
		"inventory": Color("#d8b45a"),
		"equipment": Color("#d8d8cc"),
		"character": Color("#6ee7cf"),
		"quests": Color("#b74747"),
		"map": Color("#76d9c8"),
		"forge": Color("#d86d3f"),
		"shop": Color("#d8b45a"),
		"settings": Color("#9fd6ff"),
		"codex": Color("#e8d98b"),
		"direction": Color("#d96d8b"),
		"database": Color("#76d9c8"),
		"pause": Color("#d8b45a")
	}
	return accents.get(screen_name, Color("#d8b45a"))


func _ease_out_cubic(value: float) -> float:
	var x := clampf(value, 0.0, 1.0)
	return 1.0 - pow(1.0 - x, 3.0)


func _draw_transition() -> void:
	var raw := clampf(transition_timer / maxf(0.1, transition_duration), 0.0, 1.0)
	var alpha := _ease_out_cubic(raw)
	var accent := _screen_accent(transition_to)
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#090807", alpha * 0.62))
	if not bool(_quality_profile().transition_fx):
		draw_string(ThemeDB.fallback_font, Vector2(430, 480), transition_title, HORIZONTAL_ALIGNMENT_CENTER, 420, 28, Color("#f6e7b1", alpha))
		return
	var center := Vector2(640, 360)
	var sweep := 1.0 - raw
	var left := -160 + sweep * 520
	var right := 1280 - sweep * 520
	draw_polygon(PackedVector2Array([Vector2(left - 260, 0), Vector2(left, 0), Vector2(left + 170, 720), Vector2(left - 90, 720)]), PackedColorArray([Color("#17110b", alpha * 0.92)]))
	draw_polygon(PackedVector2Array([Vector2(right + 260, 0), Vector2(right, 0), Vector2(right - 170, 720), Vector2(right + 90, 720)]), PackedColorArray([Color("#0b1514", alpha * 0.92)]))
	draw_line(Vector2(left, 0), Vector2(left + 170, 720), accent, 3)
	draw_line(Vector2(right, 0), Vector2(right - 170, 720), accent.darkened(0.25), 3)
	_draw_divine_star(center, 48 + (1.0 - alpha) * 42)
	draw_arc(center, 92 + (1.0 - alpha) * 120, -PI * 0.25, TAU * sweep, 80, Color("#6ee7cf", alpha * 0.6), 4)
	draw_arc(center, 126 + (1.0 - alpha) * 150, PI * 0.65, TAU * sweep + PI, 80, Color("#d8b45a", alpha * 0.42), 3)
	draw_string(ThemeDB.fallback_font, center + Vector2(-210, 120), transition_title, HORIZONTAL_ALIGNMENT_CENTER, 420, 28, Color("#f6e7b1", alpha))
	draw_string(ThemeDB.fallback_font, center + Vector2(-210, 153), "%s  >  %s" % [_screen_display_name(transition_from), _screen_display_name(transition_to)], HORIZONTAL_ALIGNMENT_CENTER, 420, 15, Color("#76d9c8", alpha * 0.82))


func _draw_title_logo() -> void:
	var reveal := _ease_out_cubic(clampf(intro_timer / 2.2, 0.0, 1.0))
	var alpha := clampf(reveal, 0.0, 1.0)
	var center := Vector2(210, 145 + (1.0 - reveal) * 18.0)
	var accent := _screen_accent(auth_screen)
	draw_rect(Rect2(276, 119, 392 * reveal, 3), Color("#d8b45a", alpha * 0.7))
	draw_rect(Rect2(296, 190, 344 * reveal, 2), Color("#6ee7cf", alpha * 0.5))
	_draw_divine_star(center, 50 + sin(frontend_time * 2.0) * 2)
	draw_line(center + Vector2(0, -30), center + Vector2(0, 60), Color("#d8d8cc", alpha), 5)
	draw_line(center + Vector2(-28, 12), center + Vector2(28, 12), Color("#d8d8cc", alpha), 5)
	draw_arc(center, 72 + sin(frontend_time) * 5, 0, TAU, 56, Color(accent.r, accent.g, accent.b, alpha * 0.38), 2)
	draw_string(ThemeDB.fallback_font, Vector2(290, 132 + (1.0 - reveal) * 16.0), "AESDIVINUS", HORIZONTAL_ALIGNMENT_LEFT, 430, 54, Color("#f6e7b1", alpha))
	draw_string(ThemeDB.fallback_font, Vector2(296, 169 + (1.0 - reveal) * 12.0), "A COROA, A FLORESTA E A MARCA", HORIZONTAL_ALIGNMENT_LEFT, 390, 18, Color("#76d9c8", alpha))
	_draw_developer_brand(Vector2(518, 244), alpha, 0.46)
	draw_string(ThemeDB.fallback_font, Vector2(298, 214), _screen_display_name(auth_screen), HORIZONTAL_ALIGNMENT_LEFT, 340, 20, Color(accent.r, accent.g, accent.b, 0.9 * alpha))
	if intro_timer < intro_duration:
		var step := clampi(int(intro_timer), 0, 4)
		var lines := ["A floresta acorda.", "Gradon fecha seus portoes.", "A Marca encontra um herdeiro.", "Escolha sua origem.", "Entre no prologo."]
		draw_string(ThemeDB.fallback_font, Vector2(32, 620), lines[step], HORIZONTAL_ALIGNMENT_LEFT, 420, 20, Color("#f6e7b1", 0.72 * alpha))


func _draw_developer_brand(center: Vector2, alpha: float, scale: float = 1.0) -> void:
	var gold := Color("#d8b45a", alpha)
	var teal := Color("#6ee7cf", alpha * 0.82)
	var cream := Color("#f6e7b1", alpha)
	for side in [-1, 1]:
		var wing := PackedVector2Array([
			center + Vector2(14 * side, -8) * scale,
			center + Vector2(72 * side, -50) * scale,
			center + Vector2(118 * side, -38) * scale,
			center + Vector2(82 * side, -4) * scale,
			center + Vector2(116 * side, 26) * scale,
			center + Vector2(54 * side, 24) * scale,
			center + Vector2(20 * side, 8) * scale
		])
		draw_polygon(wing, PackedColorArray([Color("#0b5c63", alpha * 0.72)]))
		draw_polyline(wing, gold, 3.0 * scale, true)
		for i in range(3):
			var feather_start := center + Vector2((24 + i * 18) * side, -12 + i * 9) * scale
			var feather_end := center + Vector2((86 + i * 9) * side, -38 + i * 30) * scale
			draw_line(feather_start, feather_end, Color("#f6e7b1", alpha * 0.75), 2.0 * scale)
	_draw_divine_star(center, 18.0 * scale)
	draw_arc(center, 36.0 * scale, 0.0, TAU, 48, teal, 2.0 * scale)
	draw_string(ThemeDB.fallback_font, center + Vector2(-130, 48) * scale, DEVELOPER_NAME, HORIZONTAL_ALIGNMENT_CENTER, 260 * scale, int(19 * scale), cream)
	if scale >= 0.7:
		draw_string(ThemeDB.fallback_font, center + Vector2(-172, 76) * scale, DEVELOPER_MOTTO, HORIZONTAL_ALIGNMENT_CENTER, 344 * scale, int(13 * scale), Color("#76d9c8", alpha * 0.8))


func _draw_divine_star(center: Vector2, radius: float) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var r := radius if i % 2 == 0 else radius * 0.42
		var angle := -PI / 2 + i * PI / 5
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	draw_polygon(points, PackedColorArray([Color("#d8b45a")]))
	draw_arc(center, radius + 8, 0, TAU, 40, Color("#6ee7cf", 0.32), 3)
	draw_circle(center, radius * 0.26, Color("#11130f"))


func _spawn_spark(pos: Vector2, color: Color) -> void:
	if not bool(game_settings.particles_enabled):
		return
	var profile: Dictionary = _quality_profile()
	var count: int = max(1, int(round(8.0 * float(profile.particles) * _graphics_load_factor())))
	for i in range(count):
		particles.append({"pos": pos, "vel": Vector2(randf_range(-130, 130), randf_range(-150, 40)), "life": randf_range(0.18, 0.45), "color": color})


func _graphics_load_factor() -> float:
	return clampf(float(game_settings.get("resolution_scale", 100)) / 100.0, 0.5, 1.0)


func _float_text(pos: Vector2, value: String, color: Color) -> void:
	floating_text.append({"pos": pos, "value": value, "life": 0.75, "color": color})


func _show_banner(value: String) -> void:
	banner = value
	banner_timer = 4.0


func _reset_game() -> void:
	game_over = false
	victory = false
	if bool(character_profile.get("created", false)):
		_apply_character_template()
	else:
		player.max_hp = 120
		player.base_max_hp = 120
		player.stamina = 100
		player.courage = 100
		player.loyalty = 50
	player.hp = player.max_hp
	player.coins = 35
	player.skill_points = 1
	player.instinct_points = 1
	player.equipment = {"weapon": "Espada de Gradon", "tool": "Kit de Campanha", "armor": "Couro militar"}
	player.weapon_levels = {"Espada de Gradon": 1}
	player.tool_levels = {"Kit de Campanha": 1}
	player.skills = {"Forca": 0, "Defesa": 0, "Agilidade": 0, "Fe": 0, "Honra": 0}
	player.instincts = {"Sobrevivencia": 0, "Percepcao": 0, "Furia Controlada": 0, "Marca Divina": 0}
	player.inventory = {"Aes Divinus": 0, "Fragmento de Ferro": 0, "Relato Manchado": 0, "Racao": 1}
	checkpoint = {"map_index": 0, "pos_x": 120.0}
	_load_map(0)


func _respawn_at_checkpoint() -> void:
	game_over = false
	victory = false
	player.hp = player.max_hp
	player.stamina = 100
	player.courage = maxf(55, player.courage)
	_load_map(int(checkpoint.get("map_index", 0)))
	player.pos.x = float(checkpoint.get("pos_x", 120.0))
	player.pos.y = FLOOR_Y
	_record_action("respawn_checkpoint", checkpoint.duplicate(true))
	_save_game()
	_show_banner("Checkpoint recuperado.")


func _save_game() -> void:
	var save_data := {
		"version": BUILD_VERSION,
		"map_index": map_index,
		"checkpoint": checkpoint,
		"inventory": player.inventory,
		"coins": player.coins,
		"skill_points": player.skill_points,
		"instinct_points": player.instinct_points,
		"equipment": player.equipment,
		"weapon_levels": player.weapon_levels,
		"tool_levels": player.tool_levels,
		"skills": player.skills,
		"instincts": player.instincts,
		"loyalty": player.loyalty,
		"courage": player.courage,
		"victory": victory,
		"account": account,
		"character_profile": character_profile,
		"settings": game_settings,
		"player_max_hp": player.max_hp,
		"player_base_max_hp": player.base_max_hp,
		"player_hp": player.hp,
		"player_stamina": player.stamina,
		"player_position": {"x": player.pos.x, "y": player.pos.y}
	}
	var user := _current_user()
	user.settings = game_settings.duplicate(true)
	user.save = save_data
	db.users[current_user_id] = user
	_db_upsert_character()
	_db_save()


func _load_save() -> void:
	if current_user_id == "" or not db.users.has(current_user_id):
		_show_banner("Nenhum save encontrado.")
		return
	var user: Dictionary = db.users[current_user_id]
	var parsed: Dictionary = user.get("save", {})
	if user.has("settings") and typeof(user.settings) == TYPE_DICTIONARY:
		for key in game_settings.keys():
			if user.settings.has(key):
				game_settings[key] = user.settings[key]
	if parsed.is_empty():
		if FileAccess.file_exists(LEGACY_SAVE_PATH):
			var file := FileAccess.open(LEGACY_SAVE_PATH, FileAccess.READ)
			if file != null:
				var legacy_text := file.get_buffer(file.get_length()).get_string_from_utf8().strip_edges()
				if not legacy_text.is_empty():
					var legacy_json := JSON.new()
					if legacy_json.parse(legacy_text) == OK and typeof(legacy_json.data) == TYPE_DICTIONARY:
						parsed = legacy_json.data
		if parsed.is_empty():
			_show_banner("Nenhum save encontrado.")
			return
	if typeof(parsed) != TYPE_DICTIONARY:
		_show_banner("Save invalido no banco.")
		return
	map_index = clampi(int(parsed.get("map_index", 0)), 0, maps.size() - 1)
	checkpoint = parsed.get("checkpoint", {"map_index": map_index, "pos_x": 120.0})
	player.inventory = parsed.get("inventory", player.inventory)
	player.coins = int(parsed.get("coins", player.get("coins", 35)))
	player.skill_points = int(parsed.get("skill_points", player.get("skill_points", 0)))
	player.instinct_points = int(parsed.get("instinct_points", player.get("instinct_points", 0)))
	player.equipment = parsed.get("equipment", player.equipment)
	player.weapon_levels = parsed.get("weapon_levels", player.weapon_levels)
	player.tool_levels = parsed.get("tool_levels", player.tool_levels)
	player.skills = parsed.get("skills", player.skills)
	player.instincts = parsed.get("instincts", player.instincts)
	_normalize_player_runtime_data()
	player.loyalty = int(parsed.get("loyalty", player.loyalty))
	player.courage = float(parsed.get("courage", player.courage))
	victory = bool(parsed.get("victory", false))
	account = parsed.get("account", account)
	character_profile = parsed.get("character_profile", character_profile)
	if parsed.has("settings") and typeof(parsed.settings) == TYPE_DICTIONARY:
		for key in game_settings.keys():
			if parsed.settings.has(key):
				game_settings[key] = parsed.settings[key]
	_apply_runtime_settings()
	player.base_max_hp = int(parsed.get("player_base_max_hp", player.get("base_max_hp", player.max_hp)))
	player.max_hp = int(parsed.get("player_max_hp", player.max_hp))
	if bool(character_profile.get("created", false)):
		_sync_character_indices()
		_apply_character_template()
	player.max_hp = int(parsed.get("player_max_hp", player.max_hp))
	player.hp = mini(int(parsed.get("player_hp", player.max_hp)), player.max_hp)
	player.stamina = float(parsed.get("player_stamina", player.stamina))
	player.courage = float(parsed.get("courage", player.courage))
	player.loyalty = int(parsed.get("loyalty", player.loyalty))
	game_over = false
	_load_map(map_index)
	_normalize_player_runtime_data()
	var saved_pos: Dictionary = parsed.get("player_position", {})
	player.pos.x = float(saved_pos.get("x", checkpoint.get("pos_x", 120.0)))
	player.pos.y = float(saved_pos.get("y", FLOOR_Y))
	_record_action("save_loaded", {"map_index": map_index})
	_show_banner("Save carregado.")


func _run_smoke_test() -> void:
	account.name = "Teste"
	account.email = "teste@aesdivinus.local"
	register_password = "1234"
	login_password = "1234"
	var user_id := _make_user_id(account.email)
	if db.users.has(user_id):
		db.users.erase(user_id)
	assert(_register_user(account.name, account.email, register_password))
	assert(_login_user(account.email, login_password))
	character_profile.created = true
	character_profile.name = "Aurea Teste"
	character_profile.type = "Hilda"
	character_profile.class = "Marcado Divino"
	character_profile.origin = "Ordem Divina"
	_sync_character_indices()
	_apply_character_template()
	_db_upsert_character()
	game_started = true
	for screen in ["login", "register", "character_create", "main_menu", "systems"]:
		auth_screen = screen
		_update_ui()
	for screen in system_overlay_order:
		overlay = screen
		paused = true
		_update_ui()
	game_settings.quality_profile = "Baixo"
	game_settings.resolution_scale = 70
	game_settings.target_fps = 30
	game_settings.high_contrast = true
	game_settings.particles_enabled = false
	_apply_runtime_settings()
	player.coins = 250
	player.inventory["Fragmento de Ferro"] = 5
	player.inventory["Aes Divinus"] = 4
	player.inventory["Relato Manchado"] = 1
	forge_index = 0
	_craft_selected_recipe()
	assert(player.weapon_levels.has("Lamina de Ferro"))
	forge_index = 4
	_craft_selected_recipe()
	assert(player.weapon_levels.has("Espada Aes"))
	equipment_index = max(0, _equipment_rows().find("Lamina de Ferro"))
	player.equipment.weapon = "Espada Aes"
	assert(player.equipment.weapon == "Espada Aes")
	assert(_is_corrupted_enemy({"type": "ignis"}))
	player.skill_points = 1
	progression_index = 0
	_upgrade_progression(_progression_rows()[progression_index])
	assert(int(player.skills.get("Forca", 0)) >= 1)
	shop_index = 0
	_buy_selected_shop_item()
	assert(int(player.inventory.get("Racao", 0)) >= 1)
	assert(maps.size() == 3)
	for idx in range(maps.size()):
		_load_map(idx)
		_update_ui()
		assert(player.hp > 0)
		if not enemies.is_empty():
			_damage_enemy(enemies[0], 999, 1)
		_update_checkpoint()
		_update_particles(0.016)
	_update_ui()
	_save_game()
	game_settings.quality_profile = "Ultra"
	game_settings.resolution_scale = 100
	game_settings.target_fps = 144
	game_settings.high_contrast = false
	game_settings.particles_enabled = true
	_load_save()
	assert(game_settings.quality_profile == "Baixo")
	assert(int(game_settings.resolution_scale) == 70)
	assert(int(game_settings.target_fps) == 30)
	assert(bool(game_settings.high_contrast))
	assert(not bool(game_settings.particles_enabled))
	assert(db.users.has(current_user_id))
	assert(not Dictionary(db.users[current_user_id].save).is_empty())
	_respawn_at_checkpoint()
	_reset_game()
	get_tree().quit(0)
