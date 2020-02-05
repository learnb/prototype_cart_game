extends KinematicBody2D

enum PICKUP_STATES {
	IDLE,
	PUSHED
}

var state: int = PICKUP_STATES.IDLE
var motion: Vector2 = Vector2()
var speed: int = 20
var target: Vector2 = Vector2()

func _ready():
	pass

func _physics_process(delta):
	if self.state == PICKUP_STATES.PUSHED:
		react_to_push(target)

func react_to_push(_target):
	motion = self.position - _target
	motion = motion.normalized() * speed
	
	move_and_slide(motion)
	self.state = PICKUP_STATES.IDLE

# set to PUSHED state
func pushed(_body):
	self.state = PICKUP_STATES.PUSHED
	self.target = _body.position
