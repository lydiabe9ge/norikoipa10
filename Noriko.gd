extends Sprite2D

# Reference to the AnimationPlayer node
@onready var animation_player: AnimationPlayer = $NorikoAnimations

# Called when the node enters the scene tree
func _ready() -> void:
	# Play the idle animation by default
	animation_player.play("Idle")

# Called when Noriko receives an input event
func _input_event(_viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if the click is on Noriko
			if get_rect().has_point(to_local(event.position)):
				# Play the action animation
				animation_player.play("Action")
				# Wait for the action animation to finish
				await animation_player.animation_finished
				# Return to the idle animation
				animation_player.play("Idle")
