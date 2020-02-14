extends StaticBody2D

var health: int

func _ready():
	self.health = 100

func on_attacked_by_player():
	self.health -= 5
	
	if self.health <= 0:
		self.call_deferred("queue_free")
