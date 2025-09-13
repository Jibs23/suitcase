extends Label

var timer: float = 0.0
var time_is_running: bool = false

func _ready():
	visible = false

func start_timer() -> void:
	time_is_running = true
	visible = true

func stop_timer() -> void:
	time_is_running = false

func reset_timer() -> void:
	timer = 0.0
	text = "0.00"
	visible = false

func _process(delta: float) -> void:
	if time_is_running:
		timer += 1*delta
		text = str(timer).pad_decimals(2)