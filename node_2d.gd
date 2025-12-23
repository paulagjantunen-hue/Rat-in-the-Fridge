extends Node2D

const SAVE_PATH := "user://save.json"

var rat_sprites := [
	preload("res://rats/rat1.jpg"),
	preload("res://rats/rat2.jpg"),
	preload("res://rats/rat3.jpg"),
	preload("res://rats/rat4.jpg")
]


var leftovers := 0
var sounds := [
	preload("res://sounds/note1.wav"),
	preload("res://sounds/note2.wav"),
	preload("res://sounds/note3.wav")
]
var current_sound_index := 0

@onready var label = $LeftoversLabel
@onready var sound = $SoundPlayer
@onready var rat = $Rat

func _ready():
	load_game()
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
		sound.stream = preload("res://sounds/note2.wav")
	sound.play()
	rat.scale = Vector2(1.1, 0.9) # squish
	check_sound_unlock()
	update_rat_sprite()
	save_game()

func _process(delta):
	rat.scale = rat.scale.lerp(Vector2.ONE, 8 * delta)


func _on_idle_timer_timeout() -> void:
	leftovers += 1
	update_label()
	check_sound_unlock()
	update_rat_sprite()
	rat.scale = Vector2(1.05, 0.95) # smaller squish than click
	save_game()

func check_sound_unlock():
	var new_index: int = min(int(leftovers / 10), sounds.size() -1)
	if new_index != current_sound_index:
		current_sound_index = new_index
		sound.stream = sounds[current_sound_index]

func save_game():
	var data = {
		"leftovers": leftovers,
		"sound_index": current_sound_index
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var data = JSON.parse_string(content)
	if data == null:
		return
	leftovers = data.get("leftovers", 0)
	current_sound_index = data.get("sound_index", 0)
	sound.stream = sounds[current_sound_index]
	update_label()

func update_rat_sprite():
	if leftovers < 10:
		$Rat.texture = rat_sprites[0]
	elif leftovers < 25:
		$Rat.texture = rat_sprites[1]
	elif leftovers < 50:
		$Rat.texture = rat_sprites[2]
	else:
		$Rat.texture = rat_sprites[3]
