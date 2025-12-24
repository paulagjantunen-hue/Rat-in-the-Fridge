extends Label

func _ready():
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 40, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.6)\
		.set_trans(Tween.TRANS_SINE)
	tween.finished.connect(queue_free)
