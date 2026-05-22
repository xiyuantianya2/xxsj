extends Control

# 战斗UI
class_name BattleUI

@onready var player_hp_bar = $PlayerHPBar
@onready var player_mp_bar = $PlayerMPBar
@onready var enemy_hp_bar = $EnemyHPBar
@onready var battle_log = $BattleLog
@onready var action_buttons = $ActionButtons

var battle_system = null

func _ready():
	battle_system = BattleSystem.new()
	add_child(battle_system)
	
	battle_system.battle_started.connect(on_battle_started)
	battle_system.battle_ended.connect(on_battle_ended)
	battle_system.player_damaged.connect(on_player_damaged)
	battle_system.enemy_damaged.connect(on_enemy_damaged)
	
	$ActionButtons/AttackButton.pressed.connect(_on_attack)
	$ActionButtons/SkillButton.pressed.connect(_on_skill)
	$ActionButtons/ItemButton.pressed.connect(_on_item)
	$ActionButtons/FleeButton.pressed.connect(_on_flee)

func start_battle(enemy_data: Dictionary):
	battle_system.start_battle(GameManager.player_data, enemy_data)

func on_battle_started():
	update_hp_bars()
	battle_log.text = ""
	_add_log("战斗开始！")

func on_battle_ended(victory: bool, exp: int, gold: int):
	if victory:
		_add_log("战斗胜利！获得修为：" + str(exp))
	else:
		_add_log("战斗失败...")
	
	# 关闭战斗UI
	queue_free()

func on_player_damaged(amount: int):
	update_hp_bars()
	_add_log("受到" + str(amount) + "点伤害")

func on_enemy_damaged(amount: int):
	update_hp_bars()
	_add_log("敌人受到" + str(amount) + "点伤害")

func update_hp_bars():
	var player = battle_system.player
	var enemy = battle_system.enemy
	
	player_hp_bar.value = float(player["hp"]) / player["max_hp"]
	player_mp_bar.value = float(player["mp"]) / player["max_mp"]
	enemy_hp_bar.value = float(enemy["hp"]) / enemy["max_hp"]

func _on_attack():
	battle_system.player_attack()
	update_hp_bars()

func _on_skill():
	# 打开技能选择
	pass

func _on_item():
	# 打开物品选择
	pass

func _on_flee():
	battle_system.flee()

func _add_log(message: String):
	battle_log.text += message + "\n"
	battle_log.scroll_vertical = battle_log.get_scroll_vertical_max()
