extends AnimatedSprite

func _on_Player_animate(motion: PlayerMotion):
	flip_h = false
	if not motion.is_on_floor and motion.VELOCITY.y < 0:
		play("jump")
	elif motion.is_on_floor and motion.VELOCITY.x > 0:
		play("walk")
	elif motion.is_on_floor and motion.VELOCITY.x < 0:
		flip_h = true
		play("walk")
	else:
		play("idle")
