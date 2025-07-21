extends CharacterBody2D

const DASH_DURATION := 0.1

var animation := "idle_down"
@onready var sprite := $AnimatedSprite2D

# Dash ability variables
var is_dashing := false
var dash_time := 0.0
var dash_direction := Vector2.ZERO
var dash_cooldown := 0.0

# attacking
var is_attacking := false

# collision
var col_layer: int
var col_mask: int


func _ready() -> void:
	$ProgressBar.max_value = Player.health
	$ExperienceProgressBar.max_value = Player.experience_threshold
	$ExperienceProgressBar.value = 0.0
	self.col_layer = self.collision_layer
	self.col_mask = self.collision_mask
	self.sprite.frame_changed.connect(_on_attack_frame_changed)
	Player.create_fire_aura.connect(self._on_create_fire_aura)
	Player.level_up.connect(self._on_level_up)
	Player.create_staff.connect(self._on_create_staff)

func _process(_delta: float) -> void:
	$ExperienceProgressBar.value = Player.experience
	$ProgressBar.value = Player.health

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	self._try_start_dash(direction, delta)
	self._process_dash(delta)
	self._process_damage(delta)
	self._process_melee_attack(direction)
	self._process_movement(direction)
	self.move_and_slide()

func _process_melee_attack(direction: Vector2) -> void:
	self.is_attacking = false
	if self.is_dashing: return
	if direction.length() > 0: return
	var melee_enemies = $MeleeBox.get_overlapping_areas()
	if melee_enemies.size() <= 0: return

	self._start_melee_attack_facing_enemy(melee_enemies)

func _start_melee_attack_facing_enemy(enemies: Array) -> void:
	# Pick the first enemy in the array
	var enemy = enemies[0]
	var to_enemy = enemy.global_position - self.global_position
	var anim = "attack_"
	if abs(to_enemy.x) > abs(to_enemy.y):
		anim += "right" if to_enemy.x > 0 else "left"
	else:
		anim += "down" if to_enemy.y > 0 else "up"
	self.animation = anim
	self.is_attacking = true
	sprite.play(anim)

func _on_attack_frame_changed():
	if not self.is_attacking: return
	if not self.animation.begins_with("attack"): return

	# Only deal damage on frame 3 of attack animation
	if sprite.frame != 3: return

	var melee_enemies = $MeleeBox.get_overlapping_areas()
	var facing = self.animation.replace("attack_", "")
	for enemy in melee_enemies:
		var to_enemy = (enemy.global_position - self.global_position).normalized()
		const threshold := 0.7
		match facing:
			"right":
				if to_enemy.x < threshold: continue
			"left":
				if -to_enemy.x < threshold: continue
			"down":
				if to_enemy.y < threshold: continue
			"up":
				if -to_enemy.y < threshold: continue

		enemy.get_parent().take_damage(Player.melee_damage)
		Player.health += Player.life_steal
		Stats.life_steal += Player.life_steal

func _try_start_dash(direction: Vector2, delta: float) -> void:
	# calculate cooldown
	if dash_cooldown > 0.0:
		dash_cooldown -= delta

	if self.is_dashing: return
	if dash_cooldown > 0.0: return
	if not Input.is_action_just_pressed("dash"): return
	if direction.length() <= 0: return

	is_dashing = true
	dash_time = DASH_DURATION
	dash_direction = direction.normalized()
	dash_cooldown = Player.dash_cooldown

func _process_dash(delta: float) -> void:
	if not self.is_dashing: return
	
	dash_time -= delta
	self.velocity = dash_direction * Player.dash_speed
	self._play_dash_animation()
	self.set_collision_layer(0)
	self.set_collision_mask(1)
	if dash_time <= 0.0:
		is_dashing = false
		self.set_collision_layer(self.col_layer)
		self.set_collision_mask(self.col_mask)

func _play_dash_animation() -> void:
	if abs(dash_direction.x) > abs(dash_direction.y):
		self.animation = "dash_right" if dash_direction.x > 0 else "dash_left"
	else:
		self.animation = "dash_down" if dash_direction.y > 0 else "dash_up"
	self.sprite.play(self.animation)

func _process_movement(direction: Vector2) -> void:
	if self.is_dashing: return

	var is_moving := false
	if direction.x > 0:
		self.animation = "move_right"
		is_moving = true
	elif direction.x < 0:
		self.animation = "move_left"
		is_moving = true
	elif direction.y > 0:
		self.animation = "move_down"
		is_moving = true
	elif direction.y < 0:
		self.animation = "move_up"
		is_moving = true

	if not is_moving and not self.is_attacking:
		var parts = self.animation.split("_")
		self.animation = "idle_" + parts[parts.size() - 1]

	self.sprite.play(self.animation)
	self.velocity = direction * Player.speed

func _process_damage(delta: float) -> void:
	var touching_enemies = $HurtBox.get_overlapping_areas()
	var damage = Player.damage_rate * touching_enemies.size() * delta
	Player.health -= damage
	Stats.damage_taken += damage

func _on_level_up() -> void:
	$ExperienceProgressBar.value = 0.0
	$ExperienceProgressBar.max_value = Player.experience_threshold

#region Auras
var fire_aura_ref: Node = null

func _on_create_fire_aura() -> void:
	var aura_scene := preload("res://combat/scenes/aura.tscn")
	var fire_scene := preload("res://combat/scenes/fire-animation.tscn")
	var aura := aura_scene.instantiate()
	var fire := fire_scene.instantiate()
	aura.add_child(fire)
	self.add_child(aura)
	fire_aura_ref = aura
#endregion

#region Staff
func _on_create_staff() -> void:
	var staff_scene := preload("res://combat/scenes/staff.tscn")
	var staff := staff_scene.instantiate()
	self.add_child(staff)
#endregion
