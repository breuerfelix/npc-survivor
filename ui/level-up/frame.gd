extends Control

@onready var color_rect := $ColorRect
@onready var hbox := $HBoxContainer
@onready var level_label := $MarginContainer/LevelLabel
var btn := preload("res://ui/level-up/scenes/button.tscn")
var buttons: Array[Button] = []

func _ready() -> void:
	Player.level_up.connect(self._on_level_up)
	set_process_unhandled_key_input(true)

func _unhandled_key_input(event) -> void:
	if not self.visible: return
	if self.buttons.size() != 3: return

	if event.is_pressed():
		match event.as_text():
			"1":
				buttons[0].emit_signal("pressed")
			"2":
				buttons[1].emit_signal("pressed")
			"3":
				buttons[2].emit_signal("pressed")

func _on_level_up() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.level_label.text = "Level " + str(Player.level)
	self.level_label.add_theme_font_size_override("font_size", 48)

	for upgrade in Player.get_upgrade_options():
		var button := self.btn.instantiate()
		buttons.append(button)
		button.pressed.connect(self._btn_wrapper.bind(upgrade.upgrade_func))
		self.hbox.add_child(button)
		button.init(upgrade)

	# popup from middle
	self.pivot_offset = self.size * 0.5
	# popup frame, scale up and fade in
	self.create_tween().tween_property(self, "modulate:a", 1, 0.25).from(0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	self.create_tween().tween_property(self, "scale", Vector2.ONE, 0.25).from(Vector2(0.6, 0.6)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	self.visible = true

func _btn_wrapper(upgrade_func: Callable) -> void:
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	upgrade_func.call()
	for button in self.buttons:
		button.queue_free()
	self.buttons.clear()

	Player.upgrade_finished.emit()
