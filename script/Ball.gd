extends KinematicBody2D

signal reached_end
signal returned_to_player

export var speed = 170
export var horizontal_power = 80
export var margin = 144
export var bounce_strength = 50.0
var velocity = Vector2()
var launched = false
var returning = false
var impact_slowdown = 0.85
var impact_deviation = 35.0
var return_target = Vector2()
var return_speed = 700.0
var return_phase = 0
var return_bottom_y = 330.0
var rotation_speed = 350.0

func _ready():
	$DetectionArea.connect("area_entered", self, "_on_area_entered")

func launch(start_position, direction):
	global_position = start_position
	velocity = Vector2(speed, direction * horizontal_power)
	launched = true
	returning = false
	
func return_to_player(target_position):
	return_target = target_position
	returning = true
	launched = true
	return_phase = 0

func _physics_process(delta):
	
	position.y = clamp(position.y, margin, 500 - margin)
	
	if not launched:
		return
		
	$Sprite.rotation_degrees += rotation_speed * delta
		
	if returning:
		if return_phase == 0:
			var bottom_position = Vector2(global_position.x, return_bottom_y)

			global_position = global_position.move_toward(
				bottom_position,
				return_speed * delta
			)

			if global_position.distance_to(bottom_position) < 3:
				return_phase = 1

		elif return_phase == 1:
			var horizontal_position = Vector2(return_target.x, return_bottom_y)

			global_position = global_position.move_toward(
				horizontal_position,
				return_speed * delta
			)

			if global_position.distance_to(horizontal_position) < 3:
				return_phase = 2

		elif return_phase == 2:
			global_position = global_position.move_toward(
				return_target,
				return_speed * delta
			)

			if global_position.distance_to(return_target) < 5:
				global_position = return_target
				returning = false
				launched = false
				emit_signal("returned_to_player")
		return

	var collision = move_and_collide(velocity * delta)
	if collision:
		var target = collision.collider
		
		if target.is_in_group("pins"):
			
			var impact_direction = velocity.normalized()
			target.hit_by_ball(impact_direction, 100.0)
			velocity *= 1

	if global_position.x > 700:
		launched = false
		emit_signal("reached_end")

func _on_area_entered(area):
	if area.is_in_group("pins"):
		if area.has_method("hit_by_ball"):
			area.hit_by_ball()
			
			velocity *= impact_slowdown

			var direction = [-1, 1][randi() % 2]
			velocity.y += direction * impact_deviation

			velocity.y = clamp(velocity.y, -100, 100)
