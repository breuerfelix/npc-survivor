extends Control

@onready var stats_label := $%Stats

func _ready() -> void:
	Player.death.connect(self._on_death)
	self.set_process_unhandled_key_input(true)

func _unhandled_key_input(event: InputEvent):
	if self.visible and event.is_action_pressed("quit"):
		self._on_button_pressed()

func _on_button_pressed() -> void:
	self.get_tree().quit()

func _on_death() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.get_tree().paused = true
	
	# popup from middle animation
	self.pivot_offset = self.size * 0.5
	create_tween().tween_property(self, "modulate:a", 1, 0.25).from(0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.25).from(Vector2(0.2, 0.2)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var stats_text = "level: " + str(Player.level)
	stats_text += "\nenemies killed: " + str(int(Stats.enemies_killed))
	stats_text += "\ndamage dealt: " + str(int(Stats.damage_dealt))
	stats_text += "\ndamage taken: " + str(int(Stats.damage_taken))
	stats_text += "\nlife steal: " + str(int(Stats.life_steal))
	stats_text += "\nplaytime: " + str(int(Stats.playtime))
	self.stats_label.text = stats_text
	self.visible = true
