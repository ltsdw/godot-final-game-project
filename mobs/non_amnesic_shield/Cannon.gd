extends "res://mobs/Cannon.gd"

var rot: float

func rotate_degree(rotation: float) -> float:
    return deg2rad(rotation / 2.0)

func shoot_at_target(target: Node2D) -> void:
    look_at(target.global_position)
    var bullet: Bullet = BulletScene.instance()
    bullet.global_transform = _position_2d.global_transform
    bullet.max_range = max_range
    bullet.speed = bullet_speed
    bullet.collision_mask = collision_mask

    bullet.rotation += rotate_degree(rot)
    get_tree().root.add_child(bullet)
