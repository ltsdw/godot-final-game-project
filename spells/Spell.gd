# The player weapon.
#
# This class gets added as a child of the player's "SpellHolder" node. The
# SpellHolder node rotates towards the mouse; the Spell takes care of firing.
#
# By default, the Spell script will fire a bullet and give it its transform.
#
# It contains two sprites for the hands, but if you want to add a spell that
# requires only one hand, or a completely different kind of sprite, you can
# remove the texture from the sprites in inherited scenes.
class_name Spell
extends Node2D

export var bullet_scene: PackedScene

# Maximum random angle applied to the shot bullets. Controls the gun's
# precision.
export (float, 0.0, 360.0, 1.0) var random_angle_degrees := 10.0
# Maximum range a bullet can travel before it disappears.
export (float, 100.0, 2000.0, 1.0) var max_range := 2000.0
# The speed of the shot bullets.
export (float, 100.0, 3000.0, 1.0) var max_bullet_speed := 1500.0
# The firing rate of bullets
export var fire_rate := 3.0

onready var _audio := $AudioStreamPlayer2D
# The cool down timer can be used to prevent firing very rapidly
onready var _cooldown_timer := $CoolDownTimer

func _ready() -> void:
    assert(bullet_scene != null, 'Bullet Scene is not provided for "%s"' % [get_path()])
    _cooldown_timer.wait_time = 1.0 / fire_rate


# Shoots a bullet. Should run when the "shoot" input is pressed, but we leave
# that for each script that extends Spell to handle, in case some would want to
# do something else. For example, we may want a spell to shoot after a big
# wind-up animation.
func shoot() -> void:
    var bullet: Bullet = bullet_scene.instance()
    get_tree().root.add_child(bullet)
    bullet.global_transform = global_transform
    bullet.max_range = max_range
    bullet.speed = max_bullet_speed
    bullet.randomize_rotation(deg2rad(random_angle_degrees))
    _audio.play()

