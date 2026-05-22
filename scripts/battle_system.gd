extends Node2D

# 战斗系统
class_name BattleSystem

signal battle_started
signal battle_ended
signal turn_changed
signal player_damaged
signal enemy_damaged

# 战斗状态
enum BattleState {
	WAITING,
	PLAYER_TURN,
	ENEMY_TURN,
	BATTLE_END
}

var current_state = BattleState.WAITING
var player = null
var enemy = null
var battle_log = []

func start_battle(player_data: Dictionary, enemy_data: Dictionary):
	player = player_data.duplicate(true)
	enemy = enemy_data.duplicate(true)
	current_state = BattleState.PLAYER_TURN
	battle_log = []
	
	emit_signal("battle_started")
	_add_log("战斗开始！")
	_add_log("对手：" + enemy["name"])

func player_attack():
	if current_state != BattleState.PLAYER_TURN:
		return
	
	# 计算伤害
	var damage = max(1, player["attack"] - enemy["defense"] + randi_range(-5, 5))
	enemy["hp"] -= damage
	
	_add_log("你对" + enemy["name"] + "造成了" + str(damage) + "点伤害！")
	emit_signal("enemy_damaged", damage)
	
	# 检查敌人是否死亡
	if enemy["hp"] <= 0:
		_enemy_defeated()
		return
	
	# 切换到敌人回合
	current_state = BattleState.ENEMY_TURN
	emit_signal("turn_changed")
	enemy_turn()

func enemy_turn():
	if current_state != BattleState.ENEMY_TURN:
		return
	
	# 敌人攻击
	var damage = max(1, enemy["attack"] - player["defense"] + randi_range(-5, 5))
	player["hp"] -= damage
	
	_add_log(enemy["name"] + "对你造成了" + str(damage) + "点伤害！")
	emit_signal("player_damaged", damage)
	
	# 检查玩家是否死亡
	if player["hp"] <= 0:
		_player_defeated()
		return
	
	# 切换回玩家回合
	current_state = BattleState.PLAYER_TURN
	emit_signal("turn_changed")

func player_use_skill(skill: Dictionary):
	if current_state != BattleState.PLAYER_TURN:
		return
	
	# 技能逻辑
	match skill["type"]:
		"attack":
			player_attack()
		"heal":
			var heal_amount = skill["power"]
			player["hp"] = min(player["hp"] + heal_amount, player["max_hp"])
			_add_log("你恢复了" + str(heal_amount) + "点生命值！")
		"special":
			# 特殊技能逻辑
			pass
	
	# 切换到敌人回合
	current_state = BattleState.ENEMY_TURN
	emit_signal("turn_changed")
	enemy_turn()

func _enemy_defeated():
	current_state = BattleState.BATTLE_END
	_add_log("你击败了" + enemy["name"] + "！")
	
	# 奖励逻辑
	var exp_reward = enemy.get("exp_reward", 10)
	var gold_reward = enemy.get("gold_reward", 5)
	
	GameManager.player_data["cultivation"] += exp_reward
	_add_log("获得修为：" + str(exp_reward))
	
	emit_signal("battle_ended", true, exp_reward, gold_reward)

func _player_defeated():
	current_state = BattleState.BATTLE_END
	_add_log("你被击败了...")
	emit_signal("battle_ended", false, 0, 0)

func _add_log(message: String):
	battle_log.append(message)
	print(message)

func get_battle_log() -> Array:
	return battle_log

func flee():
	# 逃跑逻辑
	var flee_chance = 0.5 + (player["speed"] - enemy["speed"]) * 0.05
	if randf() < flee_chance:
		_add_log("你成功逃跑了！")
		current_state = BattleState.BATTLE_END
		emit_signal("battle_ended", false, 0, 0)
		return true
	else:
		_add_log("逃跑失败！")
		# 敌人攻击
		enemy_turn()
		return false
