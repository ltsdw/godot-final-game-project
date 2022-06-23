# This is the base class for weapon projectiles. To use it, create a new script
# that extends Bullet.
#
# This class is flexible, it only gives every bullet basic common functionality.
# You can attach it to any Area2D node that has a child AudioStreamPlayer2D. The
# rest, like how the bullet looks or moves, is up to you.
#
# You will want to extend this script to create different kinds of bullets. In
# this script, we call functions from signal callbacks and _physics_process() so
# that you can override these functions and give new bullets unique behavior.
#
# See _move() for an example.
class_name Bullet
extends Area2D

# The speed at which the bullet travels in pixels per second. Higher speeds make
# it easier for the player to hit their target.
export var speed := 750.0
# How much damage the bullet deals to its target on contact.
export var damage := 1
# How far the bullet can travel before disappearing.
export var max_range := 1000.0

# Stores how much the bullet travelled. Once this value reaches max_range, we
# free the bullet.
var _travelled_distance = 0.0

onready var _audio := $AudioStreamPlayer2D


func _ready() -> void:
    # An AudioStreamPlayer2D node is required for the script to work, so we test
    # for it here.
    #
    # The filename property of nodes gives us the file path of the scene from
    # which we instantiated it.
    assert(_audio, "The scene %s does not contain a node called AudioStreamPlayer2D" % [filename])
    assert(
        _audio is AudioStreamPlayer2D,
        "The scene %s's audio node is not an AudioStreamPlayer2D" % [filename]
    )
    connect("body_entered", self, "_on_body_entered")


func _physics_process(delta: float) -> void:
    _move(delta)


# Adds a random angle to the current rotation in the interval [-max_angle / 2, max_angle / 2].
#
# This function directly rotates the bullet, so make sure to have set the
# bullet's rotation or transform before calling this function.
func randomize_rotation(max_angle: float) -> void:
    rotation += randf() * max_angle - max_angle / 2.0


# We call this function on every frame in _physics_process(). We put the code in
# a function so that scripts that extend Bullet can override it to customize the
# bullet's behavior.
func _move(delta: float) -> void:
    var distance := speed * delta
    var motion := transform.x * speed * delta

    position += motion

    _travelled_distance += distance
    if _travelled_distance > max_range:
        _destroy()


# Called to provoke damage on the hit body. It's in a separate function so that
# scripts that extend Bullet can override it.
func _hit_body(body: Node) -> void:
    # You can check if a node has a function defined by calling its has_method()
    # function.
    if not body.has_method("take_damage"):
        return

    body.take_damage(damage)


# Called when the bullet either hits a body, or when it travelled too far.
func _destroy() -> void:
    queue_free()


# Disables collision detection on the bullet. It's useful if you want to play an
# animation to play before calling _destroy(), but you do not want the bullet to
# continue damaging enemies.
func _disable() -> void:
    set_physics_process(false)
    set_deferred("monitoring", false)


func _on_body_entered(body: Node) -> void:
    _hit_body(body)
    _destroy()
