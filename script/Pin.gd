extends Area2D

signal knocked_down(pin)

var has_fallen = false

func _ready():
	add_to_group("pins")

func hit_by_ball():
	if has_fallen:
		return

	has_fallen = true
	
	remove_from_group("pins")

	emit_signal("knocked_down", self)

	var tween = Tween.new()
	add_child(tween)

	var direction = [-1, 1][randi() % 2]

	tween.interpolate_property(
		self,
		"rotation_degrees",
		0,
		direction * 85,
		0.35,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)

	tween.interpolate_property(
		self,
		"position",
		position,
		position + Vector2(direction * 35, 15),
		0.35,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)

	tween.interpolate_property(
		self,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		0.35,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		0.15
	)

	tween.start()

	yield(tween, "tween_all_completed")
	queue_free()
