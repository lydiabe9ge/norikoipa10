extends CharacterBody2D

@onready var normal_sprite = $DashiNormal
@onready var pouring_sprite = $DashiPouring
@onready var collision_normal = $CollisionShape_Normal
@onready var collision_pouring = $CollisionShape_Pouring
@onready var detector_normal = $Detector_Normal
@onready var detector_pouring = $Detector_Pouring
@onready var pour_progress = $PourProgress
@onready var pour_sound: AudioStreamPlayer = $PourSound
@onready var press_sound: AudioStreamPlayer = get_node_or_null("/root/CookingMinigame/PressSound")

@export_range(0.0, 1.0, 0.01)
var fade_strength: float = 0.03

@export_range(0.0, 2.0, 0.01)
var fade_multiplier: float = 0.5

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2
var over_pot: bool = false
var is_pouring: bool = false
var soup_created: bool = false
var max_step: int = 20
var pouring_timer: float = 0.0
var pour_duration: float = 2.10

func _ready() -> void:
	original_position = global_position
	pouring_sprite.visible = false
	z_index = 11

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
		var target_position = get_global_mouse_position() + drag_offset
		var motion = target_position - global_position
		var steps = int(ceil(motion.length() / max_step))
		if steps != 0:
			var step_vector = motion / steps
			for i in steps:
				move_and_collide(step_vector)

	if is_pouring:
		pouring_timer += delta
		var progress_ratio: float = clamp(pouring_timer / pour_duration, 0.0, 1.0)
		pour_progress.value = progress_ratio * 100.0

		var pot1 = get_tree().get_first_node_in_group("pot1")
		if pot1 and pot1.has_node("Soup1Sprite"):
			var sprite = pot1.get_node("Soup1Sprite")
			if sprite.material is ShaderMaterial:
				var mat: ShaderMaterial = sprite.material
				var current_alpha: float = mat.get_shader_parameter("transparency")
				var added_alpha: float = progress_ratio * fade_strength * fade_multiplier
				var final_alpha: float = clamp(current_alpha + added_alpha, 0.0, 1.0)
				mat.set_shader_parameter("transparency", final_alpha)
				print("🟡 Dashi pouring - Soup1 transparency: %.2f (added %.2f)" % [final_alpha, added_alpha])

		if pouring_timer >= pour_duration:
			pouring_finished()

	if not soup_created:
		if over_pot and not is_pouring:
			start_pouring()
		elif not over_pot and is_pouring:
			stop_pouring()

func start_pouring() -> void:
	if soup_created or soup_already_present():
		return

	if not GameController.is_soy_sauce_finished:
		print("⛔ Soy sauce must finish pouring before Dashi can start.")
		return

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

	if pour_sound: pour_sound.play()
	print("💧 Dashi started pouring...")

func stop_pouring() -> void:
	if is_pouring:
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

		pour_progress.visible = true

		if pour_sound and pour_sound.playing:
			pour_sound.stop()

func pouring_finished() -> void:
	stop_pouring()
	soup_created = true
	pour_progress.visible = false
	GameController.is_dashi_finished = true
	print("✅ Dashi finished pouring. Sugar can now pour.")

func reset_position() -> void:
	global_position = original_position
	z_index = 11

func soup_already_present() -> bool:
	var pot1 = get_tree().get_first_node_in_group("pot1")
	return pot1 and pot1.has_method("has_soup") and pot1.has_soup()

func is_mouse_over_self() -> bool:
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_bodies = true
	var result = space_state.intersect_point(params)
	for hit in result:
		if hit.collider == self:
			return true
	return false

func _on_Detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("pot1"):
		over_pot = true

func _on_Detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("pot1"):
		over_pot = false
