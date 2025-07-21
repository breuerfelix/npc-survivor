extends Node2D

@onready var shooting_point := $WeaponPivot/Sprite2D/ShootingPoint
@onready var outer_circle := $OuterCircle
@onready var inner_circle := $InnerCircle
var bullet := preload("res://combat/scenes/bullet.tscn")

var current_target: Node = null

func _process(_delta: float) -> void:
	$Timer.wait_time = Player.staff_attack_speed

func _physics_process(_delta: float) -> void:
	var enemies = self.outer_circle.get_overlapping_areas()
	var invert_enemies = self.inner_circle.get_overlapping_areas()
	var filtered_enemies := []
	for enemy in enemies:
		if not invert_enemies.has(enemy):
			filtered_enemies.append(enemy)

	if filtered_enemies.size() > 0:
		if not filtered_enemies.has(self.current_target):
			filtered_enemies.shuffle()
			self.current_target = filtered_enemies.front()

		var target_angle = $WeaponPivot.global_position.angle_to_point(self.current_target.global_position)
		$WeaponPivot.rotation = lerp_angle($WeaponPivot.rotation, target_angle, 0.2)
		$Timer.paused = false
	else:
		$Timer.paused = true
		self.current_target = null

func shoot() -> void:
	var new_bullet := self.bullet.instantiate()
	new_bullet.global_position = self.shooting_point.global_position
	new_bullet.global_rotation = self.shooting_point.global_rotation
	self.shooting_point.add_child(new_bullet)

func _on_timer_timeout() -> void:
	self.shoot()
