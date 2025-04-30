extends Area2D
class_name Pot1

const AburaageScript = preload("res://Aburaage.gd")

@onready var water_sprite: Sprite2D = $WaterSprite
@onready var soup_sprite: Sprite2D = $SoupSprite
@onready var soup1_sprite: Sprite2D = $Soup1Sprite
@onready var anim_player: AnimationPlayer = $fade_in_water
@onready var soup_sound: AudioStreamPlayer = $SoupSound
@onready var water_bubbles: AnimatedSprite2D = $WaterBubbles
@onready var soup_bubbles: AnimatedSprite2D = $SoupBubbles

@export_range(0.0, 1.0) var max_soup_alpha: float = 1.0
@export_range(0.0, 1.0) var max_soup1_alpha: float = 1.0

var is_filled: bool = false
var is_ready: bool = false
var dip_count: int = 0
var aburaage_area: Area2D
var current_animation_playing: String = ""

func _ready() -> void:
	water_sprite.modulate.a = 0.0
	soup_sprite.visible = true
	soup1_sprite.visible = true
	soup_sprite.modulate.a = 1.0
	soup1_sprite.modulate.a = 1.0

	if soup_sprite.material is ShaderMaterial:
		var mat: ShaderMaterial = soup_sprite.material
		mat.set_shader_parameter("transparency", 0.0)

	if soup1_sprite.material is ShaderMaterial:
		var mat1: ShaderMaterial = soup1_sprite.material
		mat1.set_shader_parameter("transparency", 0.0)

	water_bubbles.visible = false
	water_bubbles.modulate.a = 0.0
	water_bubbles.play("still")
	water_bubbles.pause()

	soup_bubbles.visible = false
	soup_bubbles.modulate.a = 0.0
	soup_bubbles.play("still")
	soup_bubbles.pause()
	soup_bubbles.z_index = soup1_sprite.z_index + 1

	collision_layer = 1
	collision_mask = 1

	aburaage_area = Area2D.new()
	aburaage_area.name = "AburaageArea"
	add_child(aburaage_area)

	var shape = RectangleShape2D.new()
	shape.size = Vector2(100, 50)

	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0, -25)
	aburaage_area.add_child(collision)

	aburaage_area.collision_layer = 2
	aburaage_area.collision_mask = 2

	aburaage_area.connect("area_entered", Callable(self, "_on_aburaage_area_entered"))
	aburaage_area.connect("area_exited", Callable(self, "_on_aburaage_area_exited"))

	add_to_group("Pot1")
	add_to_group("pot1")
	print("✅ Pot1 ready — shaders, water, soup, and bubbles initialized.")

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		if GameController.current_state == GameController.GameState.WAIT_FOR_POT1_TAP:
			fill_with_water()
			GameController.set_state(GameController.GameState.DIPPING_ABURAAGE)

func fill_with_water() -> void:
	if not is_filled:
		is_filled = true
		is_ready = false
		print("💧 Starting fade-in for water...")
		if anim_player.has_animation("fade_in_water"):
			current_animation_playing = "fade_in_water"
			if not anim_player.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
				anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
			anim_player.play("fade_in_water")
			_start_water_bubbling()
		else:
			water_sprite.modulate.a = 1.0
			is_ready = true
			_start_water_bubbling()

func remove_water() -> void:
	if is_filled:
		is_filled = false
		is_ready = false
		print("🧼 Removing water...")
		if anim_player.has_animation("fade_out_water"):
			current_animation_playing = "fade_out_water"
			if not anim_player.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
				anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
			anim_player.play("fade_out_water")
			_stop_water_bubbling()
		else:
			water_sprite.modulate.a = 0.0

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == current_animation_playing:
		if anim_name == "fade_in_water":
			water_sprite.modulate.a = 1.0
			is_ready = true
			if not water_bubbles.is_playing():
				_start_bubbling_loop()
		elif anim_name == "fade_out_water":
			water_sprite.modulate.a = 0.0
			is_ready = false
			_stop_water_bubbling()

func _start_water_bubbling() -> void:
	if water_bubbles.sprite_frames:
		water_bubbles.visible = true
		water_bubbles.play("bubbling")
		print("💧 WaterBubbles switched to bubbling (no fade)")

func _start_bubbling_loop() -> void:
	water_bubbles.play("bubbling")
	print("💧 Water bubbling animation playing!")

func _stop_water_bubbling() -> void:
	if water_bubbles.is_playing():
		water_bubbles.stop()
	water_bubbles.play("still")
	water_bubbles.pause()
	var tween = create_tween()
	tween.tween_property(water_bubbles, "modulate:a", 0.0, 0.5)
	print("🛑 Water bubbling stopped.")

func set_soup_transparency(progress: float) -> void:
	var alpha: float = clamp(progress * max_soup_alpha, 0.0, 1.0)
	if soup_sprite.material is ShaderMaterial:
		var mat: ShaderMaterial = soup_sprite.material
		mat.set_shader_parameter("transparency", alpha)
		soup_sprite.visible = alpha > 0.0
		print("🟢 SoupSprite transparency (sake): %.2f" % alpha)

		if alpha > 0.0 and not soup_sound.playing:
			soup_sound.play()
			print("✨ Shimmer sound started (sake)")
		elif alpha == 0.0 and soup_sound.playing:
			soup_sound.stop()
			print("🔇 Shimmer sound stopped (sake)")

func set_soup1_transparency(progress: float) -> void:
	var alpha: float = clamp(progress * max_soup1_alpha, 0.0, 1.0)
	var soup_alpha: float = clamp((1.0 - progress) * max_soup_alpha, 0.0, 1.0)

	if soup1_sprite.material is ShaderMaterial:
		var mat1: ShaderMaterial = soup1_sprite.material
		mat1.set_shader_parameter("transparency", alpha)
		soup1_sprite.visible = alpha > 0.0
		print("🟤 Soup1Sprite transparency (soy): %.2f" % alpha)

	if soup_sprite.material is ShaderMaterial:
		var mat0: ShaderMaterial = soup_sprite.material
		mat0.set_shader_parameter("transparency", soup_alpha)
		soup_sprite.visible = soup_alpha > 0.01
		print("⚪️ SoupSprite (sake) fade out to: %.2f" % soup_alpha)

	if (alpha > 0.0 or soup_sprite.visible) and not soup_sound.playing:
		soup_sound.play()
	elif alpha == 0.0 and not soup_sprite.visible and soup_sound.playing:
		soup_sound.stop()

# 🛠 NEW: Soup bubbling after sugar, with debug
func start_soup_bubbling_after_sugar() -> void:
	print("🔵 DEBUG: start_soup_bubbling_after_sugar() called (no fade).")

	if soup_bubbles.sprite_frames:
		print("🔵 DEBUG: soup_bubbles.sprite_frames exists.")
		if soup_bubbles.sprite_frames.has_animation("bubbling"):
			print("🔵 DEBUG: 'bubbling' animation found.")

			soup1_sprite.visible = true
			soup1_sprite.modulate.a = 1.0

			soup_bubbles.visible = true
			soup_bubbles.modulate.a = 1.0  # 🔥 Make it fully visible immediately
			soup_bubbles.play("bubbling")  # 🔥 Start bubbling directly

			print("🍜 SoupBubbles immediately visible and bubbling!")
		else:
			print("🔴 ERROR: 'bubbling' animation not found in SoupBubbles!")
	else:
		print("🔴 ERROR: soup_bubbles.sprite_frames missing!")

func _start_soup_bubbling_loop() -> void:
	print("🔵 DEBUG: _start_soup_bubbling_loop() called. Starting bubbling animation.")
	soup_bubbles.play("bubbling")

func _on_aburaage_area_entered(area: Area2D) -> void:
	if area.get_parent().get_script() == AburaageScript:
		print("🍜 Aburaage entered dipping area")

func _on_aburaage_area_exited(area: Area2D) -> void:
	if area.get_parent().get_script() == AburaageScript:
		print("🍜 Aburaage exited dipping area")

func set_water_fill_progress(progress: float) -> void:
	if not water_bubbles.visible:
		water_bubbles.visible = true
		water_bubbles.play("still")
		water_bubbles.pause()

	if water_bubbles.modulate.a < progress:
		water_bubbles.modulate.a = progress

	print("💧 WaterBubbles alpha (still):", water_bubbles.modulate.a)

func on_water_fill_finished() -> void:
	is_filled = true
	is_ready = true
	_start_water_bubbling()
	if not water_bubbles.is_playing():
		_start_bubbling_loop()
	print("✅ Water fully visible and bubbling ready.")
