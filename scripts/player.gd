extends CharacterBody2D

# 玩家角色
class_name Player

@export var move_speed: float = 100.0
@export var animation_speed: float = 8.0

var animation_timer: Timer
var facing_direction: int = 0  # 0=下, 1=左, 2=右, 3=上
var is_moving: bool = false
var current_animation: String = "idle"

# 碰撞检测
var collision_layer: int = 1
var collision_mask: int = 2

func _ready():
	# 创建动画定时器
	animation_timer = Timer.new()
	animation_timer.wait_time = 1.0 / animation_speed
	animation_timer.one_shot = false
	animation_timer.timeout.connect(_on_animation_timer)
	add_child(animation_timer)
	animation_timer.start()

	# 设置碰撞
	collision_layer = collision_layer
	collision_mask = collision_mask

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	# 获取输入
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	# 归一化方向
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		is_moving = true
		
		# 更新面向方向
		if direction.y > 0:
			facing_direction = 0  # 下
		elif direction.x < 0:
			facing_direction = 1  # 左
		elif direction.x > 0:
			facing_direction = 2  # 右
		elif direction.y < 0:
			facing_direction = 3  # 上
		
		# 移动
		velocity = direction * move_speed
		move_and_slide()
		
		# 播放行走动画
		if current_animation != "walk":
			current_animation = "walk"
			_play_animation()
	else:
		is_moving = false
		velocity = Vector2.ZERO
		if current_animation != "idle":
			current_animation = "idle"
			_play_animation()

func _on_animation_timer():
	# 动画帧更新逻辑
	pass

func _play_animation():
	# 播放动画的逻辑
	# 这里需要根据实际美术资源实现
	match current_animation:
		"idle":
			pass  # 播放待机动画
		"walk":
			pass  # 播放行走动画

func interact():
	# 交互逻辑
	var interact_direction = Vector2.ZERO
	match facing_direction:
		0: interact_direction = Vector2(0, 1)  # 下
		1: interact_direction = Vector2(-1, 0) # 左
		2: interact_direction = Vector2(1, 0)  # 右
		3: interact_direction = Vector2(0, -1) # 上
	
	# 检测前方是否有可交互对象
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position + interact_direction * 32
	query.collision_mask = 4  # NPC层
	
	var result = space_state.intersect_point(query)
	if not result.is_empty():
		var npc = result[0]["collider"]
		if npc.has_method("on_interact"):
			npc.on_interact()

func take_damage(amount: int):
	GameManager.player_data["hp"] -= amount
	if GameManager.player_data["hp"] <= 0:
		_on_death()

func heal(amount: int):
	GameManager.player_data["hp"] = min(GameManager.player_data["hp"] + amount, GameManager.player_data["max_hp"])

func _on_death():
	# 死亡逻辑
	print("玩家死亡！")
	# 可以添加复活逻辑
