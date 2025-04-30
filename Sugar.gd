extends CharacterBody2D

@onready var normal_sprite = $SugarNormal
@onready var pouring_sprite = $SugarPouring
@onready var collision_normal = $CollisionShape_Normal
@onready var collision_pouring = $CollisionShape_Pouring
@onready var detector_normal = $Detector_Normal
@onready var detector_pouring = $Detector_Pouring
@onready var pour_progress = $PourProgress
@onready var pour_sound = $PourSound
@onready var sugar_particles = $SugarParticles
@onready var splash_particles = $SplashParticles
@onready var sugar_hit_area = $SugarHitArea
@onready var press_sound = get_node_or_null("/root/CookingMinigame/PressSound")

var dragging := false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO
var over_pot := false
var is_pouring := false
var sugar_done := false
var pouring_timer := 0.0
var pour_duration := 2.10
var max_step := 20

func _ready() -> void:
	original_position = global_position
	pouring_sprite.visible = false
	z_index = 11
	collision_pouring.disabled = true
	detector_pouring.monitoring = false

	pour_progress.visible = false
	pour_progress.value = 0
	pour_progress.max_value = 100

	sugar_particles.emitting = false
	splash_particles.emitting = false

	sugar_hit_area.connect("area_entered", Callable(self, "_on_sugar_hit"))

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
		pouring_timer += delta
		var progress = clamp(pouring_timer / pour_duration, 0.0, 1.0)
		pour_progress.value = progress * 100.0

		if pouring_timer >= pour_duration:
			pouring_finished()

	if not sugar_done:
		if over_pot and not is_pouring:
			start_pouring()
		elif not over_pot and is_pouring:
			stop_pouring()

func start_pouring() -> void:
	if sugar_done:
		return

	if not GameController.is_dashi_finished:
		print("⛔ Dashi must finish pouring before Sugar can start.")
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
	sugar_particles.emitting = true

	if pour_sound:
		pour_sound.play()
	print("🍬 Sugar started pouring.")

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
		sugar_particles.emitting = false

		if pour_sound and pour_sound.playing:
			pour_sound.stop()
		print("🛑 Sugar pouring stopped.")

func pouring_finished() -> void:
	stop_pouring()
	sugar_done = true
	pour_progress.visible = false

	GameController.set("is_sugar_finished", true)
	print("✅ Sugar pouring finished. Aburaage can float again!")

func _on_Detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("pot1"):
		over_pot = true

func _on_Detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("pot1"):
		over_pot = false

func reset_position() -> void:
	global_position = original_position
	z_index = 11

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

# ✅ Splash only triggers if actually pouring
func _on_sugar_hit(area: Area2D) -> void:
	if area.is_in_group("pot1") and is_pouring:
		splash_particles.emitting = false  # Reset first
		splash_particles.emitting = true   # Trigger clean splash
		print("💥 Sugar splash triggered while pouring.")
