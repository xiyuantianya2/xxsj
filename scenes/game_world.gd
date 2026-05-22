extends Node2D

# 游戏世界主场景
class_name GameWorld

@onready var player = $Player
@onready var camera = $Camera2D
@onready var ui = $UI
@onready var tilemap = $TileMap

var current_map = null
var game_active = false

func _ready():
	# 初始化游戏
	GameManager.initialize_player()
	
	# 加载起始地图
	load_map("village")
	
	# 启动游戏
	game_active = true
	camera.position = player.position

func _process(delta):
	if game_active:
		# 更新相机跟随玩家
		camera.position = player.position
		
		# 检查随机遭遇
		if randi() % 300 == 0:
			check_random_encounter()

func load_map(map_id: String):
	current_map = MapSystem.load_map(map_id)
	# 加载地图数据
	print("Loaded map: " + current_map["name"])

func check_random_encounter():
	if current_map and "encounters" in current_map:
		for encounter in current_map["encounters"]:
			if randf() < encounter["chance"]:
				start_battle(encounter["enemy"])

func start_battle(enemy_id: String):
	var enemy_data = EnemyManager.load_enemy(enemy_id)
	if enemy_data:
		print("Battle started with: " + enemy_data["name"])
		# 创建战斗场景
		var battle = load("res://scenes/battle.tscn").instantiate()
		battle.start_battle(enemy_data)
		add_child(battle)

func _input(event):
	if event.is_action_pressed("pause"):
		game_active = not game_active
		print("Game paused: " + str(not game_active))
