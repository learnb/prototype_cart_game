extends KinematicBody2D

onready var ray = $RayCast2D

enum PLAYER_STATES {
	IDLE,
	WALK,
	ATTACK,
	HOLDING,
	PULLING
}

var state: int = PLAYER_STATES.IDLE
var motion: Vector2 = Vector2()
var speed: int = 80
var rayVec: Vector2 = Vector2()
var rayLength = 10

func _ready():
	pass

func _physics_process(_delta):
	get_input()
	check_collision()
	move_and_slide(self.motion)

func get_input():
	# Detect up/down/left/right keystate and only move when pressed.
	self.motion = Vector2()
	self.rayVec = Vector2(0,0)

	if Input.is_action_pressed('player_right'):
		self.motion.x += 1
		self.rayVec.x += rayLength
	if Input.is_action_pressed('player_left'):
		self.motion.x -= 1
		self.rayVec.x -= rayLength
	if Input.is_action_pressed('player_down'):
		self.motion.y += 1
		self.rayVec.y += rayLength
	if Input.is_action_pressed('player_up'):
		self.motion.y -= 1
		self.rayVec.y -= rayLength
	
	ray.set_cast_to(self.rayVec)
	self.motion = self.motion.normalized() * speed

func check_collision():
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.is_in_group("Enemy"):
			print("Player hit Enemy")
		elif collider.is_in_group("Pickup"):
			print("Player hit Pickup")
		elif collider.is_in_group("Cart"):
			print("Player hit Cart")
		else:
			print("Player hit something else")
