extends Node2D

# 地图系统
class_name MapSystem

signal map_changed
signal location_discovered

# 地图数据结构
# {
#   "id": "village",
#   "name": "青云村",
#   "description": "一个宁静的小村庄",
#   "tilemap": "res://assets/tilemaps/village.tres",
#   "npcs": [],
#   "exits": [
#     {"direction": "up", "target_map": "mountain", "target_position": [10, 20]}
#   ],
#   "encounters": [
#     {"enemy": "wolf", "chance": 0.3}
#   ]
# }

var current_map = null
var map_data = {}
var discovered_locations = []

func _ready():
	load_all_maps()

func load_all_maps():
	# 加载所有地图数据
	var maps_dir = DirAccess.open("res://data/maps/")
	if maps_dir:
		maps_dir.list_dir_begin()
		var file = maps_dir.get_next()
		while file != "":
			if file.ends_with(".json"):
				var map_id = file.trim_suffix(".json")
				map_data[map_id] = load_map_data(map_id)
			file = maps_dir.get_next()
		maps_dir.list_dir_end()

func load_map_data(map_id: String) -> Dictionary:
	var file = FileAccess.open("res://data/maps/" + map_id + ".json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	return {}

func change_map(map_id: String, position: Vector2 = Vector2(0, 0)):
	if map_id in map_data:
		current_map = map_id
		map_data[map_id]["player_position"] = position
		
		# 标记地点为已发现
		if not map_id in discovered_locations:
			discovered_locations.append(map_id)
			emit_signal("location_discovered", map_id)
		
		emit_signal("map_changed", map_id)
		return true
	return false

func get_exit(direction: String) -> Dictionary:
	if current_map and map_data[current_map].has("exits"):
		for exit in map_data[current_map]["exits"]:
			if exit["direction"] == direction:
				return exit
	return {}

func move_to_exit(direction: String):
	var exit = get_exit(direction)
	if exit:
		change_map(exit["target_map"], Vector2(exit["target_position"][0], exit["target_position"][1]))

func check_encounter() -> bool:
	if current_map and map_data[current_map].has("encounters"):
		for encounter in map_data[current_map]["encounters"]:
			if randf() < encounter["chance"]:
				return true
	return false

func get_current_map_name() -> String:
	if current_map and current_map in map_data:
		return map_data[current_map]["name"]
	return "未知"

func get_current_map_description() -> String:
	if current_map and current_map in map_data:
		return map_data[current_map].get("description", "")
	return ""
