extends Control

# UI管理器
class_name UIManager

signal button_pressed
signal menu_opened
signal menu_closed

@onready var main_menu = $MainMenu
@onready var game_ui = $GameUI
@onready var battle_ui = $BattleUI
@onready var inventory_ui = $InventoryUI
@onready var dialogue_ui = $DialogueUI

var current_menu = null

func _ready():
	hide_all_menus()
	main_menu.show()

func show_main_menu():
	hide_all_menus()
	main_menu.show()
	current_menu = main_menu
	emit_signal("menu_opened", "main")

func show_game_ui():
	hide_all_menus()
	game_ui.show()
	current_menu = game_ui
	emit_signal("menu_opened", "game")

func show_battle_ui():
	hide_all_menus()
	battle_ui.show()
	current_menu = battle_ui
	emit_signal("menu_opened", "battle")

func show_inventory():
	hide_all_menus()
	inventory_ui.show()
	current_menu = inventory_ui
	emit_signal("menu_opened", "inventory")

func show_dialogue():
	hide_all_menus()
	dialogue_ui.show()
	current_menu = dialogue_ui
	emit_signal("menu_opened", "dialogue")

func hide_all_menus():
	main_menu.hide()
	game_ui.hide()
	battle_ui.hide()
	inventory_ui.hide()
	dialogue_ui.hide()
	current_menu = null

func update_player_stats():
	# 更新玩家状态显示
	var player = GameManager.player_data
	# TODO: 更新UI元素
	pass

func update_inventory():
	# 更新背包显示
	# TODO: 更新UI元素
	pass

func show_message(message: String, duration: float = 2.0):
	# 显示临时消息
	# TODO: 实现消息显示
	print(message)
