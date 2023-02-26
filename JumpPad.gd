extends Area2D

var PAD_POWER = 2

onready var sprite = $AnimatedSprite
onready var spring_body = $SpringBody
onready var collision_resting = $SpringBody/BoundingBoxResting
onready var collision_compressed = $SpringBody/BoundingBoxCompressed
onready var collision_sprung = $SpringBody/BoundingBoxSprung

var was_compressed := false
var bodies_on_pad: Array = []

enum frame {
	resting = 0
	compressed = 1
	sprung = 2
}

func _ready():
	sprite.frame = frame.resting
	collision_resting.set_deferred("disabled", false)
	collision_compressed.set_deferred("disabled", true)
	collision_sprung.set_deferred("disabled", true)
	pass

func _on_AnimatedSprite_frame_changed():
	var collision_resting_disabled = true
	var collision_compressed_disabled = true
	var collision_sprung_disabled = true
	
	if (sprite.frame == frame.resting):
		collision_resting_disabled = false
	elif (sprite.frame == frame.compressed):
		if !was_compressed:
			was_compressed = true
			self.position.y += 20
		collision_compressed_disabled = false
	else:
		if was_compressed:
			was_compressed = false
			self.position.y -= 20
		spring_body
		for body in bodies_on_pad:
			if body.has_method("hit_by_jump_pad"):
				body.hit_by_jump_pad(PAD_POWER)
		collision_sprung_disabled = false

	collision_resting.set_deferred("disabled", collision_resting_disabled)
	collision_compressed.set_deferred("disabled", collision_compressed_disabled)
	collision_sprung.set_deferred("disabled", collision_sprung_disabled)

func _on_JumpPad_body_entered(body: KinematicBody2D):
	bodies_on_pad.append(body)
	if not sprite.is_playing():
		sprite.frame = frame.compressed
		sprite.play()

func _on_JumpPad_body_exited(body: KinematicBody2D):
	bodies_on_pad.erase(body)

func _on_AnimatedSprite_animation_finished():
	yield(get_tree().create_timer(1.0), "timeout")
	sprite.stop()
	sprite.frame = frame.resting
