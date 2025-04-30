extends Area2D
class_name Aburaage

@onready var plate_node: Node = get_tree().get_root().get_node("CookingMinigame/Plate")
@onready var dip_progress: TextureProgressBar = $DipProgress
@onready var mask_node: Sprite2D = $Mask
@onready var aburaage_sprite: Sprite2D = $Mask/AburaageSprite
@onready var animator: AnimationPlayer = $FloatAnimator
@onready var float_progress: TextureProgressBar = $FloatProgress

var jump_delay_timer: Timer
var dragging := false
var original_position: Vector2
var offset: Vector2 = Vector2.ZERO
var pot = null
var dip_count: int = 0
var is_in_pot := false
var is_animating := false
var next_action := ""
var floating_after_sugar := false
var in_plate := false
var float_timer: Timer
var sugar_done := false
var aburaage_area: Area2D = null
var already_triggered_jump := false  # ✅ Prevent double-calling GameController

func _ready() -> void:
	original_position = global_position
	dip_progress.value = 0
	dip_progress.max_value = 3
	dip_progress.visible = false

	float_progress.visible = false
	float_progress.value = 0
	float_progress.max_value = 100
	float_progress.z_index = 1000

	collision_layer = 2
	collision_mask = 2

	float_timer = Timer.new()
	add_child(float_timer)
	float_timer.wait_time = 2.0
	float_timer.one_shot = true
	float_timer.timeout.connect(_on_float_timer_timeout)

	find_pot()

	mask_node.clip_children = CanvasItem.ClipChildrenMode.CLIP_CHILDREN_DISABLED
	mask_node.self_modulate.a = 0.0
	aburaage_sprite.z_index = 1
	animator.animation_finished.connect(_on_animation_finished)

	jump_delay_timer = Timer.new()
	jump_delay_timer.wait_time = 1.5
	jump_delay_timer.one_shot = true
	jump_delay_timer.timeout.connect(_on_jump_delay_timeout)
	add_child(jump_delay_timer)

func _input_event(_viewport, event, _shape_idx) -> void:
	if is_animating:
		return

	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		if (is_in_pot and dip_count < 3) or in_plate:
			handle_dip()
		elif not is_in_pot:
			dragging = true
			offset = get_global_mouse_position() - global_position

	elif (event is InputEventMouseButton or event is InputEventScreenTouch) and not event.pressed and dragging:
		dragging = false
		if is_inside_pot():
			var can_place := false
			if sugar_done:
				can_place = true
				print("✅ Sugar is done — placement allowed.")
			elif pot and pot.is_ready:
				can_place = true
				print("✅ Pot is ready — placement allowed.")
			else:
				print("❌ Pot is not ready yet — placement blocked.")
			if can_place:
				place_in_pot()
			else:
				reset_position()
		else:
			reset_position()

func _process(_delta) -> void:
	if dragging:
		global_position = get_global_mouse_position() - offset
		aburaage_sprite.z_index = 100

	if floating_after_sugar and not float_timer.is_stopped():
		var progress: float = clamp(1.0 - float_timer.time_left / float_timer.wait_time, 0.0, 1.0)
		float_progress.value = progress * 100.0

	if not sugar_done and GameController.is_sugar_finished:
		set_sugar_done()

func is_inside_pot() -> bool:
	for area in get_overlapping_areas():
		if area.name == "AburaageArea":
			aburaage_area = area
			return true
	return false

func place_in_pot() -> void:
	print("✅ Placing in pot or plate: sugar_done=" + str(sugar_done))

	for area in get_overlapping_areas():
		if area.name == "AburaageArea":
			aburaage_area = area
			break

	snap_fully_inside()

	mask_node.clip_children = CanvasItem.ClipChildrenMode.CLIP_CHILDREN_ONLY
	mask_node.self_modulate.a = 1.0
	mask_node.visible = true
	aburaage_sprite.z_index = 0
	aburaage_sprite.visible = true

	if sugar_done:
		in_plate = true
		is_in_pot = false
		floating_after_sugar = true
		animator.stop()
		animator.play("float")

		if plate_node and plate_node.has_method("show_aburaage"):
			plate_node.show_aburaage()

		float_progress.visible = true
		float_progress.value = 0
		float_timer.start()
	else:
		is_in_pot = true
		in_plate = false
		animator.stop()
		animator.play("float")

func handle_dip() -> void:
	print("🟡 Tap detected: is_in_pot=%s | in_plate=%s | sugar_done=%s" % [is_in_pot, in_plate, sugar_done])

	if not is_in_pot and not in_plate:
		return

	is_animating = true
	animator.play("sink")

	if is_in_pot and pot:
		dip_count += 1
		dip_progress.visible = true
		dip_progress.value = dip_count

		if dip_count == 3 and not GameController.is_aburaage_dipped:
			GameController.is_aburaage_dipped = true
			print("✅ Aburaage finished dipping.")

	next_action = "reset" if is_in_pot and dip_count == 3 else "float"

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "sink":
		if next_action == "float":
			animator.play("float")
			is_animating = false
			next_action = ""
		elif next_action == "reset":
			if pot and pot.has_method("remove_water"):
				pot.remove_water()
			reset_position()
	elif anim_name == "float":
		is_animating = false

func _on_float_timer_timeout() -> void:
	reset_position()
	if sugar_done and plate_node and plate_node.has_method("show_soup_sprite"):
		plate_node.show_soup_sprite()

func reset_position() -> void:
	print("↩️ Resetting position: sugar_done=" + str(sugar_done))
	global_position = original_position
	aburaage_sprite.position = Vector2(0, 0)
	aburaage_sprite.z_index = 1
	dip_progress.value = 0
	dip_progress.visible = false
	is_in_pot = false
	in_plate = false
	is_animating = false
	next_action = ""
	floating_after_sugar = sugar_done
	float_timer.stop()
	float_progress.visible = false
	float_progress.value = 0
	animator.stop()

	if sugar_done:
		in_plate = true
		floating_after_sugar = true
		mask_node.clip_children = CanvasItem.ClipChildrenMode.CLIP_CHILDREN_ONLY
		mask_node.self_modulate.a = 1.0
		mask_node.visible = true
		aburaage_sprite.visible = true
		aburaage_sprite.z_index = 0
		animator.play("float")
		float_timer.start()

		# ✅ Trigger Page 2 jump once
		if not already_triggered_jump:
			already_triggered_jump = true
			jump_delay_timer.start()  # ⏱ Start 1-second delay

	else:
		in_plate = false
		floating_after_sugar = false
		mask_node.clip_children = CanvasItem.ClipChildrenMode.CLIP_CHILDREN_DISABLED
		mask_node.self_modulate.a = 0.0

	aburaage_area = null

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Pot1:
		pot = area.get_parent()

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent() is Pot1:
		pot = null

func find_pot() -> void:
	var found_pot = get_tree().get_first_node_in_group("Pot1")
	if found_pot:
		pot = found_pot

func set_sugar_done() -> void:
	sugar_done = true
	print("🧂 Sugar state set to done!")
	if pot and pot.has_method("start_soup_bubbling_after_sugar"):
		print("🔵 DEBUG: calling pot.start_soup_bubbling_after_sugar()")
		pot.start_soup_bubbling_after_sugar()
	else:
		print("🔴 ERROR: Pot missing or method missing!")

func snap_fully_inside():
	if not aburaage_area:
		return

	var area_shape = aburaage_area.get_node_or_null("CollisionShape2D")
	if not area_shape:
		return

	var aburaage_shape = get_node_or_null("CollisionShape2D")
	if not aburaage_shape:
		return

	if area_shape.shape is RectangleShape2D:
		var area_rect: RectangleShape2D = area_shape.shape
		var area_center: Vector2 = aburaage_area.to_global(area_shape.position)
		var area_extents: Vector2 = area_rect.extents
		var area_top_left: Vector2 = area_center - area_extents
		var area_bottom_right: Vector2 = area_center + area_extents

		if not (aburaage_shape.shape is RectangleShape2D):
			return
		var aburaage_rect: RectangleShape2D = aburaage_shape.shape
		var aburaage_center: Vector2 = to_global(aburaage_shape.position)
		var aburaage_extents: Vector2 = aburaage_rect.extents
		var aburaage_offset = aburaage_center - global_position

		var clamped_x = clamp(
			global_position.x,
			area_top_left.x + aburaage_extents.x - aburaage_offset.x,
			area_bottom_right.x - aburaage_extents.x - aburaage_offset.x
		)
		var clamped_y = clamp(
			global_position.y,
			area_top_left.y + aburaage_extents.y - aburaage_offset.y,
			area_bottom_right.y - aburaage_extents.y - aburaage_offset.y
		)
		global_position = Vector2(clamped_x, clamped_y)

	elif area_shape.shape is CircleShape2D:
		var circle: CircleShape2D = area_shape.shape
		var circle_center: Vector2 = aburaage_area.to_global(area_shape.position)
		var circle_radius: float = circle.radius

		var aburaage_radius: float = 0.0
		if aburaage_shape.shape is RectangleShape2D:
			var extents: Vector2 = aburaage_shape.shape.extents
			aburaage_radius = max(extents.x, extents.y)
		elif aburaage_shape.shape is CircleShape2D:
			aburaage_radius = aburaage_shape.shape.radius
		else:
			return

		var aburaage_center: Vector2 = to_global(aburaage_shape.position)
		var aburaage_offset = aburaage_center - global_position

		var direction = (global_position + aburaage_offset) - circle_center
		var distance = direction.length()
		var max_distance = circle_radius - aburaage_radius
		if distance > max_distance:
			direction = direction.normalized() * max_distance
			global_position = circle_center + direction - aburaage_offset

func _on_jump_delay_timeout() -> void:
	if GameController.has_method("notify_aburaage_returned_to_second_plate"):
		GameController.notify_aburaage_returned_to_second_plate()
