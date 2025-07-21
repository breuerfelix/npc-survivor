extends Area2D

@onready var collision_shape := $CollisionShape2D
var sprite: AnimatedSprite2D = null

func _ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			self.sprite = child
			break
	self.sprite.frame_changed.connect(_on_sprite_frame_changed)

func _process(_delta: float) -> void:
	var r = Player.fire_aura_radius
	self.sprite.scale = Vector2(r, r)
	self.sprite.speed_scale = Player.fire_aura_speed

func _physics_process(_delta: float) -> void:
	var r = Player.fire_aura_radius
	self.collision_shape.scale = Vector2(r, r)

func _on_sprite_frame_changed() -> void:
	if not sprite: return
	if not sprite.frame == 3: return
	
	var bodies = get_overlapping_areas()
	for body in bodies:
		body.get_parent().take_damage(Player.fire_aura_damage)
		Player.health += Player.life_steal
		Stats.life_steal += Player.life_steal
