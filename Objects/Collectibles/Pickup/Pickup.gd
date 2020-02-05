extends "res://Objects/Collectibles/Collectibles.gd"

func _ready():
	pass

func collect(_entity):
	.collect(_entity)

func deposit():
	.deposit()

func _on_Pickup_body_entered(body):
	if body.is_in_group("Player"):
		collect(body)
