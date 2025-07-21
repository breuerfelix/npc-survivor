extends Area2D

var speed := 80.0
var distance := 600.0
var direction := Vector2.ZERO
var traveled := 0.0

func _ready() -> void:
	direction = Vector2.RIGHT.rotated(randf() * TAU)
	self.body_entered.connect(self._on_body_entered)

func _physics_process(delta: float) -> void:
	var move = direction * speed * delta
	position += move
	traveled += move.length()
	if traveled >= distance:
		self._remove()

func _on_body_entered(_body: Node) -> void:
	var dmg := pow(Player.level, Player.enemy_bullet_multiplier)
	Player.health -= dmg
	Stats.damage_taken += dmg
	self._remove()

func _remove() -> void:
	Player.enemy_bullet_count -= 1
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.finished.connect(self.queue_free)
