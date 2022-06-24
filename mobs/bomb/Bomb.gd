class_name Bomb
extends Mob


onready var _shock_area: Area2D = $ShockArea

export (float, 100, 400) var speed_slow: float = 100

var _body_default_speed: float


func _ready() -> void:
    _animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
    _shock_area.connect("body_entered", self, "_on_ShockArea_entered")


func _on_AnimationPlayer_animation_finished(animation_name: String) -> void:
    match animation_name:
        "will_explode":
            _disable()
            _die_sound.play()
            _animation_player.play("explode")
        "explode":
            queue_free()
        "RESET":
            _animation_player.play("hover")


func _on_AttackArea_body_exited(body: Character) -> void:
    _target_within_range = false

    body.speed = _body_default_speed

    match _animation_player.get_current_animation():
        "will_explode":
            _animation_player.stop()
            _animation_player.play("RESET")


func _on_AttackArea_body_entered(body: Character) -> void:
    _target_within_range = true

    _body_default_speed = body.speed
    body.speed = speed_slow

    _animation_player.play("will_explode")


func _on_ShockArea_entered(body: Node) -> void:
    if not body.has_method("take_damage"):
        return

    body.take_damage(damage)
