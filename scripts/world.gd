extends Node2D

var pointer := preload("res://assets/cursors/pointer.png")

func _ready() -> void:
	self._set_pointer()
	
	if OS.is_debug_build():
		var size = Vector2i(3000, 2000)
		DisplayServer.window_set_size(size)
		# Center window on screen
		var screen_rect = DisplayServer.screen_get_usable_rect()
		var pos = screen_rect.position + (screen_rect.size - size) / 2
		DisplayServer.window_set_position(pos)

func _set_pointer() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var pointer_tex = self.pointer
	var pointer_scale := 2 # Increase pointer size by 2x
	var img = pointer_tex.get_image()
	img.resize(img.get_width() * pointer_scale, img.get_height() * pointer_scale, Image.INTERPOLATE_NEAREST)
	var big_pointer = ImageTexture.create_from_image(img)
	Input.set_custom_mouse_cursor(big_pointer)
