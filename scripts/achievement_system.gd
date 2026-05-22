extends Node

# 成就系统
class_name AchievementSystem

signal achievement_unlocked

var achievements_unlocked = []

# 成就数据结构
# {
#   "id": "first_battle",
#   "name": "初战告捷",
#   "description": "赢得第一场战斗",
#   "condition": {"type": "battle_won", "count": 1},
#   "reward": {"cultivation": 100}
# }

func _ready():
	pass

func check_achievements():
	# 检查所有成就条件
	var achievements = load_all_achievements()
	for achievement in achievements:
		if not achievement["id"] in achievements_unlocked:
			if check_condition(achievement["condition"]):
				unlock_achievement(achievement)

func check_condition(condition: Dictionary) -> bool:
	match condition["type"]:
		"battle_won":
			return GameManager.player_data.get("battles_won", 0) >= condition["count"]
		"realm_reached":
			return GameManager.player_data["realm"] >= condition["count"]
		"items_collected":
			return ItemSystem.get_inventory().size() >= condition["count"]
		_:
			return false

func unlock_achievement(achievement: Dictionary):
	achievements_unlocked.append(achievement["id"])
	emit_signal("achievement_unlocked", achievement)
	
	# 给予奖励
	var reward = achievement.get("reward", {})
	if reward.has("cultivation"):
		GameManager.gain_cultivation(reward["cultivation"])

func load_all_achievements() -> Array:
	var achievements = []
	var dir = DirAccess.open("res://data/achievements/")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".json"):
				var data = load_achievement_data(file.trim_suffix(".json"))
				if data:
					achievements.append(data)
			file = dir.get_next()
		dir.list_dir_end()
	return achievements

func load_achievement_data(id: String) -> Dictionary:
	var file = FileAccess.open("res://data/achievements/" + id + ".json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	return {}
