extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var dragging := false
var offset := Vector2.ZERO
var is_inside_aburaage_area := false
var aburaage_area: Area2D = null

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)
	set_process_input(true)

	# Delay finding until scene tree is fully ready
	call_deferred("find_aburaage_area")

func find_aburaage_area():
	var pot1 = get_node_or_null("/root/CookingMinigame/Pot1")
	if pot1:
		aburaage_area = pot1.get_node_or_null("AburaageArea")
		if aburaage_area:
			print("✅ Found AburaageArea")
		else:
			print("❌ AburaageArea not found")
	else:
		print("❌ Pot1 not found in CookingMinigame")

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			dragging = true
			offset = get_global_mouse_position() - global_position
		else:
			dragging = false
			if is_inside_aburaage_area:
				print("✅ Released inside AburaageArea — snapping")
				snap_fully_inside()
			else:
				print("❌ Released outside any valid area")

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - offset

func _on_area_entered(area: Area2D) -> void:
	if area.name == "AburaageArea":
		is_inside_aburaage_area = true
		print("👀 Entered AburaageArea")

func _on_area_exited(area: Area2D) -> void:
	if area.name == "AburaageArea":
		is_inside_aburaage_area = false
		print("👋 Exited AburaageArea")

func snap_fully_inside():
	if not aburaage_area:
		print("❌ Can't snap — no AburaageArea")
		return

	var shape = aburaage_area.get_node_or_null("CollisionShape2D")
	if not shape or not (shape.shape is RectangleShape2D):
		print("❌ AburaageArea shape not valid")
		return

	var rect: RectangleShape2D = shape.shape as RectangleShape2D
	var center: Vector2 = aburaage_area.to_global(shape.position)
	var extents: Vector2 = rect.extents

	var top_left: Vector2 = center - extents
	var bottom_right: Vector2 = center + extents

	# 🌟 FIX: Use sprite rect + scale + anchor position
	var sprite_size: Vector2 = sprite.get_rect().size * sprite.global_scale
	var half_size: Vector2 = sprite_size * 0.5
	var sprite_offset: Vector2 = sprite.position * global_scale

	# ✅ Clamp the global position so the entire sprite fits inside the box
	var clamped_x = clamp(
		global_position.x,
		top_left.x + half_size.x - sprite_offset.x,
		bottom_right.x - half_size.x - sprite_offset.x
	)
	var clamped_y = clamp(
		global_position.y,
		top_left.y + half_size.y - sprite_offset.y,
		bottom_right.y - half_size.y - sprite_offset.y
	)

	global_position = Vector2(clamped_x, clamped_y)
	print("📦 Snapped to:", global_position)
