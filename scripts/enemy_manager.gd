extends Node

# 敌人管理器
class_name EnemyManager

# 敌人数据结构
# {
#   "id": "spirit_wolf",
#   "name": "灵狼",
#   "hp": 50,
#   "max_hp": 50,
#   "attack": 15,
#   "defense": 5,
#   "speed": 12,
#   "exp_reward": 20,
#   "gold_reward": 10,
#   "drops": [
#     {"id": "wolf_fur", "chance": 0.5}
#   ]
# }

var enemies = {}

func _ready():
	load_all_enemies()

func load_all_enemies():
	var enemies_dir = DirAccess.open("res://data/enemies/")
	if enemies_dir:
		enemies_dir.list_dir_begin()
		var file = enemies_dir.get_next()
		while file != "":
			if file.ends_with(".json"):
				var enemy_id = file.trim_suffix(".json")
				enemies[enemy_id] = load_enemy_data(enemy_id)
			file = enemies_dir.get_next()
		enemies_dir.list_dir_end()

func load_enemy_data(enemy_id: String) -> Dictionary:
	var file = FileAccess.open("res://data/enemies/" + enemy_id + ".json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	return {}

func get_enemy(enemy_id: String) -> Dictionary:
	if enemy_id in enemies:
		return enemies[enemy_id].duplicate(true)
	return {}

func get_random_encounter() -> Dictionary:
	var keys = enemies.keys()
	if keys.is_empty():
		return {}
	return get_enemy(keys[randi() % keys.size()])
