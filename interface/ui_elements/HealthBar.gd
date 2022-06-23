# A health bar for the player. This component connects to the global events bus
# and updates automatically (see Events.gd for more information).
#
# The health bar uses the tool mode so that you can directly test it in the
# editor and see how it looks with different amounts of health.
#
# To draw the health, we instantiate one TextureRect for each health point.
tool
class_name UIHealthBar
extends HBoxContainer

export var heart_full: Texture
export var heart_empty: Texture

export var max_health := 5 setget set_max_health
export var health := 5 setget set_health


func _ready() -> void:
	_redraw_health_bar()


# Called when modifying the health property or when Events emits the
# "player_health_changed" signal.
func set_health(new_health: int) -> void:
	# The clamp() function prevents the new_health from going over max_health or
	# below 0.
	health = clamp(new_health, 0, max_health)
	_redraw_health_bar()


# Setter for max_health. We need a setter because we need to redraw the bar when
# max_health changes.
func set_max_health(new_max_health: int) -> void:
	max_health = new_max_health
	_redraw_health_bar()


func _redraw_health_bar() -> void:
	# Because we use individual TextureRect nodes to draw health points, to
	# redraw the bar, we delete all the existing nodes and create new ones with
	# the appropriate texture.
	for child in get_children():
		child.queue_free()

	# We need as many nodes as there is max_health: one texture per health
	# point.
	for index in max_health:
		var heart := TextureRect.new()
		# As long as index is below or equal to health, draw a full heart.
		if index < health:
			heart.texture = heart_full
		# When index is higher than health, draw an empty heart.
		else:
			heart.texture = heart_empty
		add_child(heart)
