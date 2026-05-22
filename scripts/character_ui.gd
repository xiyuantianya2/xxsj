extends Control

# 角色面板UI
class_name CharacterUI

@onready var name_label = $NameLabel
@onready var realm_label = $RealmLabel
@onready var cultivation_label = $CultivationLabel
@onready var hp_bar = $HPBar
@onready var mp_bar = $MPBar
@onready var stats_label = $StatsLabel

func update_display():
	var player = GameManager.player_data
	
	name_label.text = "姓名：" + player["name"]
	realm_label.text = "境界：" + GameManager.get_current_realm_name()
	cultivation_label.text = "修为：" + str(player["cultivation"])
	
	hp_bar.value = float(player["hp"]) / player["max_hp"]
	mp_bar.value = float(player["mp"]) / player["max_mp"]
	
	stats_label.text = "攻击：" + str(player["attack"]) + "\n防御：" + str(player["defense"]) + "\n速度：" + str(player["speed"])
