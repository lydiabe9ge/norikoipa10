extends Area2D

# Reference to the AnimationPlayer node
@onready var animation_player: AnimationPlayer = $"../NorikoAnimations"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the input event signal to a function
	self.input_event.connect(_on_input_event)

# Called when the area receives an input event
func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Play the action animation
		animation_player.play("Action")
