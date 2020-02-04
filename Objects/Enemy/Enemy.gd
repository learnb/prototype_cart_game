extends KinematicBody2D

onready var ray = $RayCast2D
onready var Cart = get_parent().get_node("Cart")

enum ENEMY_STATES {
	IDLE,
	WALK,
	ATTACK,
	HOLDING,
	STUN
}

var state: int = ENEMY_STATES.IDLE
var motion: Vector2 = Vector2()
var speed: int = 80
var rayVec: Vector2 = Vector2()
var rayLength = 10
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
	ai_move_toward(target, delta)

func ai_sense_env():
	if self.state != ENEMY_STATES.HOLDING:
		self.target = Cart.position
	else:
		pass

func ai_move_toward(_target, _delta):
	# get vector to target
	motion = _target - self.position
	motion = motion.normalized()
	ray.set_cast_to(motion * rayLength)

	# determine speed
	if self.state == ENEMY_STATES.HOLDING:
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
	if ray.is_colliding():
		if ray.get_collider().is_in_group("Cart"):
			on_collide_cart()
		if ray.get_collider().is_in_group("Player"):
			on_collide_player()

func on_collide_cart():
	if self.state != ENEMY_STATES.HOLDING:
		print("Enemy hit cart")
		self.state = ENEMY_STATES.HOLDING
		self.partType = WEIGHTS.MEDIUM
		
		# Set new target (turn around and move far away)
		target = (target - self.position) * -1
		target = target.normalized() * 2000

func on_collide_player():
	if self.state == ENEMY_STATES.HOLDING:
		print("Enemy hit player")
		self.state = ENEMY_STATES.IDLE

func on_attacked_by_player():
	self.call_deferred("queue_free")
