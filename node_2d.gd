extends Node2D

var leftovers := 0

@onready var label = $LeftoversLabel
@onready var sound = $SoundPlayer

func _ready():
	update_label()

func _on_Fridge_pressed():
	leftovers += 1
	update_label()
	if leftovers == 10:
		sound.stream = preload("res://sounds/xylophone2.wav")
	
	sound.play()

func update_label():
	label.text = "Lefovers: %d" % leftovers

func _on_fridge_pressed() -> void:
	leftovers += 1
	update_label()
	if leftovers == 10:
		sound.stream = preload("res://sounds/xylophone2.wav")
