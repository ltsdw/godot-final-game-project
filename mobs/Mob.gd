# Base class for mobs. Defines some functions you can reuse to create different
# kinds of mobs.
class_name Mob
extends KinematicBody2D


# The damage this mob inflicts when it hits the player.
export var damage := 1
# How much damage the mob can take before dying.
export var health := 2
# How much points the mob gives when killed.
export var points := 10
# How far from the player this mob will orbit.
export var orbit_distance := 200
# Movement speed in pixels per second.
export var speed := 250.0

# This will be set if the robot is in view
var _target: Character = null
# if the robot can be attacked
var _target_within_range := false

# The velocity of the enemy
var _velocity := Vector2.ZERO
# How fast the enemy can react
var _drag_factor := 6.0
# Detects when player is close

onready var _detection_area := $DetectionArea
# Detects when player is within attack range; smaller than detection area.
onready var _attack_area := $AttackArea
# Plays a sound when the mob dies.
onready var _die_sound := $DieSound
# Wind-up time just before attacking.
onready var _before_attack_timer := $BeforeAttackTimer
# Waiting time before attacking again.
onready var _cooldown_timer := $CoolDownTimer
# The enemy sprite itself. Unused in the base mob, but can be useful in
# inherited mobs.
onready var _sprite := $Sprite
# Another sprite that is visible when the enemy is alerted. Can be a different
# color, a "!" sign, anything.
onready var _sprite_alert := $Sprite/Alert
# The animation player.
onready var _animation_player := $AnimationPlayer


func _ready() -> void:
    # This area detects when the player gets in range of the mob. Use it to play
    # "wake-up" style animations, or get the mob to track the player.
    _detection_area.connect("body_entered", self, "_on_DetectionArea_body_entered")
    _detection_area.connect("body_exited", self, "_on_DetectionArea_body_exited")
    # This is another area that detects when the player gets within attack range.
    _attack_area.connect("body_entered", self, "_on_AttackArea_body_entered")
    _attack_area.connect("body_exited", self, "_on_AttackArea_body_exited")
    # We connect the die sound to call queue_free after it
    _die_sound.connect("finished", self, "_on_DieSound_finished")
    # There's a little wind up before attacking, and we attack once it times out.
    _before_attack_timer.connect("timeout", self, "_on_BeforeAttackTimer_timeout")
    _cooldown_timer.connect("timeout", self, "_on_CoolDownTimer_timeout")
    # _sprite_alert is when the player is in view. We start out with it invisible.
    _sprite_alert.visible = false

# This function can be used to know if the mob can attack.
#
# A mob can attack if and only if:
#
# 1. The player is in view.
# 2. The cooldown timer is not running.
# 3. The wind-up to attach timer is not running.
func is_ready_to_attack() -> bool:
    return (
        _target and
        _cooldown_timer.is_stopped() and
        _before_attack_timer.is_stopped()
    )


# Steers towards the target position. Use this to follow the player, or any
# other point of interest for the mob.
func follow(target_global_position: Vector2) -> void:
    var desired_velocity := global_position.direction_to(target_global_position) * speed
    var steering := desired_velocity - _velocity
    _velocity += steering / _drag_factor
    _velocity = move_and_slide(_velocity, Vector2.ZERO)


# Orbit around the target if there is one.
func orbit_target() -> void:
    if not _target:
        return
    var direction := _target.global_position.direction_to(global_position)
    var offset_from_target := direction.rotated(PI / 6.0) * orbit_distance

    follow(_target.global_position + offset_from_target)


# Called by bullets.
func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        _die()
    else:
        _animation_player.stop()
        _animation_player.play("hit")


# Disables the mob, plays the "die" animation and the "die" sound. Emits
# "mob_died" the global event bus, which will relay it. When the "die" sound
# finishes, the mob is removed.
func _die() -> void:
    _disable()
    _animation_player.play("die")
    _die_sound.play()


# Disables the mob. We remove anything that can trigger collisions again and
# leave the monster as an invisible wall. This is useful if you want to play
# death animations or sounds before queue_free, but don't want the mob to act
# anymore
func _disable() -> void:
    collision_layer = 0
    collision_mask = 0

    _detection_area.set_deferred("monitoring", false)
    _detection_area.set_deferred("monitorable", false)
    _detection_area.collision_layer = 0
    _detection_area.collision_mask = 0

    _attack_area.set_deferred("monitoring", false)
    _attack_area.set_deferred("monitorable", false)
    _attack_area.collision_mask = 0
    _attack_area.collision_layer = 0

    set_physics_process(false)

# When the die sound finishes playing, we can remove the mob.
func _on_DieSound_finished() -> void:
    queue_free()


# When the player enters the detection area, we set the _target variable and
# show the _sprite_alert node.
func _on_DetectionArea_body_entered(body: Character) -> void:
    _target = body
    _sprite_alert.visible = true


# When the player exists the detection area, we set _target to null and hide the
# _sprite_alert.
#
# If you want a mob that doesn't let the player go after seeing it, override
# this method and set it to pass. Then the mob will remember the player forever.
func _on_DetectionArea_body_exited(body: Character) -> void:
    _target = null
    _sprite_alert.visible = false


# Called when the player is within attack range.
func _on_AttackArea_body_entered(_body: Character) -> void:
    _target_within_range = true


# Called when the player exits attack range.
# every time this function is overloaded it should check if the body is a character.
func _on_AttackArea_body_exited(_body: Character) -> void:
    _target_within_range = false


# Called when the wind-up before attacking has ran out. The mob should now
# attack.
func _on_BeforeAttackTimer_timeout() -> void:
    pass


# Called when the attack was launched and recovered from. The mob is ready to
# attack again now.
func _on_CoolDownTimer_timeout() -> void:
    pass
