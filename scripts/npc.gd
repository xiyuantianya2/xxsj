extends Node2D

# NPC系统
class_name NPC

signal dialogue_started
signal quest_given
signal quest_completed

@export var npc_id: String = ""
@export var name: String = "无名"
@export var dialogue_id: String = ""
@export var quest_id: String = ""

var is_interactable: bool = true
var current_quest_given: bool = false

func _ready():
	pass

func on_interact():
	if not is_interactable:
		return
	
	# 开始对话
	if not dialogue_id.is_empty():
		start_dialogue(dialogue_id)
	
	# 给予任务
	if not quest_id.is_empty() and not current_quest_given:
		give_quest(quest_id)

func start_dialogue(dialogue_id: String):
	emit_signal("dialogue_started", dialogue_id)

func give_quest(quest_id: String):
	if not current_quest_given:
		current_quest_given = true
		emit_signal("quest_given", quest_id)
		# 添加到玩家任务列表
		if not quest_id in GameManager.player_data["quests"]:
			GameManager.player_data["quests"].append(quest_id)

func complete_quest(quest_id: String):
	if quest_id == quest_id and current_quest_given:
		current_quest_given = false
		emit_signal("quest_completed", quest_id)
		# 从玩家任务列表移除
		GameManager.player_data["quests"].erase(quest_id)
		# 给予奖励
		give_reward(quest_id)

func give_reward(quest_id: String):
	# 加载任务奖励数据
	var reward_data = load_quest_reward(quest_id)
	if reward_data:
		# 给予修为
		if reward_data.has("cultivation"):
			GameManager.gain_cultivation(reward_data["cultivation"])
		# 给予物品
		if reward_data.has("items"):
			for item in reward_data["items"]:
				ItemSystem.add_item(item["id"], item.get("quantity", 1))

func load_quest_reward(quest_id: String) -> Dictionary:
	var file = FileAccess.open("res://data/quests/" + quest_id + "_reward.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	return {}
