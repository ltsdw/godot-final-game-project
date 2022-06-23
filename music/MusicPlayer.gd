# Plays a random sound from an array of provided sound files.
#
# If no sounds are set in the array, will play the set `stream` property like
# any regular AudioStreamPlayer.
#
# This script only works in-game, not in the editor.
class_name RandomAudioPlayer
extends AudioStreamPlayer

export(Array, AudioStream) var sounds = []

onready var _animation_player := $CanvasLayer/AnimationPlayer
onready var _label := $CanvasLayer/Label


func play(from_position = 0.0) -> void:
	if sounds:
		stream = sounds[randi() % sounds.size()]
	.play(from_position)
	_display_music_name()


func _display_music_name() -> void:
	var text := stream.resource_path.get_file().get_basename()
	_label.text = "Now playing\n" + text
	_animation_player.play("appear")
