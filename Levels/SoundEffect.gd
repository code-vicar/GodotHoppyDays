extends AudioStreamPlayer

onready var coin_sound = load("res://Assets/SFX/coin_SFX.wav")

func _on_Coin_collect():
	stream = coin_sound
	play()
