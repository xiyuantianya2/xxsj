extends Node

# 物品系统
class_name ItemSystem

signal item_added
signal item_removed
signal item_used

# 物品类型
enum ItemType {
	CONSUMABLE,  # 消耗品（丹药、草药）
	EQUIPMENT,   # 装备（武器、防具）
	MATERIAL,    # 材料（炼制材料）
	QUEST,       # 任务物品
	KEY,         # 关键物品
	SPECIAL      # 特殊物品
}

# 物品数据结构
# {
#   "id": "potion_hp_small",
#   "name": "小还丹",
#   "description": "恢复50点生命值",
#   "type": ItemType.CONSUMABLE,
#   "effect": {"type": "heal", "value": 50},
#   "stackable": true,
#   "max_stack": 99,
#   "value": 10
# }

var inventory = []
var max_inventory_size = 50

func _ready():
	pass

func add_item(item_id: String, quantity: int = 1) -> bool:
	# 检查是否已有该物品
	for item in inventory:
		if item["id"] == item_id and item["stackable"]:
			if item["quantity"] + quantity <= item.get("max_stack", 99):
				item["quantity"] += quantity
				emit_signal("item_added", item, quantity)
				return true
	
	# 检查背包空间
	if inventory.size() >= max_inventory_size:
		push_error("背包已满！")
		return false
	
	# 添加新物品
	var item_data = load_item_data(item_id)
	if item_data:
		item_data["quantity"] = quantity
		inventory.append(item_data)
		emit_signal("item_added", item_data, quantity)
		return true
	
	return false

func remove_item(item_id: String, quantity: int = 1) -> bool:
	for i in range(inventory.size()):
		if inventory[i]["id"] == item_id:
			if inventory[i]["quantity"] > quantity:
				inventory[i]["quantity"] -= quantity
				emit_signal("item_removed", inventory[i], quantity)
				return true
			elif inventory[i]["quantity"] == quantity:
				var removed = inventory.pop_at(i)
				emit_signal("item_removed", removed, quantity)
				return true
	return false

func use_item(item_id: String) -> bool:
	for item in inventory:
		if item["id"] == item_id:
			var effect = item.get("effect")
			if effect:
				_apply_effect(effect)
				emit_signal("item_used", item)
			
			if item["stackable"] and item["quantity"] > 1:
				item["quantity"] -= 1
			else:
				inventory.erase(item)
			
			return true
	return false

func _apply_effect(effect: Dictionary):
	match effect["type"]:
		"heal":
			GameManager.player_data["hp"] = min(
				GameManager.player_data["hp"] + effect["value"],
				GameManager.player_data["max_hp"]
			)
		"mp_restore":
			GameManager.player_data["mp"] = min(
				GameManager.player_data["mp"] + effect["value"],
				GameManager.player_data["max_mp"]
			)
		"cultivation":
			GameManager.gain_cultivation(effect["value"])
		"stat_boost":
			for stat in effect["stats"]:
				GameManager.player_data[stat] += effect["stats"][stat]

func get_item_count(item_id: String) -> int:
	for item in inventory:
		if item["id"] == item_id:
			return item["quantity"]
	return 0

func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_count(item_id) >= quantity

func load_item_data(item_id: String) -> Dictionary:
	# 从数据文件加载物品数据
	var file = FileAccess.open("res://data/items/" + item_id + ".json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	return {}

func get_inventory() -> Array:
	return inventory

func get_equippable_items() -> Array:
	var items = []
	for item in inventory:
		if item["type"] == ItemType.EQUIPMENT:
			items.append(item)
	return items
