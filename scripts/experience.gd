extends Node2D

@onready var sprite := $AnimatedSprite2D
@onready var shadow := $Sprite2D
@onready var pickup_area := $PickUpArea
@onready var bubble := $Bubble

func _ready() -> void:
	original_y = sprite.position.y

func _physics_process(delta: float) -> void:
	self._magnet_to_target(delta)
	self._absorb(delta)

func _process(delta: float) -> void:
	self._bob(delta)

var bob_amplitude := 1.0  # How high the jump is
var bob_speed := 8.0      # How fast the bob is
var bob_time := 0.0
var original_y := 0.0

func _bob(delta: float) -> void:
	if self.magnet_target: return # Don't bob if magnet is active

	self.bob_time += delta * self.bob_speed
	var bob_offset := sin(self.bob_time) * self.bob_amplitude
	self.sprite.position.y = self.original_y + bob_offset

	# Shadow scales and fades based on bobbing
	var base_scale := Vector2(0.5, 0.19)
	var min_scale := 0.7
	var max_scale := 1.1
	var min_alpha := 0.4
	var max_alpha := 0.8
	var t = (bob_offset + self.bob_amplitude) / (2.0 * self.bob_amplitude) # 0 at top, 1 at bottom
	var scale_factor = lerp(min_scale, max_scale, t)
	self.shadow.scale = base_scale * scale_factor
	self.shadow.modulate.a = lerp(min_alpha, max_alpha, t)


func _on_pick_up_area_body_entered(body: Node2D) -> void:
	self.magnet_target = body

var magnet_target: Node2D = null
var magnet_strength := 20000.0 # base strength, tweak as needed

func _magnet_to_target(delta: float) -> void:
	if not self.magnet_target:
		return  # No target to attract to

	var to_target = self.magnet_target.global_position - self.global_position
	var distance = to_target.length()

	# Magnet force increases as distance decreases
	var force = self.magnet_strength / max(distance, 1.0)
	var move = to_target.normalized() * force * delta
	# Don't overshoot
	if move.length() > distance:
		move = to_target
	self.global_position += move


var is_absorbing := false
var absorb_timer := 0.0
const ABSORB_DURATION := 0.12

func _on_bubble_body_entered(_body: Node2D) -> void:
	Player.experience += 1.0
	self.is_absorbing = true
	self.absorb_timer = ABSORB_DURATION

func _absorb(delta: float) -> void:
	if not self.is_absorbing: return

	self.absorb_timer -= delta
	var t = clamp(self.absorb_timer / ABSORB_DURATION, 0, 1)
	self.scale = Vector2.ONE * lerp(0.1, 1.0, t)
	if self.absorb_timer <= 0.0:
		Player.exp_bubble_count -= 1
		self.queue_free()
