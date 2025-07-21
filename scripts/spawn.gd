extends Path2D

func _ready() -> void:
	Player.level_up.connect(_on_player_level_up)
	$Timer.wait_time = 1.0
	$Timer2.wait_time = 1.0

func _on_player_level_up() -> void:
	# will be max around lvl 50
	# 0.035 is the maximum limit, i have around 16ms per physics tick
	# with 0.04 i have around 7ms per physics tick
	# 0.04 is 50 ticks per second
	# 0.035 is 57 ticks per second
	# max enemies is limited anyways now
	$Timer.wait_time = max(0.05, 0.6 - Player.level * 0.01)
	$Timer2.wait_time = max(0.05, 0.6 - Player.level * 0.01)

func spawn_enemy() -> void:
	if Player.enemy_count >= Player.max_enemies: return

	var enemy := preload("res://scenes/enemy.tscn").instantiate()
	var modifier = 1.0 + floor(Player.level / 10.0) / 10.0
	enemy.health = 1.0 + pow(Player.level, modifier)
	enemy.speed += pow(Player.level * 0.8, Player.enemy_speed_multiplier)
	$PathFollow2D.progress_ratio = randf()
	enemy.global_position = $PathFollow2D.global_position
	Player.enemy_count += 1
	get_tree().get_current_scene().add_child(enemy)


func _on_timer_timeout() -> void:
	self.spawn_enemy()

func _on_timer_2_timeout() -> void:
	self.spawn_enemy()
