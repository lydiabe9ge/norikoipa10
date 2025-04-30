extends Area2D  # This node should be of type Area2D

# Variables to hold the references to the panels
var settings_panel: Control = null
var reminder_scene: Control = null

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Ensure this Area2D is able to detect input
	input_pickable = true  # Make sure the Area2D can detect mouse clicks

	# Connect the input_event signal to a function that handles mouse clicks
	self.input_event.connect(_on_input_event)

# Function to set the reference of the SettingsPanel
func set_settings_panel(panel: Control) -> void:
	settings_panel = panel

# Function to set the reference of the ReminderScene
func set_reminder_scene(scene: Control) -> void:
	reminder_scene = scene

# Called when the area receives an input event (clicks outside)
func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Clicked outside the panel!")

		# Close the specific SettingsPanel if it's visible
		if settings_panel:
			settings_panel.queue_free()  # Close the specific SettingsPanel if it's visible
			print("SettingsPanel closed.")
		
		# Close the specific ReminderScene if it's visible
		if reminder_scene:
			reminder_scene.queue_free()  # Close the specific ReminderScene if it's visible
			print("ReminderScene closed.")
		
		# Close the OptionsPanel as well
		close_panel()  # Close the OptionsPanel

# Function to close the OptionsPanel
func close_panel() -> void:
	# Make the MainMenuButton visible before closing the OptionsPanel
	var main_scene = get_node("/root/MainScene")
	if main_scene and main_scene.has_node("MainMenuButton"):
		var main_menu_button = main_scene.get_node("MainMenuButton")
		main_menu_button.visible = true  # Show the MainMenuButton again
		print("MainMenuButton reappeared.")

	# Now safely remove the OptionsPanel from the scene
	var options_panel = get_parent()
	options_panel.queue_free()
	print("OptionsPanel closed.")
