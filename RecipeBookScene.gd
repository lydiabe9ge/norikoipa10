extends Control

@onready var close_area: Area2D = $CloseArea
@onready var recipe_scroll_container: ScrollContainer = $BookContainer/RecipeScrollContainer
@onready var recipe_vbox: VBoxContainer = $BookContainer/RecipeScrollContainer/RecipeVBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	print("RecipeBookScene Initialized!")

	if animation_player and animation_player.has_animation("OpenBookAnimation"):
		animation_player.play("OpenBookAnimation")

	populate_recipe_list()

	close_area.input_event.connect(_on_close_area_input_event)

# Dynamically populate recipe buttons
func populate_recipe_list():
	for recipe_name in RecipeData.recipes.keys():
		var button = Button.new()
		button.text = recipe_name
		button.pressed.connect(_on_recipe_selected.bind(recipe_name))
		recipe_vbox.add_child(button)

# Handle recipe selection
func _on_recipe_selected(recipe_name: String):
	RecipeData.selected_recipe = recipe_name
	get_tree().change_scene_to_file("res://CookingMinigame.tscn")

# Handle outside clicks
func _on_close_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Clicked outside - closing RecipeBookScene.")
		queue_free()  # This removes the pop-up
