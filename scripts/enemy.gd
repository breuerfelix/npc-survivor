extends CharacterBody2D

var speed := 80.0
@onready var character := $/root/World/Character
@onready var sprite := $AnimatedSprite2D
@onready var nav_agent := $CollisionShape2D/NavigationAgent2D
@onready var collision_shape := $CollisionShape2D
var health := 3
var is_dieing := false
var direction := Vector2.ZERO
var _last_damage_number_time := 0.0

func _physics_process(_delta: float) -> void:
	if self.is_dieing: return
	if self.health <= 0:
		_die()
		return

	nav_agent.target_position = character.global_position
	var next_path_pos = nav_agent.get_next_path_position()
	var to_player = character.global_position - self.collision_shape.global_position
	var close_enough_distance = 7.0

	self.velocity = Vector2.ZERO
	self.direction = (next_path_pos - self.collision_shape.global_position).normalized()
	if to_player.length() > close_enough_distance:
		# only move towards player if not close enough
		self.velocity = self.direction * self.speed

	self.move_and_slide()

func _process(_delta: float) -> void:
	# animation
	var animation := "pause"
	if abs(self.direction.x) > abs(self.direction.y):
		if self.direction.x > 0:
			animation = "move_right"
		elif self.direction.x < 0:
			animation = "move_left"
	else:
		if self.direction.y > 0:
			animation = "move_down"
		elif self.direction.y < 0:
			animation = "move_up"

	if animation == "pause":
		self.sprite.stop()
	else:
		self.sprite.play(animation)

func take_damage(damage):
	self.health -= damage
	Stats.damage_dealt += damage
	_show_damage_number(damage)

func _die():
	self.is_dieing = true

	# spawn exp bubble
	if Player.exp_bubble_count <= Player.max_exp_bubbles:
		var exp_scene := preload("res://scenes/experience.tscn")
		var exp_instance := exp_scene.instantiate()
		exp_instance.global_position = self.global_position
		get_tree().get_current_scene().call_deferred("add_child", exp_instance)
		Player.exp_bubble_count += 1
	else:
		Player.experience += 1.0

	# spawn blood splatter
	var blood_scene := preload("res://combat/scenes/blood.tscn")
	var blood_instance := blood_scene.instantiate()
	blood_instance.global_position = self.global_position
	self.get_tree().get_current_scene().call_deferred("add_child", blood_instance)

	# spawn enemy bullet with chance equal to player level percent
	if Player.enemy_bullet_count < Player.max_enemy_bullets:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var chance = float(Player.level) / 100.0
		if rng.randf() < chance:
			var bullet_scene := preload("res://combat/scenes/enemy-bullet.tscn")
			var bullet_instance := bullet_scene.instantiate()
			bullet_instance.global_position = self.global_position
			var bullet_tween := bullet_instance.create_tween()
			bullet_tween.tween_property(bullet_instance, "scale", Vector2.ONE, 0.2).from(Vector2.ZERO)
			Player.enemy_bullet_count += 1
			self.get_tree().get_current_scene().call_deferred("add_child", bullet_instance)

	# nice fade out
	self.velocity = Vector2.ZERO
	self.sprite.stop()

	var tween = self.create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.15)
	tween.finished.connect(self.queue_free)

	Stats.enemies_killed += 1
	Player.enemy_count -= 1

func _show_damage_number(damage: float) -> void:
	# only show every 200ms
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_damage_number_time < 0.2: return

	_last_damage_number_time = now
	var label := Label.new()
	label.text = str(damage)
	label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	label.add_theme_font_size_override("font_size", 11)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.z_index = 2
	self.get_tree().get_current_scene().add_child(label)
	label.call_deferred("set_global_position", self.global_position + Vector2(0, -24))
	var tween := label.create_tween()
	tween.tween_property(label, "modulate:a", 0, 0.5)
	tween.finished.connect(label.queue_free)
