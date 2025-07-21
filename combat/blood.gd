extends Node2D

func _ready() -> void:
	# $Static.modulate.a = 0
	# create_tween().tween_property($Static, "modulate:a", 0.6, 0.3)
	# $AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$Static.visible = false
	$AnimatedSprite2D.animation_finished.connect(self.queue_free)

func _on_animation_finished() -> void:
	$AnimatedSprite2D.queue_free()
