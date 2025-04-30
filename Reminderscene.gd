extends Control

@onready var text_edit: TextEdit = $TextEditNote
@onready var background_image: TextureRect = $BackgroundImage

var note_file_path = "user://reminder_note.txt"

# Set the maximum number of characters per line before wrapping
const MAX_CHARACTERS_PER_LINE = 13

func _ready() -> void:
	print("ReminderScene _ready() called")

	# Load saved note (if any)
	_load_note()

	# Connect autosave and manual wrapping
	text_edit.text_changed.connect(_on_text_changed)

	# Center scene
	_center_on_screen()

	# Focus text box for mobile keyboard
	text_edit.grab_focus()

	self.visible = true
	print("ReminderScene is visible.")

func _center_on_screen() -> void:
	var viewport_size = get_viewport_rect().size
	var scene_size = get_size()
	position = (viewport_size - scene_size) / 2
	print("ReminderScene centered at position: ", position)

# Called whenever text changes (autosave + manual wrapping)
func _on_text_changed() -> void:
	autosave_note()
	enforce_manual_word_wrap()

# Save the note automatically
func autosave_note() -> void:
	var file = FileAccess.open(note_file_path, FileAccess.WRITE)
	if file:
		file.store_string(text_edit.text)
		file.close()
		print("Reminder note autosaved.")

# Load note from disk
func _load_note() -> void:
	if FileAccess.file_exists(note_file_path):
		var file = FileAccess.open(note_file_path, FileAccess.READ)
		if file:
			text_edit.text = file.get_as_text()
			file.close()
			print("Reminder note loaded.")

# Manual word wrap enforcement
func enforce_manual_word_wrap() -> void:
	var lines = text_edit.text.split("\n")
	var wrapped_lines = []

	for line in lines:
		while line.length() > MAX_CHARACTERS_PER_LINE:
			wrapped_lines.append(line.left(MAX_CHARACTERS_PER_LINE))
			line = line.substr(MAX_CHARACTERS_PER_LINE)
		wrapped_lines.append(line)

	# Only update text if wrapping actually changed it (prevents cursor reset)
	var new_text = "\n".join(wrapped_lines)
	if new_text != text_edit.text:
		text_edit.text = new_text
		# Move caret to end after modification
		text_edit.set_caret_line(text_edit.get_line_count() - 1)
		text_edit.set_caret_column(text_edit.get_line(text_edit.get_caret_line()).length())
