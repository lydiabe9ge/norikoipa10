extends Control  # Ensure the script is attached to a Node

@onready var volume_slider: Slider = get_node("VolumeSlider")

var grabber_texture: Texture2D = preload("res://grabber.png")  # Ensure the path is correct!

func _ready() -> void:
	print("🛠 SettingsPanel _ready() called!")

	# Debug check if the texture loads properly
	if grabber_texture == null:
		print("❌ ERROR: Grabber texture failed to load!")
	else:
		print("✅ Grabber texture loaded successfully! Size:", grabber_texture.get_size())

	visible = false  # Hide settings initially

	# Verify volume_slider exists
	if volume_slider == null:
		print("❌ ERROR: VolumeSlider node not found! Check the node path.")
		return  # Exit to prevent further errors

	# Configure slider
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.step = 1

	# Load and apply saved volume
	var saved_volume = load_volume_setting()
	volume_slider.value = saved_volume
	_on_volume_slider_value_changed(saved_volume)

	# Connect the signal properly
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)

	# Apply the grabber texture properly
	apply_custom_grabber_texture()
	print("✅ VolumeSlider setup complete.")

# 🎨 Properly apply grabber texture
func apply_custom_grabber_texture() -> void:
	if grabber_texture == null:
		print("❌ ERROR: Grabber texture is missing!")
		return

	print("🎨 Applying grabber texture...")

	# Apply grabber texture as an icon
	volume_slider.add_theme_icon_override("grabber", grabber_texture)

	# Set the grabber size manually (adjust if too big/small)
	var grabber_size = grabber_texture.get_size().x
	volume_slider.add_theme_constant_override("grabber_size", grabber_size)

	# Prevent disappearing when hovered
	volume_slider.add_theme_icon_override("grabber_highlight", grabber_texture)

	print("✅ Grabber applied! Size:", grabber_size)

# 🎵 Handle volume slider changes
func _on_volume_slider_value_changed(value: float) -> void:
	print("🔊 Volume slider changed:", value)

	# Ensure higher slider value = higher volume
	var db_value = linear_to_db(value / 100.0)
	
	print("🎚 Volume in dB:", db_value)

	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index == -1:
		print("❌ ERROR: 'Master' bus not found. Check Audio Bus Layout.")
		return

	AudioServer.set_bus_volume_db(bus_index, db_value)
	save_volume_setting(value)

# 💾 Save volume setting
func save_volume_setting(value: float) -> void:
	var config = ConfigFile.new()
	config.set_value("Audio", "volume", value)
	config.save("user://settings.cfg")

# 📂 Load volume setting
func load_volume_setting() -> float:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		return config.get_value("Audio", "volume", 100.0)  # Default to 100
	return 100.0
