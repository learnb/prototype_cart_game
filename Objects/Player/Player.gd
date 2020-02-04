extends KinematicBody2D

onready var ray = $RayCast2D
onready var weaponArea = $WeaponArea

enum PLAYER_STATES {
	IDLE,
	WALK,
	ATTACK,
	HOLDING,
	PULLING,
	STUN
}

var state: int = PLAYER_STATES.IDLE
var motion: Vector2 = Vector2()
var speed: int = 80
var rayVec: Vector2 = Vector2()
var rayLength = 10

var weaponHittingQueue = Array()

func _ready():
	pass

func _physics_process(_delta):
	get_input()
	move_and_slide(self.motion)
	check_collision()

func get_input():

	# Clear vectors
	self.motion = Vector2()
	self.rayVec = Vector2()
	#weaponArea.position = Vector2()

	# Movement inputs
	if Input.is_action_pressed('player_right'):
		self.motion.x += 1
		self.rayVec.x += rayLength
		weaponArea.position.x = rayLength
	elif Input.is_action_pressed('player_left'):
		self.motion.x -= 1
		self.rayVec.x -= rayLength
		weaponArea.position.x = -1 * rayLength
	if Input.is_action_pressed('player_down'):
		self.motion.y += 1
		self.rayVec.y += rayLength
		weaponArea.position.y = rayLength
	elif Input.is_action_pressed('player_up'):
		self.motion.y -= 1
		self.rayVec.y -= rayLength
		weaponArea.position.y = -1 * rayLength
	
	# Action inputs
	if Input.is_action_just_pressed("player_action"):
		self.state = PLAYER_STATES.ATTACK
	if Input.is_action_just_released("player_action"):
		self.state = PLAYER_STATES.IDLE
	
	ray.set_cast_to(self.rayVec)
	self.motion = self.motion.normalized() * speed
	
	if self.state != PLAYER_STATES.ATTACK:
		if self.motion.x > 0 || self.motion.y > 0:
			self.state = PLAYER_STATES.WALK
		else:
			self.state = PLAYER_STATES.IDLE

func check_collision():
	# Detect walking into bodies
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.is_in_group("Enemy"):
			self.state = PLAYER_STATES.STUN
		elif collider.is_in_group("Pickup"):
			self.state = PLAYER_STATES.HOLDING
		elif collider.is_in_group("Cart"):
			self.state = PLAYER_STATES.PULLING
		else:
			print("Player hit something else")
		#print(self.state)
	
	# Detect hitting bodies with weapon
	if self.state == PLAYER_STATES.ATTACK:
		for b in weaponHittingQueue:
			do_weapon_damage(b)
		weaponHittingQueue.empty()
		self.state = PLAYER_STATES.IDLE

func do_weapon_damage(body):
	if body.is_in_group("Enemy"):
		print("hit Enemy")
	if body.is_in_group("Cart"):
		print("repair Cart")

func _on_Weapon_body_entered(body):
	weaponHittingQueue.append(body)


func _on_Weapon_body_exited(body):
	weaponHittingQueue.remove(weaponHittingQueue.find(body))
