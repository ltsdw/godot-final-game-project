extends Bomb

onready var _radius: Vector2 = Vector2($DetectionArea/CollisionShape2D.shape.radius, 0)

export(float, 0.0, 30.0, 1.0) var random_angle_degrees: float = 10.0
export(float, 100.0, 2000.0, 1.0) var max_range: float = 2000.0
export(float, 100.0, 3000.0, 1.0) var bullet_speed: float = 400.0
export(int, 1, 24, 1) var projectile_number: int = 24
export(float, 0, 6.24, 0.1) var angle_spawn = TAU / projectile_number

enum CollisionMask {
    PLAYER = 5,
    MOB = 2,
    WALL = 16,
    PLAYER_AND_WALL = 21,
    ALL = 23
}

export(CollisionMask) var c_mask: int = CollisionMask.PLAYER

func _shoot() -> void:
    var rot: float = 0

    for i in range(projectile_number):
        var spawn_pos: Vector2 = global_position + _radius.rotated(angle_spawn * i)

        var bullet: Bullet = preload("res://bullets/fire_ball/Fireball.tscn").instance()

        bullet.position = spawn_pos
        bullet.max_range = max_range
        bullet.speed = bullet_speed
        bullet.collision_mask = c_mask

        bullet.rotation += rot

        get_tree().root.call_deferred("add_child", bullet)

        rot += angle_spawn


func _on_AttackArea_body_entered(body: Character) -> void:
    _target_within_range = true

    _body_default_speed = body.speed
    body.speed = speed_slow

    _animation_player.play("will_explode")

    _shoot()
