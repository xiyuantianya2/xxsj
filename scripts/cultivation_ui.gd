extends Control

# 修炼UI
class_name CultivationUI

@onready var meditate_button = $MeditateButton
@onready var breakthrough_button = $BreakthroughButton
@onready var cultivation_label = $CultivationLabel
@onready var progress_bar = $ProgressBar

func _ready():
	meditate_button.pressed.connect(_on_meditate)
	breakthrough_button.pressed.connect(_on_breakthrough)
	update_display()

func update_display():
	var player = GameManager.player_data
	cultivation_label.text = "修为：" + str(player["cultivation"])
	
	var next_realm = GameManager.get_next_realm_requirement()
	if next_realm > 0:
		progress_bar.value = float(player["cultivation"]) / next_realm
		breakthrough_button.disabled = player["cultivation"] < next_realm
	else:
		breakthrough_button.disabled = true

func _on_meditate():
	CultivationSystem.meditate(1)
	update_display()

func _on_breakthrough():
	if CultivationSystem.attempt_breakthrough():
		update_display()
	else:
		print("突破失败")
