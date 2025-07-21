extends Control

func _ready() -> void:
	set_process_unhandled_key_input(true)

func _unhandled_key_input(event):
	if not self.visible and self.get_tree().paused: return

	if event.is_action_pressed("esc"):
		if self.visible:
			self._on_button_pressed()  # Resume game
		else:
			# Pause game and show menu
			self.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

			# popup from middle animation
			self.pivot_offset = self.size * 0.5
			create_tween().tween_property(self, "modulate:a", 1, 0.25).from(0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			create_tween().tween_property(self, "scale", Vector2.ONE, 0.25).from(Vector2(0.2, 0.2)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

			self.get_tree().paused = true
	
	if self.visible:
		if event.is_action_pressed("accept"):
			self._on_button_pressed()
		elif event.is_action_pressed("quit"):
			self._on_button_pressed_quit()

func _on_button_pressed() -> void:
	self.visible = false
	self.get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_button_pressed_quit() -> void:
	self.get_tree().quit()
