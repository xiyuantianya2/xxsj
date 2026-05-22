extends Node

# 游戏管理器 - 全局游戏状态管理
class_name GameManager

signal game_started
signal game_paused
signal game_resumed
signal scene_changed

# 游戏状态
enum GameState {
	MENU,
	GAME,
	PAUSED,
	BATTLE,
	DIALOGUE
}

var current_state = GameState.MENU
var current_scene = null
var current_map = null

# 玩家数据
var player_data = {
	"name": "无名",
	"level": 1,
	"cultivation": 0,  # 修为
	"realm": 0,  # 境界索引
	"hp": 100,
	"max_hp": 100,
	"mp": 50,
	"max_mp": 50,
	"attack": 10,
	"defense": 5,
	"speed": 10,
	"inventory": [],
	"equipment": {},
	"skills": [],
	"quests": [],
	"flags": {}
}

# 境界系统
var realms = [
	{"name": "凡人", "min_cultivation": 0, "hp_bonus": 100, "mp_bonus": 50, "atk_bonus": 10, "def_bonus": 5},
	{"name": "炼气期", "min_cultivation": 100, "hp_bonus": 150, "mp_bonus": 80, "atk_bonus": 15, "def_bonus": 8},
	{"name": "筑基期", "min_cultivation": 500, "hp_bonus": 250, "mp_bonus": 150, "atk_bonus": 25, "def_bonus": 15},
	{"name": "金丹期", "min_cultivation": 2000, "hp_bonus": 500, "mp_bonus": 300, "atk_bonus": 50, "def_bonus": 30},
	{"name": "元婴期", "min_cultivation": 10000, "hp_bonus": 1000, "mp_bonus": 600, "atk_bonus": 100, "def_bonus": 60},
	{"name": "化神期", "min_cultivation": 50000, "hp_bonus": 2000, "mp_bonus": 1200, "atk_bonus": 200, "def_bonus": 120},
	{"name": "渡劫期", "min_cultivation": 200000, "hp_bonus": 5000, "mp_bonus": 3000, "atk_bonus": 500, "def_bonus": 300},
	{"name": "大乘期", "min_cultivation": 1000000, "hp_bonus": 10000, "mp_bonus": 6000, "atk_bonus": 1000, "def_bonus": 600},
	{"name": "飞升", "min_cultivation": 10000000, "hp_bonus": 50000, "mp_bonus": 30000, "atk_bonus": 5000, "def_bonus": 3000}
]

func _ready():
	pass

func start_game():
	current_state = GameState.GAME
	emit_signal("game_started")

func pause_game():
	current_state = GameState.PAUSED
	emit_signal("game_paused")

func resume_game():
	current_state = GameState.GAME
	emit_signal("game_resumed")

func change_scene(scene_path):
	if current_scene:
		current_scene.queue_free()
	current_scene = load(scene_path).instantiate()
	get_tree().root.add_child(current_scene)
	emit_signal("scene_changed")

func update_player_stats():
	var realm = realms[player_data["realm"]]
	player_data["max_hp"] = realm.hp_bonus + (player_data["level"] - 1) * 10
	player_data["max_mp"] = realm.mp_bonus + (player_data["level"] - 1) * 5
	player_data["attack"] = realm.atk_bonus + (player_data["level"] - 1) * 2
	player_data["defense"] = realm.def_bonus + (player_data["level"] - 1) * 1

func gain_cultivation(amount):
	player_data["cultivation"] += amount
	check_realm_up()

func check_realm_up():
	for i in range(realms.size() - 1, 0, -1):
		if player_data["cultivation"] >= realms[i]["min_cultivation"] and player_data["realm"] < i:
			player_data["realm"] = i
			update_player_stats()
			print("恭喜突破到" + realms[i]["name"] + "！")
			return true
	return false

func get_current_realm_name():
	return realms[player_data["realm"]]["name"]

func get_next_realm_requirement():
	if player_data["realm"] < realms.size() - 1:
		return realms[player_data["realm"] + 1]["min_cultivation"]
	return 0
