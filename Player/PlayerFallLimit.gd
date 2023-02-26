extends Node

var timer: SceneTreeTimer

func _on_Player_falling(is_falling: bool):
	if is_falling:
		timer = get_tree().create_timer(10)
		timer.connect("timeout", self, "_on_timer_up")
	elif timer and timer.is_connected("timeout", self, "_on_timer_up"):
		timer.disconnect("timeout", self, "_on_timer_up")

func _on_timer_up():
	get_tree().change_scene("res://Levels/GameOver.tscn")
