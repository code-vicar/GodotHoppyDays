extends Node2D

var lives := 3

func _ready():
	add_to_group("Gamestate")
	
func lose_life():
	lives -= 1
	if lives <= 0:
		game_over()

func game_over():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Levels/GameOver.tscn")
