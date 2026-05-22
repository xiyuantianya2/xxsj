extends Control

# 对话系统
class_name DialogueSystem

signal dialogue_finished
signal choice_selected

@onready var dialogue_label = $DialogueLabel
@onready var name_label = $NameLabel
@onready var choices_container = $ChoicesContainer

var current_dialogue = []
var current_index = 0
var current_character = ""
var is_waiting_for_input = false

func start_dialogue(dialogue_id: String):
	# 加载对话数据
	var dialogue_data = load_dialogue_data(dialogue_id)
	if dialogue_data:
		current_dialogue = dialogue_data
		current_index = 0
		show_dialogue()

func show_dialogue():
	if current_index >= current_dialogue.size():
		# 对话结束
		emit_signal("dialogue_finished")
		queue_free()
		return
	
	var line = current_dialogue[current_index]
	current_character = line["character"]
	
	# 更新UI
	name_label.text = current_character
	dialogue_label.text = line["text"]
	
	# 清除之前的选项
	for child in choices_container.get_children():
		child.queue_free()
	
	# 如果有选项，显示选项
	if line.has("choices") and not line["choices"].is_empty():
		is_waiting_for_input = true
		for choice in line["choices"]:
			var button = Button.new()
			button.text = choice["text"]
			button.pressed.connect(_on_choice_selected.bind(choice))
			choices_container.add_child(button)
	else:
		is_waiting_for_input = false

func _on_choice_selected(choice: Dictionary):
	is_waiting_for_input = false
	emit_signal("choice_selected", choice)
	
	# 根据选择跳转到对应的对话索引
	if choice.has("next"):
		current_index = choice["next"]
	else:
		current_index += 1
	
	show_dialogue()

func _input(event):
	if is_waiting_for_input:
		return
	
	if event.is_action_pressed("interact"):
		if not is_waiting_for_input:
			current_index += 1
			show_dialogue()

func load_dialogue_data(dialogue_id: String) -> Array:
	var file = FileAccess.open("res://data/dialogue/" + dialogue_id + ".json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	return []
