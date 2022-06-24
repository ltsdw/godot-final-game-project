extends Bullet

onready var animation_player: AnimationPlayer = $AnimationPlayer
export (float, 750, 1500) var max_speed


func _physics_process(delta: float) -> void:
    if speed < max_speed:
        speed += 750 * delta


func _ready() -> void:
    assert(max_speed > 0, "the max_speed can not be less than zero.")

    animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
    animation_player.play("spawn")


func _destroy() -> void:
    _disable()
    _audio.play()
    animation_player.play("destroy")


func _on_AnimationPlayer_animation_finished(anim_frame: String) -> void:
    if anim_frame == "destroy":
        _destroy()
