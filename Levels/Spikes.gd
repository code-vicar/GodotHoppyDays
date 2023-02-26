extends Area2D

func _on_Spikes_body_entered(body):
	get_tree().call_group("Gamestate", "lose_life")
	if body.has_method("hurt"):
		body.hurt()
