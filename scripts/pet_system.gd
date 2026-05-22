extends Node

# 灵宠系统
class_name PetSystem

signal pet_captured
signal pet_evolved
signal pet_skill_used

# 灵宠数据结构
# {
#   "id": "fire_bird",
#   "name": "火凤",
#   "level": 1,
#   "hp": 100,
#   "max_hp": 100,
#   "attack": 20,
#   "defense": 10,
#   "skills": ["fire_breath"],
#   "element": "fire"
# }

var pets = []
var active_pet = null
var max_pets = 5

func _ready():
	pass

func capture_pet(pet_data: Dictionary) -> bool:
	if pets.size() >= max_pets:
		push_error("灵宠数量已达上限")
		return false
	
	pets.append(pet_data)
	emit_signal("pet_captured", pet_data)
	return true

func release_pet(pet_id: String):
	for i in range(pets.size()):
		if pets[i]["id"] == pet_id:
			pets.pop_at(i)
			if active_pet == pet_id:
				active_pet = null
			return

func set_active_pet(pet_id: String):
	for pet in pets:
		if pet["id"] == pet_id:
			active_pet = pet_id
			return

func evolve_pet(pet_id: String) -> bool:
	for pet in pets:
		if pet["id"] == pet_id:
			pet["level"] += 1
			pet["hp"] += 10
			pet["max_hp"] += 10
			pet["attack"] += 5
			pet["defense"] += 3
			emit_signal("pet_evolved", pet)
			return true
	return false

func use_pet_skill(pet_id: String, skill_id: String):
	for pet in pets:
		if pet["id"] == pet_id and skill_id in pet["skills"]:
			emit_signal("pet_skill_used", pet, skill_id)
			return
