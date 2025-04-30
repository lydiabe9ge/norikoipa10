extends Area2D
class_name Sink

@onready var faucet_water: AnimatedSprite2D = $FaucetWater

func _ready():
	faucet_water.visible = false

# Call this from Udon when it’s dragged under the sink.
func play_water_animation():
	faucet_water.visible = true
	faucet_water.play("water")  # Ensure you have an animation named "water" in FaucetWater
	print("Sink water animation started.")
