extends Camera2D

@export var zoom_speed := 0.2
@export var min_zoom := 2.0
@export var max_zoom := 12.0

var zoom_level := 0.0

func _ready() -> void:
	self.zoom_level = self.zoom.x

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		zoom_level -= zoom_speed
		zoom_level = clamp(zoom_level, min_zoom, max_zoom)
		self.zoom = Vector2(zoom_level, zoom_level)
	elif event.is_action_pressed("zoom_out"):
		zoom_level += zoom_speed
		zoom_level = clamp(zoom_level, min_zoom, max_zoom)
		self.zoom = Vector2(zoom_level, zoom_level)
