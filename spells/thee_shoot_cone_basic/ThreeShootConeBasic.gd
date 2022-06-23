extends Spell

var rot: float


func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("shoot") and _cooldown_timer.is_stopped():
        rot = 0.0

        for _i in range(3):
            shoot()

            rot += 25.0

func rotate_degree(rotation: float) -> float:
    return deg2rad(rotation / 2.0)

func shoot() -> void:
    _cooldown_timer.start()
    var bullet: Bullet = bullet_scene.instance()
    get_tree().root.add_child(bullet)
    bullet.global_transform = global_transform
    bullet.max_range = max_range
    bullet.speed = max_bullet_speed
    bullet.rotation += rotate_degree(rot)
    _audio.play()
