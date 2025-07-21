extends Button

@onready var vbox := %VBoxContainer
@onready var label := %Label

func init(upgrade) -> void:
	var expand_fill := Control.SIZE_EXPAND | Control.SIZE_FILL
	var iconSprite = upgrade.icon.instantiate()

	iconSprite.size_flags_vertical = expand_fill
	iconSprite.size_flags_horizontal = expand_fill

	self.vbox.add_child(iconSprite)
	self.vbox.move_child(iconSprite, 0)
	self.label.text = upgrade.text
	self.label.size_flags_vertical = expand_fill
	self.label.size_flags_horizontal = expand_fill
	self.label.autowrap_mode = TextServer.AUTOWRAP_WORD
	self.label.align = HORIZONTAL_ALIGNMENT_CENTER
	self.label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
