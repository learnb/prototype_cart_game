extends KinematicBody2D

onready var Player = get_parent().get_node("Player")

enum CART_STATES {
	IDLE,
	PULLED
}

var state: int = CART_STATES.IDLE
var motion: Vector2 = Vector2()
var speed: int = 80
var target: Vector2 = Vector2()

# Weights for various part types
enum WEIGHTS {
	SMALL = 1,
	MEDIUM = 2,
	LARGE = 3
}

# Assign weight value (larger part => slower movement)
const WEIGHT_VALUE = {
	SMALL = 0.6,
	MEDIUM = 0.4,
	LARGE = 0.2
}

# Store current weight
var partType = self.WEIGHTS.SMALL


func _ready():
	pass

func _physics_process(delta):
	ai_sense_env()
	if self.state == CART_STATES.PULLED:
		ai_move_toward(target, delta)

func ai_sense_env():
	if self.state == CART_STATES.PULLED:
		self.target = Player.position
	else:
		pass

func ai_move_toward(_target, _delta):
	# get vector to target
	motion = _target - self.position
	motion = motion.normalized()

	# determine speed
	if self.state == CART_STATES.PULLED:
		if partType == WEIGHTS.SMALL:
			motion *= (speed * WEIGHT_VALUE.SMALL)
		elif partType == WEIGHTS.MEDIUM:
			motion *= (speed * WEIGHT_VALUE.MEDIUM)
		elif partType == WEIGHTS.LARGE:
			motion *= (speed * WEIGHT_VALUE.LARGE)
	else:
		motion *= speed

	# move
	move_and_slide(motion)

	# detect collision

