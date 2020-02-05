extends KinematicBody2D

onready var Player = get_parent().get_node("Player")

enum CART_STATES {
	IDLE,
	PULLED,
	PUSHED
}

var state: int = CART_STATES.IDLE
var motion: Vector2 = Vector2()
var pushMagnitude: int = 20
var speed: int = 40
var target: Vector2 = Vector2()
var minDist: float = 10.0
var maxDist: float = 30.0

# Weights for various part types
enum WEIGHTS {
	SMALL = 1,
	MEDIUM = 2,
	LARGE = 3
}

# Assign weight value (larger part => slower movement)
const WEIGHT_MODIFIER = {
	SMALL = 0.6,
	MEDIUM = 0.4,
	LARGE = 0.2
}

# Store current weight
var weight = self.WEIGHTS.LARGE


func _ready():
	pass

func _physics_process(delta):
	ai_sense_env()
	if self.state == CART_STATES.PULLED:
		var d = self.position.distance_to(target)
		if d > maxDist: # break free
			self.released()
			Player.release_cart(self)
		else: # follow
			if d > minDist:
				ai_move_toward(target, delta)
	elif self.state == CART_STATES.PUSHED:
		react_to_push(target)

func ai_sense_env():
	self.target = Player.position

func ai_move_toward(_target, _delta):
	# get vector to target
	motion = _target - self.position
	motion = motion.normalized() * speed

	# move
	move_and_slide(motion)

func react_to_push(_target):
	motion = self.position - _target
	motion = motion.normalized() * pushMagnitude
	
	move_and_slide(motion)
	self.state = CART_STATES.IDLE

# set to PULLED state
func grabbed():
	self.state = CART_STATES.PULLED

# set to IDLE state
func released():
	self.state = CART_STATES.IDLE

# set to PUSHED state
func pushed():
	if self.state != CART_STATES.PULLED:
		self.state = CART_STATES.PUSHED

