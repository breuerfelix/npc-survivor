extends Area2D

const SPEED := 400
const RANGE := 1200
const DAMAGE := 1

var travelled_distance := 0.0

func _ready() -> void:
	self.area_entered.connect(self._on_area_entered)

func _physics_process(delta: float) -> void:
	var direction := Vector2.RIGHT.rotated(self.rotation)
	self.position += direction * SPEED * delta
	self.travelled_distance += SPEED * delta
	if self.travelled_distance > RANGE:
		self.queue_free()

func _on_area_entered(area: Area2D) -> void:
	area.get_parent().take_damage(Player.staff_attack_damage)
	Player.health += Player.life_steal
	Stats.life_steal += Player.life_steal
