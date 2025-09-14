extends Label

var timer: float = 0.0
var time_is_running: bool = false


func _init() -> void:
	Logic.speedrun_timer = self

func _ready():
	visible = false

func start_timer() -> void:
	time_is_running = true
	visible = true

func stop_timer() -> void:
	time_is_running = false

func reset_timer() -> void:
	timer = 0.0
	text = "00:00.00"
	visible = false

func _process(delta: float) -> void:
	if time_is_running:
		timer += 1*delta
		var minutes = int(timer) / 60
		var seconds = int(timer) % 60
		var milliseconds = int((timer - int(timer)) * 100)
		text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
