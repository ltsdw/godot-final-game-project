class_name SpellIcePunch
extends Spell


func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("shoot") and _cooldown_timer.is_stopped():
        shoot()

func shoot() -> void:
    _cooldown_timer.start()
    .shoot()
