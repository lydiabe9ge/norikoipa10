extends Node  # No `class_name` since it's an Autoload

# Enum for tracking steps
enum GameState {
	WAIT_FOR_POT1_TAP,
	DIPPING_ABURAAGE,  
	ABURAAGE_ON_PLATE,
	INGREDIENTS_POURING,
	UDON_RINSE,
	FINAL_BOWL
}

# Game state tracking
var current_state = GameState.WAIT_FOR_POT1_TAP

# Ingredient flow flags
var is_aburaage_dipped: bool = false
var is_sake_finished: bool = false
var is_soy_sauce_finished: bool = false
var is_dashi_finished: bool = false
var is_sugar_finished: bool = false

# Set current state
func set_state(new_state: GameState) -> void:
	current_state = new_state
	print(" Game state changed to:", get_state_name(new_state))

# Ingredient status setters
func set_aburaage_dipped(value: bool) -> void:
	is_aburaage_dipped = value
	print(" Aburaage dipped 3 times status set to:", value)

func set_sake_finished(value: bool) -> void:
	is_sake_finished = value
	print(" Sake pouring finished status set to:", value)

func set_soy_sauce_finished(value: bool) -> void:
	is_soy_sauce_finished = value
	print(" Soy sauce pouring finished status set to:", value)

func set_dashi_finished(value: bool) -> void:
	is_dashi_finished = value
	print(" Dashi pouring finished status set to:", value)

func set_sugar_finished(value: bool) -> void:
	is_sugar_finished = value
	if value:
		print(" Sugar pouring finished. Aburaage can float again!")
		var aburaage = get_tree().get_first_node_in_group("Aburaage")
		if aburaage and aburaage.has_method("set_sugar_done"):
			aburaage.set_sugar_done()

# ✅ Call this when Aburaage returns to second bowl
func notify_aburaage_returned_to_second_plate() -> void:
	print("📘 Aburaage returned to second bowl — snapping to Page 2.")

	var main_scene = get_tree().get_first_node_in_group("MainScene")
	if main_scene and main_scene.has_method("jump_to_page"):
		main_scene.jump_to_page(2)  # Page 2 = X: 562.5
		main_scene.paging_enabled = false  # 🔒 Keep swipe disabled

# Debug helper
func get_state_name(state: GameState) -> String:
	match state:
		GameState.WAIT_FOR_POT1_TAP: return "WAIT_FOR_POT1_TAP"
		GameState.DIPPING_ABURAAGE: return "DIPPING_ABURAAGE"
		GameState.ABURAAGE_ON_PLATE: return "ABURAAGE_ON_PLATE"
		GameState.INGREDIENTS_POURING: return "INGREDIENTS_POURING"
		GameState.UDON_RINSE: return "UDON_RINSE"
		GameState.FINAL_BOWL: return "FINAL_BOWL"
	return "UNKNOWN_STATE"

func print_state() -> void:
	print(" Current State:", get_state_name(current_state))

func _ready() -> void:
	pass
