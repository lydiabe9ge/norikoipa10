extends Node2D

# References to nodes for Noriko, background music, and buttons
@onready var background_music: AudioStreamPlayer2D = $BackgroundMusic
@onready var noriko_animations: AnimationPlayer = $Noriko/NorikoAnimations
@onready var click_area: Area2D = $Noriko/ClickArea
@onready var action_timer: Timer = $Noriko/ActionTimer
@onready var reminder_hotspot: Area2D = $ReminderHotspot
@onready var main_menu_button: TextureButton = $MainMenuButton

# New references for renamed close area and collision
@onready var reminder_close_area: Area2D = $ReminderCloseArea
@onready var reminder_close_collision: CollisionShape2D = $ReminderCloseArea/ReminderCloseCollision

# NEW: Reference for Recipe Book clickable area
@onready var recipe_book_hotspot: Area2D = $RecipeBookHotspot

# Load scenes
var options_panel_scene = preload("res://OptionsPanel.tscn")
var reminder_scene_scene = preload("res://ReminderScene.tscn")
var recipe_book_scene_path = "res://RecipeBookScene.tscn"  # path to your RecipeBookScene

func _ready() -> void:
	background_music.play()

	click_area.input_event.connect(_on_click_area_input_event)
	action_timer.timeout.connect(_on_action_timer_timeout)
	reminder_hotspot.input_event.connect(_on_reminder_hotspot_input_event)

	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

	# Connect ReminderCloseArea (click outside detection)
	reminder_close_area.input_event.connect(_on_reminder_close_area_input_event)

	# Connect RecipeBookHotspot for opening the recipe book
	recipe_book_hotspot.input_event.connect(_on_recipe_book_hotspot_input_event)

	noriko_animations.play("Idle")
	main_menu_button.visible = true

# Handle clicking on Noriko
func _on_click_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Clicked on Noriko!")
		noriko_animations.play("Action")
		action_timer.start()

# Reset Noriko animation after action
func _on_action_timer_timeout() -> void:
	noriko_animations.play("Idle")

# Open options panel
func _on_main_menu_button_pressed() -> void:
	print("Main Menu Button Pressed")
	main_menu_button.visible = false

	var options_panel_instance = options_panel_scene.instantiate()
	add_child(options_panel_instance)

	var animation_player = options_panel_instance.get_node("PanelAnimationPlayer")
	if animation_player and animation_player.has_animation("PanelAnimation"):
		animation_player.play("PanelAnimation")
		await get_tree().create_timer(0.4).timeout
		if animation_player.has_animation("SlideInLastImage"):
			animation_player.play("SlideInLastImage")

# Open ReminderScene
func _on_reminder_hotspot_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Reminder hotspot clicked! Opening ReminderScene.")
		var reminder_scene = reminder_scene_scene.instantiate()
		reminder_scene.name = "ReminderScene"
		add_child(reminder_scene)

		reminder_scene.visible = true
		print("ReminderScene opened.")

# Close ReminderScene when clicking outside it
func _on_reminder_close_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Clicked outside — checking if ReminderScene is open.")

		if has_node("ReminderScene"):
			var reminder_scene = get_node("ReminderScene")
			if reminder_scene:
				print("Closing ReminderScene and autosaving.")

				if reminder_scene.has_method("autosave_note"):
					reminder_scene.autosave_note()

				reminder_scene.queue_free()
				print("ReminderScene closed.")
		else:
			print("No ReminderScene found.")

# NEW: Open the Recipe Book when clicking the hotspot area (pop-up style inside MainScene)
func _on_recipe_book_hotspot_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Recipe book area clicked - Opening RecipeBookScene as pop-up")
		open_recipe_book_popup()

# NEW: Opens RecipeBookScene as a pop-up inside MainScene (not a scene switch)
func open_recipe_book_popup():
	if has_node("RecipeBookScene"):
		print("RecipeBookScene already open - skipping duplicate.")
		return

	var recipe_book_scene = load(recipe_book_scene_path).instantiate()
	recipe_book_scene.name = "RecipeBookScene"
	add_child(recipe_book_scene)
