extends Node2D

export var speed = 200
export var margin = 150

var can_move = true

func _ready():
	$Sprite.flip_h = true

func _process(delta):
	if not can_move:
		return

	if Input.is_action_pressed("move_left"):
		position.y -= speed * delta
		$Sprite.play("Walk")
	elif Input.is_action_pressed("move_right"):
		position.y += speed * delta
		$Sprite.play("Walk")
	else:
		$Sprite.stop()

	position.y = clamp(position.y, margin, 420 - margin)
