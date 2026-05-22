extends Node

# 修炼系统
class_name CultivationSystem

signal realm_broken
signal skill_learned
signal cultivation_gained

# 功法类型
enum SkillType {
	ATTACK,      # 攻击功法
	DEFENSE,     # 防御功法
	HEAL,        # 治疗功法
	SPECIAL,     # 特殊功法
	MOVEMENT     # 身法
}

# 功法数据结构
# {
#   "id": "fire_slash",
#   "name": "烈焰斩",
#   "description": "以火焰之力斩击敌人",
#   "type": SkillType.ATTACK,
#   "power": 20,
#   "mp_cost": 10,
#   "cooldown": 3,
#   "realm_required": 1,
#   "elements": ["fire"]
# }

var learned_skills = []
var active_skill = null

func _ready():
	pass

func learn_skill(skill_id: String) -> bool:
	# 检查是否已学会
	for skill in learned_skills:
		if skill["id"] == skill_id:
			return false
	
	# 加载功法数据
	var skill_data = load_skill_data(skill_id)
	if not skill_data:
		return false
	
	# 检查境界要求
	if skill_data.has("realm_required"):
		if GameManager.player_data["realm"] < skill_data["realm_required"]:
			push_error("境界不足，无法学习此功法")
			return false
	
	# 学习功法
	learned_skills.append(skill_data)
	emit_signal("skill_learned", skill_data)
	return true

func use_skill(skill_id: String) -> bool:
	for skill in learned_skills:
		if skill["id"] == skill_id:
			# 检查灵力
			if GameManager.player_data["mp"] < skill.get("mp_cost", 0):
				push_error("灵力不足")
				return false
			
			# 消耗灵力
			GameManager.player_data["mp"] -= skill["mp_cost"]
			
			# 执行功法效果
			execute_skill(skill)
			return true
	return false

func execute_skill(skill: Dictionary):
	match skill["type"]:
		SkillType.ATTACK:
			# 攻击逻辑
			pass
		SkillType.DEFENSE:
			# 防御逻辑
			pass
		SkillType.HEAL:
			# 治疗逻辑
			GameManager.player_data["hp"] = min(
				GameManager.player_data["hp"] + skill["power"],
				GameManager.player_data["max_hp"]
			)
		SkillType.SPECIAL:
			# 特殊效果
			pass
		SkillType.MOVEMENT:
			# 身法效果
			pass

func meditate(hours: int = 1):
	# 打坐修炼，获得修为
	var cultivation_gain = GameManager.player_data["level"] * hours
	GameManager.gain_cultivation(cultivation_gain)
	emit_signal("cultivation_gained", cultivation_gain)

func attempt_breakthrough() -> bool:
	# 尝试突破境界
	var next_realm = GameManager.realms[GameManager.player_data["realm"] + 1]
	if GameManager.player_data["cultivation"] >= next_realm["min_cultivation"]:
		# 突破成功
		GameManager.player_data["realm"] += 1
		GameManager.update_player_stats()
		emit_signal("realm_broken", GameManager.player_data["realm"])
		return true
	else:
		push_error("修为不足，无法突破")
		return false

func load_skill_data(skill_id: String) -> Dictionary:
	var file = FileAccess.open("res://data/skills/" + skill_id + ".json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	return {}

func get_available_skills() -> Array:
	# 返回当前境界可学习的所有功法
	var available = []
	for skill in learned_skills:
		if skill.get("realm_required", 0) <= GameManager.player_data["realm"]:
			available.append(skill)
	return available
