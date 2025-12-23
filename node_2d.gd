extends Node2D

var leftovers := 0

@onready var label = $LeftoversLabel
@onready var sound = $SoundPlayer
@onready var rat = $Rat

func _ready():
	update_label()

func update_label():
	label.text = "Lefovers: %d" % leftovers
	if leftovers < 10:
		rat.modulate = Color.WHITE
	elif leftovers < 25:
		rat.modulate = Color(1, 1, 0.8) # warm
	else:
		rat.modulate = Color(1, 0.8, 0.8) # slightly cursed

func _on_fridge_pressed() -> void:
	leftovers += 1
	update_label()
	if leftovers == 10:
		sound.stream = preload("res://sounds/xylophone2.wav")
	sound.play()
	rat.scale = Vector2(1.1, 0.9) # squish

func _process(delta):
	rat.scale = rat.scale.lerp(Vector2.ONE, 8 * delta)


func _on_idle_timer_timeout() -> void:
	leftovers += 1
	update_label()
	rat.scale = Vector2(1.05, 0.95) # smaller squish than click
