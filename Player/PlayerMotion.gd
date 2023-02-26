extends Reference

class_name PlayerMotion

var VELOCITY: Vector2 setget setVelocity, getVelocity
var is_on_floor: bool setget setIsOnFloor, getIsOnFloor

func _init(init_velocity: Vector2, init_is_on_floor: bool):
	VELOCITY = init_velocity
	is_on_floor = init_is_on_floor

func setVelocity(_x):
	push_warning("Attempting to set read only variable")
func getVelocity():
	return VELOCITY
		
func setIsOnFloor(_x):
	push_warning("Attempting to set read only variable")
func getIsOnFloor():
	return is_on_floor
