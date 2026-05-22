extends Node

# 任务系统
class_name QuestSystem

signal quest_received
signal quest_updated
signal quest_completed
signal quest_failed

# 任务状态
enum QuestState {
	AVAILABLE,
	ACTIVE,
	COMPLETED,
	FAILED
}

# 任务数据结构
# {
#   "id": "quest_001",
#   "name": "初出茅庐",
#   "description": "帮助村长采集灵草",
#   "giver_npc": "village_elder",
#   "state": QuestState.AVAILABLE,
#   "objectives": [
#     {"type": "collect", "target": "spirit_herb", "required": 5, "current": 0}
#   ],
#   "rewards": {
#     "cultivation": 50,
#     "items": [{"id": "potion_hp_small", "quantity": 2}]
#   },
#   "prerequisites": [],
#   "is_main_quest": false
# }

var active_quests = []
var completed_quests = []
var failed_quests = []

func _ready():
	pass

func receive_quest(quest_id: String) -> bool:
	var quest_data = load_quest_data(quest_id)
	if not quest_data:
		return false
	
	# 检查前置条件
	if not check_prerequisites(quest_data):
		return false
	
	quest_data["state"] = QuestState.ACTIVE
	active_quests.append(quest_data)
	emit_signal("quest_received", quest_data)
	return true

func update_quest(quest_id: String, objective_type: String, amount: int = 1):
	for quest in active_quests:
		if quest["id"] == quest_id:
			for objective in quest["objectives"]:
				if objective["type"] == objective_type:
					objective["current"] += amount
					check_quest_completion(quest)
					emit_signal("quest_updated", quest)
					return
	return

func check_quest_completion(quest: Dictionary):
	# 检查所有目标是否完成
	for objective in quest["objectives"]:
		if objective["current"] < objective["required"]:
			return
	
	# 所有目标完成
	complete_quest(quest["id"])

func complete_quest(quest_id: String):
	for i in range(active_quests.size()):
		if active_quests[i]["id"] == quest_id:
			var quest = active_quests.pop_at(i)
			quest["state"] = QuestState.COMPLETED
			completed_quests.append(quest)
			
			# 给予奖励
			give_quest_rewards(quest)
			
			emit_signal("quest_completed", quest)
			return
	return

func fail_quest(quest_id: String):
	for i in range(active_quests.size()):
		if active_quests[i]["id"] == quest_id:
			var quest = active_quests.pop_at(i)
			quest["state"] = QuestState.FAILED
			failed_quests.append(quest)
			emit_signal("quest_failed", quest)
			return

func give_quest_rewards(quest: Dictionary):
	var rewards = quest.get("rewards", {})
	
	# 修为奖励
	if rewards.has("cultivation"):
		GameManager.gain_cultivation(rewards["cultivation"])
	
	# 物品奖励
	if rewards.has("items"):
		for item in rewards["items"]:
			ItemSystem.add_item(item["id"], item.get("quantity", 1))

func check_prerequisites(quest: Dictionary) -> bool:
	var prerequisites = quest.get("prerequisites", [])
	for prereq in prerequisites:
		match prereq["type"]:
			"realm":
				if GameManager.player_data["realm"] < prereq["value"]:
					return false
			"level":
				if GameManager.player_data["level"] < prereq["value"]:
					return false
			"quest_completed":
				if not prereq["value"] in completed_quests:
					return false
	return true

func load_quest_data(quest_id: String) -> Dictionary:
	var file = FileAccess.open("res://data/quests/" + quest_id + ".json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	return {}

func get_active_quests() -> Array:
	return active_quests

func get_quest_by_id(quest_id: String) -> Dictionary:
	for quest in active_quests:
		if quest["id"] == quest_id:
			return quest
	return {}
