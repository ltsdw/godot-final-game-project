extends Sprite

var _noise: OpenSimplexNoise = preload("../camera_noise.tres")
var _texture_size := 512.0

onready var _point1 := $Point1
onready var _point2 := $Point2


func _process(delta: float) -> void:
	var time_elapsed := OS.get_ticks_msec() / 20.0
	var wrapped_time := wrapf(time_elapsed, 0, _texture_size)
	var wrapped_time_2 := wrapf(time_elapsed * 2, 0, _texture_size)
	var wrapped_time_3 := wrapf(time_elapsed * 3, 0, _texture_size)
	
	_point1.position = Vector2(wrapped_time, wrapped_time_3)
	_point2.position = Vector2(wrapped_time_2, wrapped_time)
