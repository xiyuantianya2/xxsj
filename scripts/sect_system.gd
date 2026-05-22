extends Node

# 宗门系统
class_name SectSystem

signal sect_joined
signal sect_rank_changed
signal sect_quest_received

# 宗门数据结构
# {
#   "id": "qingyun",
#   "name": "青云宗",
#   "description": "以剑道闻名的修仙宗门",
#   "ranks": ["外门弟子", "内门弟子", "核心弟子", "长老", "宗主"],
#   "quests": [],
#   "benefits": {
#     "cultivation_bonus": 0.1,
#     "skills": ["sword_art_basic"]
#   }
# }

var current_sect = null
var sect_rank = 0
var sects = {}

func _ready():
	load_all_sects()

func load_all_sects():
	var sects_dir = DirAccess.open("res://data/sects/")
	if sects_dir:
		sects_dir.list_dir_begin()
		var file = sects_dir.get_next()
		while file != "":
			if file.ends_with(".json"):
				var sect_id = file.trim_suffix(".json")
				sects[sect_id] = load_sect_data(sect_id)
			file = sects_dir.get_next()
		sects_dir.list_dir_end()

func join_sect(sect_id: String) -> bool:
	if sect_id in sects:
		current_sect = sect_id
		sect_rank = 0
		emit_signal("sect_joined", sects[sect_id])
		return true
	return false

func promote():
	if sect_rank < sects[current_sect]["ranks"].size() - 1:
		sect_rank += 1
		emit_signal("sect_rank_changed", sect_rank)
		return true
	return false

func load_sect_data(sect_id: String) -> Dictionary:
	var file = FileAccess.open("res://data/sects/" + sect_id + ".json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	return {}

func get_sect_name() -> String:
	if current_sect and current_sect in sects:
		return sects[current_sect]["name"]
	return "无"

func get_rank_name() -> String:
	if current_sect and current_sect in sects:
		return sects[current_sect]["ranks"][sect_rank]
	return ""
