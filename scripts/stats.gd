extends Node

var enemies_killed := 1
var damage_dealt := 0.0
var damage_taken := 0.0
var life_steal := 0.0
var playtime := 0.0

func _process(delta: float) -> void:
    self.playtime += delta