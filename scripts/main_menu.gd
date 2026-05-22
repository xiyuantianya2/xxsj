extends Control

# 主菜单脚本
class_name MainMenu

signal start_game
signal load_game
signal quit_game

func _ready():
	$StartButton.pressed.connect(on_start)
	$LoadButton.pressed.connect(on_load)
	$QuitButton.pressed.connect(on_quit)

func on_start():
	emit_signal("start_game")

func on_load():
	emit_signal("load_game")

func on_quit():
	get_tree().quit()
