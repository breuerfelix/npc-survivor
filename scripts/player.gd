extends Node

var max_health := 100.0
var health := 100.0

# enemy damage
var damage_rate := 3.0
var damage_rate_addition := 0.0
var enemy_speed_multiplier := 1.0
var enemy_bullet_multiplier := 1.2

# level and experience
var experience := 0.0
var experience_threshold := 10.0
var level := 1
signal level_up
signal upgrade_finished
signal death

var speed := 120.0
var dash_cooldown := 0.4
var dash_speed := 450.0

# melee
var melee_damage := 1.0
var life_steal := 0.0

# aura
var fire_aura_damage := 0.0
var fire_aura_radius := 0.0
var fire_aura_speed := 0.0
signal create_fire_aura

# staff
var staff_count := 0
var staff_attack_speed := 0.0
var staff_attack_damage := 0.0
signal create_staff

# some globals for easier access
const max_enemies := 100
var enemy_count := 1
const max_exp_bubbles := 100
var exp_bubble_count := 1
const max_enemy_bullets := 80
var enemy_bullet_count := 1

func _ready() -> void:
	self.upgrade_finished.connect(self._on_upgrade_finished)
	self.level_up.connect(self._on_level_up)
	self.create_staff.connect(self._on_create_staff)

func _process(_delta: float) -> void:
	if self.experience >= self.experience_threshold:
		self.level_up.emit()
		
	if self.health <= 0.0:
		self.death.emit()

func _on_level_up() -> void:
	self.get_tree().paused = true
	self.experience = 0.0
	var exp_rate := 1.0 if OS.is_debug_build() else 1.3
	self.experience_threshold = 10 + pow(self.level, exp_rate)
	self.level += 1
	self.health = self.max_health
	self.damage_rate += 0.3 + self.damage_rate_addition
	self.melee_damage += 0.2

func _on_upgrade_finished() -> void:
	get_tree().paused = false
	
# upgrades
func _create_fire_aura_if_not_exists() -> void:
	var create := false
	if self.fire_aura_damage == 0.0:
		create = true
		self.fire_aura_damage = 20.0

	if self.fire_aura_radius == 0.0:
		create = true
		self.fire_aura_radius = 1.0

	if self.fire_aura_speed == 0.0:
		create = true
		self.fire_aura_speed = 1.0

	if create:
		self.create_fire_aura.emit()

func _create_staff_if_not_exists(only_check: bool = false) -> void:
	var create := false
	if self.staff_attack_speed == 0.0:
		create = true
		self.staff_attack_speed = 0.5

	if self.staff_attack_damage == 0.0:
		create = true
		self.staff_attack_damage = 1.0

	if only_check: return
	if create: self.create_staff.emit()

func _on_create_staff() -> void:
	self.staff_count += 1

func get_upgrade_options() -> Array:
	var available_upgrades := [
		{
			"text": "Maximum Health +50",
			"icon": preload("res://ui/level-up/icons/heart.tscn"),
			"upgrade_func": func(): self.max_health += 50.0; self.health += 50.0,
			"condition": func(): return self.max_health < 500.0,
		},
		{
			"text": "Movement Speed +10",
			"icon": preload("res://ui/level-up/icons/speed.tscn"),
			"upgrade_func": func(): self.speed += 10.0,
			"condition": func(): return self.speed < 200.0 and self.level > 10,
		},
		{
			"text": "Dash Distance +5",
			"icon": preload("res://ui/level-up/icons/speed.tscn"),
			"upgrade_func": func(): self.dash_speed += 5.0,
			"condition": func(): return self.dash_speed < 500.0 and self.level > 20,
		},
		{
			"text": "Dash Cooldown -0.05",
			"icon": preload("res://ui/level-up/icons/speed.tscn"),
			"upgrade_func": func(): self.dash_cooldown -= 0.05,
			"condition": func(): return self.dash_cooldown > 0.25 and self.level > 30,
		},
		{
			"text": "Life Steal +0.05",
			"icon": preload("res://ui/level-up/icons/life-steal.tscn"),
			"upgrade_func": func(): self.life_steal += 0.05,
			"condition": func(): return self.life_steal < 0.5,
		},
		{
			"text": "Create Fire Aura",
			"icon": preload("res://ui/level-up/icons/fire-aura.tscn"),
			"upgrade_func": func(): self._create_fire_aura_if_not_exists(),
			"condition": func(): return self.fire_aura_damage == 0.0 and self.level > 50,
		},
		{
			"text": "Fire Aura +20.0 Damage",
			"icon": preload("res://ui/level-up/icons/fire-aura.tscn"),
			"upgrade_func": func(): self.fire_aura_damage += 20.0,
			"condition": func(): return self.fire_aura_damage > 0.0 and self.fire_aura_damage < 200.0,
		},
		{
			"text": "Fire Aura +0.5 Radius",
			"icon": preload("res://ui/level-up/icons/fire-aura.tscn"),
			"upgrade_func": func(): self.fire_aura_radius += 0.5,
			"condition": func(): return self.fire_aura_damage > 0.0 and self.fire_aura_radius < 3.0,
		},
		{
			"text": "Fire Aura +2.0 Speed",
			"icon": preload("res://ui/level-up/icons/fire-aura.tscn"),
			"upgrade_func": func(): self.fire_aura_speed += 2.0,
			"condition": func(): return self.fire_aura_damage > 0.0 and self.fire_aura_speed < 10.0,
		},
		{
			"text": "Add Staff",
			"icon": preload("res://ui/level-up/icons/staff.tscn"),
			"upgrade_func": func(): 
				self._create_staff_if_not_exists(true)
				self.create_staff.emit(),
			"condition": func(): return self.staff_count < 10,
		},
		{
			"text": "Staff Cooldown -0.05",
			"icon": preload("res://ui/level-up/icons/staff.tscn"),
			"upgrade_func": func(): self.staff_attack_speed = max(0.05, self.staff_attack_speed - 0.05),
			"condition": func(): return self.staff_attack_damage > 0.0 && self.staff_attack_speed > 0.05,
		},
		{
			"text": "Staff Attack Damage +1.0",
			"icon": preload("res://ui/level-up/icons/staff.tscn"),
			"upgrade_func": func(): self.staff_attack_damage += 1.0,
			"condition": func(): return self.staff_attack_damage > 0.0 and self.staff_attack_damage < 20.0,
		},
		{
			"text": "Enemy Damage Rate +0.1",
			"icon": preload("res://ui/level-up/icons/enemy.tscn"),
			"upgrade_func": func(): self.damage_rate_addition += 0.1,
			"condition": func(): return self.level > 80,
		},
		{
			"text": "Enemy Speed Multiplier +0.05",
			"icon": preload("res://ui/level-up/icons/enemy.tscn"),
			"upgrade_func": func(): self.enemy_speed_multiplier += 0.05,
			"condition": func(): return self.level > 80,
		},
		{
			"text": "Enemy Bullet Multiplier +0.05",
			"icon": preload("res://ui/level-up/icons/enemy.tscn"),
			"upgrade_func": func(): self.enemy_bullet_multiplier += 0.05,
			"condition": func(): return self.level > 80,
		},
	]

	var filtered := available_upgrades.filter(func(u): return u["condition"].call())
	filtered.shuffle()
	return filtered.slice(0, 3)
