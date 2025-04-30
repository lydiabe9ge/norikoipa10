extends Area2D
class_name Udon

@onready var frozen_sprite: Sprite2D = $FrozenUdonSprite
@onready var regular_sprite: Sprite2D = $RegularUdonSprite

var dragging := false
var original_position: Vector2
var offset: Vector2 = Vector2.ZERO
var is_in_sink := false

func _ready():
	original_position = global_position
	regular_sprite.visible = false  # Start with frozen visible
	# Connect to detect when udon enters/exits the Sink area
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			dragging = true
			offset = get_global_mouse_position() - global_position
		elif not event.pressed and dragging:
			dragging = false
			if is_in_sink:
				trigger_sink_interaction()
			else:
				reset_position()

func _process(_delta):  # ✅ Fix by adding "_" before delta
	if dragging:
		global_position = get_global_mouse_position() - offset

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Sink":
		is_in_sink = true
		print("Udon entered sink area.")

func _on_area_exited(area: Area2D) -> void:
	if area.name == "Sink":
		is_in_sink = false
		print("Udon left sink area.")

func trigger_sink_interaction() -> void:
	# Get the Sink node (adjust the path as needed)
	var sink = get_node("/root/CookingMiniGame/Sink")
	if sink:
		sink.play_water_animation()
	# Wait 3 seconds then transform the udon from frozen to regular
	await get_tree().create_timer(3.0).timeout
	transform_udon()

func transform_udon() -> void:
	frozen_sprite.visible = false
	regular_sprite.visible = true
	print("Udon transformed from frozen to regular.")
	reset_position()

func reset_position() -> void:
	global_position = original_position
