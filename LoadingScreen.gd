extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if animation_player:
		animation_player.play("LoadingAnimation")
	else:
		print("Error: AnimationPlayer node not found!")
	
	# Load the MainScene asynchronously
	load_main_scene()

func load_main_scene() -> void:
	print("Loading MainScene...")
	var _main_scene_loader = ResourceLoader.load_threaded_request("res://MainScene.tscn")
	
	while not ResourceLoader.load_threaded_get_status("res://MainScene.tscn") == ResourceLoader.THREAD_LOAD_LOADED:
		print("Loading progress...")
		await get_tree().create_timer(0.1).timeout  # Wait for 0.1 seconds
   
	var main_scene = ResourceLoader.load_threaded_get("res://MainScene.tscn")
	if main_scene:
		print("MainScene loaded successfully!")
		get_tree().change_scene_to_packed(main_scene)
	else:
		print("Error: Failed to load MainScene!")
