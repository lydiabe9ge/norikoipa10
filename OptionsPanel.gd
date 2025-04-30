extends Control  # This node should be of type Control or Panel

# References to nodes in the OptionsPanel scene
@onready var exit_button: Button = $ExitButton  # Exit button for closing the panel
@onready var settings_button: Button = $SettingsButton  # Settings button for opening settings
@onready var reminder_button: Button = $ReminderButton  # Reminder button to open the note scene
@onready var close_area: Area2D = $CloseArea  # Reference to CloseArea inside the OptionsPanel

# Preload the SettingsPanel scene
var settings_panel_scene = preload("res://SettingsPanel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("OptionsPanel Initialized!")

	# Ensure this Control can capture mouse events
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Connect all button signals
	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)
		print("ExitButton signal connected!")

	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
		print("SettingsButton signal connected!")

	if reminder_button:
		reminder_button.pressed.connect(_on_reminder_button_pressed)
		print("ReminderButton signal connected!")

# Handle ExitButton press - Save progress and go back to main menu
func _on_exit_button_pressed() -> void:
	print("Exit Button Pressed!")
	save_game_progress()
	get_tree().change_scene_to_file("res://MainMenu.tscn")

# Handle SettingsButton press - Open the settings panel
func _on_settings_button_pressed() -> void:
	print("Settings Button Pressed!")

	# Instance and add the SettingsPanel
	var settings_panel = settings_panel_scene.instantiate()
	settings_panel.position = Vector2(540, 660)  # Adjust if needed
	get_parent().add_child(settings_panel)
	settings_panel.visible = true
	print("SettingsPanel shown.")

	# Pass the SettingsPanel reference to CloseArea
	close_area.set_settings_panel(settings_panel)

# Handle ReminderButton press - Open the reminder note scene
func _on_reminder_button_pressed() -> void:
	print("Reminder Button Pressed!")

	# Instance ReminderScene
	var reminder_scene = preload("res://ReminderScene.tscn").instantiate()

	# Add to the current scene
	get_tree().current_scene.add_child(reminder_scene)

	# Let ReminderScene handle its own positioning, so we do NOT set position here
	print("ReminderScene added to tree.")

	# Pass the ReminderScene reference to CloseArea so it can be closed when clicking outside
	close_area.set_reminder_scene(reminder_scene)

# Placeholder save progress function (replace with your actual save logic)
func save_game_progress() -> void:
	print("Saving game progress...")
