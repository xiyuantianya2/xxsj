extends Node

# 存档管理器
class_name SaveManager

const SAVE_PATH = "user://saves/"
const AUTO_SAVE_PATH = "user://autosave.dat"

signal save_completed
signal load_completed
signal save_failed

func _ready():
	# 确保存档目录存在
	var dir = DirAccess.open("user://")
	if dir.dir_exists("saves"):
		return
	dir.make_dir("saves")

func save_game(save_name: String, data: Dictionary) -> bool:
	var save_path = SAVE_PATH + save_name + ".dat"
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("无法创建存档文件: " + save_path)
		emit_signal("save_failed")
		return false
	
	file.store_var(data)
	file.close()
	
	print("游戏已保存: " + save_name)
	emit_signal("save_completed")
	return true

func load_game(save_name: String) -> Dictionary:
	var save_path = SAVE_PATH + save_name + ".dat"
	
	if not FileAccess.file_exists(save_path):
		push_error("存档不存在: " + save_name)
		return {}
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_error("无法读取存档文件: " + save_path)
		return {}
	
	var data = file.get_var()
	file.close()
	
	print("游戏已加载: " + save_name)
	emit_signal("load_completed")
	return data

func auto_save(data: Dictionary) -> bool:
	return save_game("autosave", data)

func load_auto_save() -> Dictionary:
	return load_game("autosave")

func get_save_list() -> Array:
	var saves = []
	var dir = DirAccess.open(SAVE_PATH)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".dat"):
				var save_data = load_game(file_name.trim_suffix(".dat"))
				saves.append({
					"name": file_name.trim_suffix(".dat"),
					"data": save_data
				})
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return saves

func delete_save(save_name: String) -> bool:
	var save_path = SAVE_PATH + save_name + ".dat"
	
	if not FileAccess.file_exists(save_path):
		return false
	
	var dir = DirAccess.open(SAVE_PATH)
	if dir:
		dir.remove(save_name + ".dat")
		print("存档已删除: " + save_name)
		return true
	
	return false

func create_save_data() -> Dictionary:
	return {
		"player": GameManager.player_data,
		"position": Vector2(0, 0),
		"current_map": "",
		"quests": [],
		"flags": GameManager.player_data.get("flags", {}),
		"timestamp": Time.get_datetime_string_from_system()
	}
