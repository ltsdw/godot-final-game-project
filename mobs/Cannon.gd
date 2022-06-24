# A cannon node, similar to the player's, but instead of following the mouse
# like the player's weapon, it rotates towards any arbitrary target.
#
# It extends Sprite so that you can give it a texture, but it doesn't need one
# to function. Setting a sprite can help to visualize the cannon's direction,
# for debugging purposes.
extends Sprite

# The cannon can target either the player or mobs. Since the cannon is supposed
# to be used by mobs, it defaults to the player.
enum CollisionMask {
    PLAYER = 5,
    MOB = 2,
    WALL = 16,
    PLAYER_AND_WALL = 21,
    ALL = 23
}

# Load a bullet scene to shoot here
export var BulletScene: PackedScene

# Decides what collision mask the next ejected bullet will be
export(CollisionMask) var collision_mask := CollisionMask.PLAYER_AND_WALL

# Maximum random angle applied to the shot bullets in degrees. Controls the
# cannon's precision.
export(float, 0.0, 30.0, 1.0) var random_angle_degrees := 10.0
# Maximum distance a bullet can travel before it disappears.
export(float, 100.0, 2000.0, 1.0) var max_range := 2000.0
# The speed of the shot bullets.
export(float, 100.0, 3000.0, 1.0) var bullet_speed := 400.0

# This is the exit where the bullets will be spit out from
onready var _position_2d := $Position2D


# Shoots the bullet in direction of the provided target
func shoot_at_target(target: Node2D) -> void:
    look_at(target.global_position)
    var bullet: Bullet = BulletScene.instance()
    bullet.global_transform = _position_2d.global_transform
    bullet.max_range = max_range
    bullet.speed = bullet_speed
    bullet.collision_mask = collision_mask
    # We exported the angle in degrees because it's easier to edit in the
    # inspector, but the randomize_rotation() function needs the angle in
    # radians, so we convert the angles with deg2rad().
    bullet.randomize_rotation(deg2rad(random_angle_degrees))
    get_tree().root.add_child(bullet)
