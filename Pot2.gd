extends Area2D
class_name Pot2

@onready var udon_bowl_sprite: Sprite2D = $UdonBowlSprite
var game_controller  # Optional: Reference your GameController if needed

func _ready():
	# Start with the udon bowl image hidden
	udon_bowl_sprite.modulate.a = 0.0
	# If using a GameController, obtain it here (adjust the path as needed)
	# game_controller = get_node("/root/CookingMiniGame/GameController")

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		fade_in_udon_bowl()

func fade_in_udon_bowl() -> void:
	var tween = create_tween()
	tween.tween_property(udon_bowl_sprite, "modulate:a", 1.0, 1.0)  # Fade in over 1 second
	print("Udon bowl image faded in.")
