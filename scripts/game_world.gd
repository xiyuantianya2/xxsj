extends Node2D

# 游戏世界主脚本
class_name GameWorld

var player = null
var tilemap = null
var ui_manager = null

func _ready():
	player = $Player
	tilemap = $TileMap
	ui_manager = $UI
	
	# 连接信号
	GameManager.game_started.connect(on_game_started)
	
	# 初始化UI
	ui_manager.show_game_ui()

func on_game_started():
	print("游戏开始！")
	# 加载初始地图
	MapSystem.change_map("village", Vector2(10, 10))

func _input(event):
	if event.is_action_pressed("interact"):
		player.interact()
