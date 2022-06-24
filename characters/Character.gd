class_name Character
extends KinematicBody2D

export var max_health := 5

export var speed := 650.0

export(float, 0.01, 1.0) var drag_factor := 0.12

var health := max_health setget set_health
var velocity := Vector2.ZERO

onready var _camera: ShakingCamera2D = $ShakingCamera2D
onready var _damage_audio = $DamageAudio
onready var _death_audio = $DeathAudio
onready var _skin := $Skin
onready var _smoke_particles := $SmokeParticles
onready var _spell_holder := $SpellHolder


func _ready() -> void:
    _death_audio.connect("finished", get_tree(), "change_scene", ["res://interface/GameOver.tscn"])


func _physics_process(_delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var desired_velocity := speed * direction
    var steering := desired_velocity - velocity
    velocity += steering * drag_factor
    velocity = move_and_slide(velocity, Vector2.ZERO)
    _smoke_particles.emitting = velocity.length() > speed / 2.0


func set_health(new_health: int) -> void:
    health = clamp(new_health, 0, max_health)


func teleport() -> void:
    get_tree().change_scene("res://interface/WinGame.tscn")


func take_damage(amount: int) -> void:
    if health <= 0:
        return

    set_health(health - amount)

    if health <= 0:
        _disable()

        _skin.die()
        _death_audio.play()
        _spell_holder.hide()
    else:
        _damage_audio.play()
        _camera.shake_intensity += 0.6


func _disable() -> void:
    set_process(false)
    set_physics_process(false)
    collision_layer = 0
    collision_mask = 0


# a dummie function to be used as a mean to check if this is the character
func is_character() -> bool:
    return true
