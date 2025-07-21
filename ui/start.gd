extends Control

func _ready() -> void:
	self.set_process_unhandled_key_input(true)
	self.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.get_tree().paused = true

func _unhandled_key_input(event: InputEvent):
	if event.is_action_pressed("accept"):
		self._on_button_pressed() 

func _on_button_pressed() -> void:
	self.get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	self.queue_free()
