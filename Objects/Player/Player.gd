extends KinematicBody2D

onready var ray = $RayCast2D
onready var weaponArea = $WeaponArea

enum PLAYER_MOTION_STATES {
	IDLE,
	WALK,
	PULLING,
	STUN
}

enum PLAYER_ACTION_STATES {
	IDLE,
	ATTACK,
	GRAB,
	HOLDING
}

var motion_state: int = PLAYER_MOTION_STATES.IDLE
var action_state: int = PLAYER_ACTION_STATES.IDLE
var motion: Vector2 = Vector2()
var speed: int = 80
var rayVec: Vector2 = Vector2()
var rayLength = 10

var weaponHittingQueue = Array()
var interactAreaQueue = Array()

func _ready():
	weaponArea.position = Vector2(rayLength, 0)

func _physics_process(_delta):
	get_input()
	move_and_slide(self.motion)
	check_collision()

func get_input():

	# Clear vectors
	self.motion = Vector2()
	#self.rayVec = Vector2()
	
	if Input.is_action_pressed('player_right') || Input.is_action_pressed('player_left') || Input.is_action_pressed('player_down') || Input.is_action_pressed('player_up'):
		weaponArea.position = Vector2()
		self.rayVec = Vector2()

	# Movement inputs
	if Input.is_action_pressed('player_right'):
		self.motion.x += 1
		self.rayVec.x += rayLength
		weaponArea.position.x += rayLength
	if Input.is_action_pressed('player_left'):
		self.motion.x -= 1
		self.rayVec.x -= rayLength
		weaponArea.position.x -= rayLength
	if Input.is_action_pressed('player_down'):
		self.motion.y += 1
		self.rayVec.y += rayLength
		weaponArea.position.y += rayLength
	if Input.is_action_pressed('player_up'):
		self.motion.y -= 1
		self.rayVec.y -= rayLength
		weaponArea.position.y -= rayLength
	
	# Action inputs
	if Input.is_action_just_pressed("player_action"):
		if self.motion_state != PLAYER_MOTION_STATES.PULLING:
			self.action_state = PLAYER_ACTION_STATES.ATTACK
	
	# Interact inputs
	if Input.is_action_just_pressed("player_interact"):
		self.action_state = PLAYER_ACTION_STATES.GRAB
	
	# Move
	ray.set_cast_to(self.rayVec)
	
	if self.motion_state == PLAYER_MOTION_STATES.PULLING:
		self.motion = self.motion.normalized() * (speed * 0.2)
	else:
		self.motion = self.motion.normalized() * speed
		
		if self.motion.x > 0 || self.motion.y > 0:
			self.motion_state = PLAYER_MOTION_STATES.WALK
		else:
			self.motion_state = PLAYER_MOTION_STATES.IDLE

func check_collision():
	# Detect walking into bodies
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.is_in_group("Enemy"):
			pass
			#self.state = PLAYER_STATES.STUN
		elif collider.is_in_group("Pickup"):
			pass
			#self.state = PLAYER_STATES.HOLDING
		elif collider.is_in_group("Cart"):
			pass
			#self.state = PLAYER_STATES.PULLING
		else:
			print("Player hit something else")
		#print(self.state)
	
	# Detect hitting bodies with weapon
	if self.action_state == PLAYER_ACTION_STATES.ATTACK:
		for b in weaponHittingQueue:
			do_weapon_action(b)
		weaponHittingQueue.empty()
		if self.motion_state != PLAYER_MOTION_STATES.PULLING:
			self.action_state = PLAYER_ACTION_STATES.IDLE
	# Detect colliding bodies with grab/interact
	elif self.action_state == PLAYER_ACTION_STATES.GRAB:
		for b in interactAreaQueue:
			do_grab_action(b)
		interactAreaQueue.empty()

func do_weapon_action(body):
	if body.is_in_group("Enemy"):
		# damage enemy
		print("Player hit Enemy")
		self.action_state = PLAYER_ACTION_STATES.IDLE
	if body.is_in_group("Cart"):
		# repair cart
		print("Player hit Cart")

func do_grab_action(body):
	if body.is_in_group("Cart"):
		if self.motion_state != PLAYER_MOTION_STATES.PULLING:
			print("pull cart")
			body.state = body.CART_STATES.PULLED
			self.motion_state = PLAYER_MOTION_STATES.PULLING
			self.action_state = PLAYER_ACTION_STATES.IDLE
		elif self.motion_state == PLAYER_MOTION_STATES.PULLING:
			print("release cart")
			body.state = body.CART_STATES.IDLE
			self.motion_state = PLAYER_MOTION_STATES.IDLE
			self.action_state = PLAYER_ACTION_STATES.IDLE

func _on_Weapon_body_entered(body):
	weaponHittingQueue.append(body)

func _on_Weapon_body_exited(body):
	weaponHittingQueue.remove(weaponHittingQueue.find(body))

func _on_InteractArea_body_entered(body):
	interactAreaQueue.append(body)

func _on_InteractArea_body_exited(body):
	interactAreaQueue.remove(interactAreaQueue.find(body))
