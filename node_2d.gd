extends Node2D

# --- Variables ---
var leftovers: int = 0
var fridge_level: int = 1
var prestige_points: int = 0
var prestige_multiplier: float = 1.0
var current_sound_index: int = 0
const SAVE_PATH := "user://save.json"

# --- Load Rat Sprites ---
var rat_sprites := [
	preload("res://rats/rat1.jpg"),
	preload("res://rats/rat2.jpg"),
	preload("res://rats/rat3.jpg"),
	preload("res://rats/rat4.jpg")
]

# --- Load Sounds ---
var sounds := [
	preload("res://sounds/note1.wav"),
	preload("res://sounds/note2.wav"),
	preload("res://sounds/note3.wav"),
	preload("res://sounds/note4.wav")
]

# --- Node References ---
@onready var rat = $Rat
@onready var fridge_button = $Fridge
@onready var upgrade_button = $UpgradeButton
@onready var prestige_button = $PrestigeButton
@onready var label_leftovers = $Label_Leftovers
@onready var label_fridge = $Label_FridgeLevel
@onready var label_prestige = $Label_Prestige
@onready var idle_timer = $IdleTimer
@onready var tween = $RatTween
@onready var sound = AudioStreamPlayer2D.new()

func _ready():
	add_child(sound)
	load_game()
	update_labels()
	idle_timer.start()

# --- Rat Squish Animation ---
func play_rat_squish(scale_x: float, scale_y: float):
	tween.stop_all()
	tween.tween_property(rat, "scale", Vector2(scale_x, scale_y), 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.tween_property(rat, "scale", Vector2(1,1), 0.2, Tween.TRANS_SINE, Tween.EASE_IN, 0.1)

# --- Random Sound Playback ---
func play_random_sound():
	var max_index: int = min(current_sound_index, sounds.size() - 1)
	var random_index: int = randi() % (max_index + 1)

	sound.stream = sounds[random_index]
	sound.play()

# --- Update Rat Sprite ---
func update_rat_sprite():
	if leftovers < 10:
		rat.texture = rat_sprites[0]
	elif leftovers < 25:
		rat.texture = rat_sprites[1]
	elif leftovers < 50:
		rat.texture = rat_sprites[2]
	else:
		rat.texture = rat_sprites[3]

# --- Check Sound Unlock ---
func check_sound_unlock():
	var new_index = min(int(leftovers / 10), sounds.size() - 1)
	if new_index != current_sound_index:
		current_sound_index = new_index
		sound.stream = sounds[current_sound_index]

# --- Update UI Labels ---
func update_labels():
	label_leftovers.text = "Leftovers: %d" % leftovers
	label_fridge.text = "Fridge Level: %d" % fridge_level
	label_prestige.text = "Prestige: %d" % prestige_points

# --- Save / Load ---
func save_game():
	var data = {
		"leftovers": leftovers,
		"fridge_level": fridge_level,
		"prestige_points": prestige_points,
		"current_sound_index": current_sound_index,
		"last_play_time": Time.get_unix_time_from_system()
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
	fridge_level = data.get("fridge_level", 1)
	prestige_points = data.get("prestige_points", 0)
	current_sound_index = data.get("current_sound_index", 0)

	var last_play_time: float = data.get("last_play_time", Time.get_unix_time_from_system())

	# get current time
	var now: float = Time.get_unix_time_from_system()

	# seconds elapsed
	var elapsed_seconds: int = int(now - last_play_time)
	elapsed_seconds = min(elapsed_seconds, 3600) # optional cap

	leftovers += elapsed_seconds * int(fridge_level * prestige_multiplier)

	update_labels()
	sound.stream = sounds[current_sound_index]
	update_rat_sprite()


func _on_fridge_button_up() -> void:
	var gain = int(fridge_level * prestige_multiplier)
	leftovers += gain
	update_labels()
	check_sound_unlock()
	update_rat_sprite()
	play_rat_squish(1.1, 0.9)
	play_random_sound()
	save_game()


func _on_upgrade_button_pressed() -> void:
	var upgrade_cost = 50 * fridge_level
	if leftovers >= upgrade_cost:
		leftovers -= upgrade_cost
		fridge_level += 1
		update_labels()
		save_game()


func _on_prestige_button_pressed() -> void:
	if leftovers < 100:
		return
	prestige_points += 1
	prestige_multiplier = 1.0 + prestige_points * 0.1
	leftovers = 0
	fridge_level = 1
	current_sound_index = 0
	update_labels()
	save_game()


func _on_idle_timer_timeout() -> void:
	var gain = int(fridge_level * prestige_multiplier)
	leftovers += gain
	update_labels()
	check_sound_unlock()
	update_rat_sprite()
	play_rat_squish(1.05, 0.95)
	play_random_sound()
	save_game()
