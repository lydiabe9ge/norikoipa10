extends Node2D

@onready var camera = $Camera2D
@onready var back_button = $BackButton

const SCREEN_WIDTH = 1125
const PAGE_COUNT = 4

var current_page := 3  # Start at Page 3 (rightmost: X = 1687.5)
var drag_start: Vector2 = Vector2.ZERO
var is_mobile := false
var paging_enabled := false  # 🔒 Disable swipe until Aburaage is done

func _ready():
	var os_name = OS.get_name()
	is_mobile = os_name == "iOS" or os_name == "Android"
	print("📱 Running on:", os_name, "| Mobile:", is_mobile)

	snap_to_page(current_page)
	camera.make_current()

	add_to_group("MainScene")  # ✅ So GameController can find this node

	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		printerr("⚠ BackButton not found!")

func _unhandled_input(event):
	if OS.is_debug_build():
		if event is InputEventKey and event.pressed and event.keycode == KEY_P:
			paging_enabled = !paging_enabled
			print("🧪 Paging toggled:", paging_enabled)
			return


	if not paging_enabled:
		return  # 🔒 Prevent swipe

	if event is InputEventScreenTouch:
		if event.pressed:
			drag_start = event.position
		else:
			drag_start = Vector2.ZERO

	elif event is InputEventScreenDrag and drag_start != Vector2.ZERO:
		var drag_amount = event.position.x - drag_start.x
		if abs(drag_amount) > 50:
			if drag_amount < 0:
				go_to_next_page()      # Swipe left → go forward
			else:
				go_to_previous_page()  # Swipe right → go backward
			drag_start = Vector2.ZERO

func go_to_next_page():
	if current_page < PAGE_COUNT - 1:
		current_page += 1
		snap_to_page(current_page)

func go_to_previous_page():
	if current_page > 0:
		current_page -= 1
		snap_to_page(current_page)

func snap_to_page(page: int):
	var center_x = -1687.5 + float(page) * 1125.0
	var center_y = 0
	camera.position = Vector2(center_x, center_y)
	print("📸 Snapped to page", page, "→ Camera position:", camera.position)

func jump_to_page(page: int):
	current_page = clamp(page, 0, PAGE_COUNT - 1)
	snap_to_page(current_page)
	print("📘 Jumped to page", page, "(no swipe)")

func _on_back_button_pressed() -> void:
	print("🔙 Back button pressed")
	var err = get_tree().change_scene_to_file("res://MainScene.tscn")
	if err != OK:
		print("❌ Failed to change scene:", err)
	else:
		print("✅ Scene changed")
