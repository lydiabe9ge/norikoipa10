extends Sprite2D

@export var default_texture: Texture2D         # Empty plate
@export var aburaage_texture: Texture2D        # Plate with Aburaage

@onready var soup_sprite: Sprite2D = $SoupSprite  # Must be a direct child of Plate

func _ready() -> void:
	if default_texture:
		texture = default_texture
	if soup_sprite:
		soup_sprite.visible = false
		_set_soup_transparency(0.0)

# ✅ Call when aburaage returns to plate but DO NOT show soup yet
func show_aburaage() -> void:
	if aburaage_texture:
		texture = aburaage_texture
		print("🍽️ Plate texture changed to Aburaage version.")

# ✅ Call this separately after float finishes
func show_soup_sprite() -> void:
	if soup_sprite:
		soup_sprite.visible = true
		_set_soup_transparency(1.0)
		print("🍜 SoupSprite on plate is now visible.")

# 🔁 Optional: Reset back to empty plate
func reset_plate() -> void:
	if default_texture:
		texture = default_texture
	if soup_sprite:
		_set_soup_transparency(0.0)
		soup_sprite.visible = false
	print("🔄 Plate reset to default.")

# 🎛️ Internal: Set soup shader transparency
func _set_soup_transparency(value: float) -> void:
	if soup_sprite.material is ShaderMaterial:
		var mat := soup_sprite.material as ShaderMaterial
		mat.set_shader_parameter("transparency", clamp(value, 0.0, 1.0))
