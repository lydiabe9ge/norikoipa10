extends CanvasLayer

# Reference to the settings button
@onready var settings_button = $SettingsButton

# Reference to the start button
@onready var start_button = $StartButton

# Reference to the background
@onready var background = $Background

# Reference to the settings panel scene
var settings_panel_scene = preload("res://SettingsPanel.tscn")

# Reference to the instantiated settings panel
var settings_panel = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("MainMenu _ready() called!")
	
	# Connect the settings button's pressed signal
	if settings_button:
		print("SettingsButton is assigned:", settings_button)
		
		# Disconnect the signal first (if already connected)
		if settings_button.is_connected("pressed", _on_settings_button_pressed):
			print("Signal is already connected. Disconnecting...")
			settings_button.disconnect("pressed", _on_settings_button_pressed)
		
		# Connect the signal
		print("Connecting signal...")
		var connect_result = settings_button.connect("pressed", _on_settings_button_pressed)
		if connect_result != OK:
			print("Error: Failed to connect 'pressed' signal to _on_settings_button_pressed.")
	else:
		print("Error: SettingsButton is NOT assigned. Check the node path.")
	
	# Connect the start button's pressed signal
	if start_button:
		print("StartButton is assigned:", start_button)
		
		# Disconnect the signal first (if already connected)
		if start_button.is_connected("pressed", _on_start_button_pressed):
			print("Signal is already connected. Disconnecting...")
			start_button.disconnect("pressed", _on_start_button_pressed)
		
		# Connect the signal
		print("Connecting signal...")
		var connect_result = start_button.connect("pressed", _on_start_button_pressed)
		if connect_result != OK:
			print("Error: Failed to connect 'pressed' signal to _on_start_button_pressed.")
	else:
		print("Error: StartButton is NOT assigned. Check the node path.")
	
	# Connect the background's gui_input signal
	if background:
		print("Background is assigned:", background)
		
		# Disconnect the signal first (if already connected)
		if background.is_connected("gui_input", _on_background_gui_input):
			print("Signal is already connected. Disconnecting...")
			background.disconnect("gui_input", _on_background_gui_input)
		
		# Connect the signal
		print("Connecting signal...")
		var connect_result = background.connect("gui_input", _on_background_gui_input)
		if connect_result != OK:
			print("Error: Failed to connect 'gui_input' signal to _on_background_gui_input.")
	else:
		print("Error: Background is NOT assigned. Check the node path.")

# Called when the Settings Button is pressed
func _on_settings_button_pressed() -> void:
	print("Settings button pressed!")
	
	# If a settings panel already exists, remove it
	if settings_panel:
		print("Removing existing SettingsPanel.")
		settings_panel.queue_free()
		settings_panel = null
	
	# Instantiate the settings panel scene
	settings_panel = settings_panel_scene.instantiate()
	print("SettingsPanel instantiated:", settings_panel)  # Debug: Check instantiation
	add_child(settings_panel)
	
	# Show the settings panel
	settings_panel.visible = true
	print("SettingsPanel visibility:", settings_panel.visible)  # Debug: Check visibility

# Called when the Start Button is pressed
func _on_start_button_pressed() -> void:
	print("Start Game button pressed!")
	
	# Ensure the scene path is correct
	var result = get_tree().change_scene_to_file("res://LoadingScreen.tscn")
	if result != OK:
		print("Error: Failed to load LoadingScreen.tscn")

# Called when the background receives input
func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Background clicked! Hiding settings panel.")
		
		# Hide the settings panel if it exists
		if settings_panel:
			print("SettingsPanel visibility before hiding:", settings_panel.visible)
			settings_panel.hide()
			print("SettingsPanel visibility after hiding:", settings_panel.visible)
		else:
			print("Error: SettingsPanel is NOT assigned.")
