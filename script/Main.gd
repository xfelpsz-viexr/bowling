extends Node2D

const BALL_SCENE = preload("res://scene/Ball.tscn")
const PIN_SCENE = preload("res://scene/Pin.tscn")

var score = 0
var ball = null
var round_active = true

onready var player = $Player
onready var player_sprite = $Player/Sprite
onready var pins = $Pins
onready var score_label = $CanvasLayer/ScoreLabel
#onready var message_label = $CanvasLayer/MessageLabel
onready var remaing_label = $CanvasLayer/RemaingLabel
onready var ball_sfx = $ball_sfx as AudioStreamPlayer2D
onready var anus_sfx = $anus_sfx as AudioStreamPlayer2D
onready var pin_sfx = $pin_sfx as AudioStreamPlayer2D
onready var jump_sfx = $jump_sfx as AudioStreamPlayer2D


func _ready():
	create_pins()
	update_score()
	#message_label.text = "Setas: mover | Espaço: lançar"
	remaing_label.text = "Pinos restantes: 10"

func _process(_delta):
	if Input.is_action_just_pressed("launch"):
		launch_ball()
		ball_sfx.play()
	if Input.is_action_just_pressed("restart"):
		reset()

func create_pins():
	
	var rows = 4
	var spacing = 35.0
	
	for row in range(rows):
		for col in range(row + 1):
			var pin = PIN_SCENE.instance()
			pin.position.x = row * spacing
			pin.position.y = (col - row / 2.0) * spacing
			pin.add_to_group("pins")
			pin.connect("knocked_down", self, "_on_pin_knocked_down")
			pins.add_child(pin)

func launch_ball():
	player_sprite.play("Launch")
	
	if not round_active or is_instance_valid(ball):
		return

	ball = BALL_SCENE.instance()
	add_child(ball)
	
	var direction = clamp((player.global_position.y - 240.0) / 180.0, -1.0, 1.0)
	
	var start_position = player.global_position
	start_position.x += 20

	ball.launch(start_position, direction)
	ball.connect("reached_end", self, "_on_ball_reached_end")
	ball.connect("returned_to_player", self, "_on_ball_returned")

	player.can_move = false
	#message_label.text = "Bola lançada!"

func _on_pin_knocked_down(pin):
	pin_sfx.play()
	score += 1
	update_score()

func update_score():
	$CanvasLayer/ScoreLabel.text = "Pinos derrubados: " + str(score)

func _on_ball_reached_end():
	var remaining_pins = get_tree().get_nodes_in_group("pins").size()
	remaing_label.text = "Pinos restantes: " + str(remaining_pins)

	if remaining_pins > 0:
		ball.return_to_player(player.global_position)
		#message_label.text = "Bola retornando!"
	else:
		round_active = false
		get_tree().change_scene("res://scene/Final.tscn")
		#message_label.text = "Todos os pinos foram derrubados!"

func _on_ball_returned():
	ball.queue_free()
	ball = null
	anus_sfx.play()
	player.can_move = true
	
	#message_label.text = "Prepare o próximo lançamento!"

func reset():
	get_tree().change_scene("res://scene/Main.tscn")
