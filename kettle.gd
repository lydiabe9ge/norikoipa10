extends CharacterBody2D

@onready var normal_sprite = $KettleNormal
@onready var pouring_sprite = $KettlePouring
@onready var collision_normal = $CollisionShape_Normal
@onready var collision_pouring = $CollisionShape_Pouring
@onready var detector_normal = $Detector_Normal
@onready var detector_pouring = $Detector_Pouring
@onready var pour_progress = $PourProgress
@onready var pour_sound = $PourSound
@onready var press_sound = get_node_or_null("/root/CookingMinigame/PressSound")

var dragging := false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO
var over_pot := false
var is_pouring := false
var pour_timer := 0.0
var pour_duration := 2.0
var max_step := 20
var has_filled_water := false

func _ready() -> void:
	original_position = global_position
	pouring_sprite.visible = false
	collision_pouring.disabled = true
	detector_pouring.monitoring = false

	pour_progress.visible = false
	pour_progress.value = 0
	pour_progress.max_value = 100

	detector_normal.connect("area_entered", Callable(self, "_on_Detector_area_entered"))
	detector_normal.connect("area_exited", Callable(self, "_on_Detector_area_exited"))
	detector_pouring.connect("area_entered", Callable(self, "_on_Detector_area_entered"))
	detector_pouring.connect("area_exited", Callable(self, "_on_Detector_area_exited"))

	set_process_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and is_mouse_over_self():
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
			z_index = 20
			collision_mask = 0
			if press_sound: press_sound.play()
		elif dragging:
			dragging = false
			z_index = 11
			reset_position()
			if not is_pouring:
				collision_mask = 0
			if press_sound: press_sound.play()

func _physics_process(delta: float) -> void:
	if dragging:
		var target = get_global_mouse_position() + drag_offset
		var motion = target - global_position
		var steps = int(ceil(motion.length() / max_step))
		if steps != 0:
			var step_vector = motion / steps
			for i in steps:
				move_and_collide(step_vector)

	if is_pouring:
		pour_timer += delta
		var progress = clamp(pour_timer / pour_duration, 0.0, 1.0)
		pour_progress.value = progress * 100.0

		var pot = get_tree().get_first_node_in_group("pot1")
		if pot and pot.has_method("set_water_fill_progress"):
			pot.set_water_fill_progress(progress)

		if progress >= 1.0 and not has_filled_water:
			has_filled_water = true
			if pot and pot.has_method("on_water_fill_finished"):
				pot.on_water_fill_finished()
			print("✅ Kettle finished pouring. Water fully added.")
			stop_pouring()

	if over_pot and not is_pouring and not has_filled_water:
		start_pouring()
	elif not over_pot and is_pouring:
		stop_pouring()

func start_pouring() -> void:
	is_pouring = true
	collision_mask = 2
	pouring_sprite.visible = true
	pouring_sprite.play("pouring")
	normal_sprite.visible = false
	z_index = 9
	collision_normal.disabled = true
	collision_pouring.disabled = false
	detector_normal.monitoring = false
	detector_pouring.monitoring = true
	pour_progress.visible = true
	pour_timer = 0.0
	if pour_sound: pour_sound.play()
	print("🚰 Kettle pouring started...")

func stop_pouring() -> void:
	is_pouring = false
	collision_mask = 0
	pouring_sprite.stop()
	pouring_sprite.visible = false
	normal_sprite.visible = true
	z_index = 11
	collision_normal.disabled = false
	collision_pouring.disabled = true
	detector_normal.monitoring = true
	detector_pouring.monitoring = false
	pour_progress.visible = false
	if pour_sound and pour_sound.playing:
		pour_sound.stop()
	print("🛑 Kettle pouring stopped.")

func reset_position() -> void:
	global_position = original_position
	z_index = 11

func _on_Detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("pot1"):
		over_pot = true

func _on_Detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("pot1"):
		over_pot = false

func is_mouse_over_self() -> bool:
	var space_state = get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_bodies = true
	var result = space_state.intersect_point(params)
	for hit in result:
		if hit.collider == self:
			return true
	return false
