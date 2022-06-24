class_name Sword
extends Mob


export (float, 0.1, 1.0, 0.1) var lerp_smoothness = 1.0
export (float, 300.0, 1500.0, 10.0) var rush_speed = 300
export (int, 1, 10, 1) var MAX_WALK_CYCLES: int = 4


onready var _normal_rotation: float = $Sprite.rotation
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var hurtbox: Area2D = $Hurtbox
onready var _rush_timer: Timer = $RushTimer
onready var _raycast: RayCast2D = $RayCast2D
onready var _awaremeter: Timer = $Awaremeter

# used to tell if the mob got stuck and should search for another path
onready var _stuck_timer: Timer = $StuckTimer
onready var _RADIUS: float = get_node("DetectionArea/CollisionShape2D").shape.radius


var _is_resting: bool = true
var _should_rush: bool = false
var _is_rushing: bool = false
var _first_pos_target: Vector2


var _ORIGINAL_POS: Vector2
var _should_walk: bool = false
var _next_position: Vector2
var _walk_counts: int = 0


func _ready() -> void:
    randomize()

    _ORIGINAL_POS = global_position

    hurtbox.connect("body_entered", self, "_on_Hurtbox_entered")

    _rush_timer.connect("timeout", self, "_on_RushTimer_timeout")

    _awaremeter.connect("timeout", self, "_on_Awaremeter_timeout")


func _physics_process(delta: float) -> void:
    _on_physics_process(delta)


func _on_physics_process(delta: float) -> void:
    print(_target)

    if not _target:
        if not _is_resting:
            var rot: float = lerp_angle(_sprite.rotation, _normal_rotation, lerp_smoothness)
            _rest(rot)

        return

    var is_rushing: bool = not _rush_timer.is_stopped()

    if _should_rush:
        if is_rushing:
            rush_at_target()

            return

        _rush_timer.start()

        return

    if _before_attack_timer.is_stopped():
        if not search_for_player():
            # the target may hide while whithin attack area
            # this ensures it is out of range
            _should_do_rush(false)
            _target_within_range = false

            return
        else:
            # if the target never left the attack area
            # makes it within range again
            if _target in _attack_area.get_overlapping_bodies():
                _target_within_range = true

        orbit_target()

        point_to_target()

    if _target_within_range:
        _prepare_to_attack()

        return
    else:
        follow(_target.global_position)


func point_to_target() -> void:
    var rot: float = lerp_angle(_sprite.rotation, _target.global_position.angle_to_point(global_position), lerp_smoothness)

    _sprite.rotation = rot
    collision_shape.rotation = rot
    hurtbox.rotation = rot

    _is_resting = false


func rush_at_target() -> void:
    _velocity = _first_pos_target * rush_speed
    _velocity = move_and_slide(_velocity)


func _prepare_to_attack() -> void:
    if not is_ready_to_attack():
        return

    _first_pos_target = global_position.direction_to(_target.global_position)
    _before_attack_timer.start()


func _on_BeforeAttackTimer_timeout() -> void:
    if not _target:
        return

    _should_do_rush()

    _cooldown_timer.start()


# change the mob position to a standing position
# instead of pointing to a target
func _rest(rot: float) -> void:
    if is_equal_approx(_sprite.rotation, _normal_rotation):
        _is_resting = true
        return

    _sprite.rotation = rot
    collision_shape.rotation = rot
    hurtbox.rotation = rot


func _on_AttackArea_body_exited(body: Character) -> void:
    if not _rush_timer.is_stopped():
        return

    #_should_do_rush(false)
    _target_within_range = false


func _on_DetectionArea_body_exited(body: Character) -> void:
    #_target = null
    #_sprite_alert.visible = false

    print("body exited %s" % body)

    _target_within_range = false
    #_should_do_rush(false)


func _on_Hurtbox_entered(body: Node2D) -> void:
    _should_do_rush(false)

    _cooldown_timer.start()

    if not body.has_method("take_damage"):
        return

    body.take_damage(damage)


#unc _on_CoolDownTimer_timeout() -> void:
#    _should_do_rush(false)


# tells if the Sword should or not rush at the position target
# defaults to true
func _should_do_rush(a: bool = true) -> void:
    if not a:
        _should_rush = a
        _first_pos_target = Vector2.ZERO
        return

    _should_rush = a


func _on_RushTimer_timeout() -> void:
    _should_do_rush(false)
    _is_rushing = false

    _cooldown_timer.start()


# search for the player, return true if found
func search_for_player() -> bool:
    _raycast.look_at(_target.global_position)
    _raycast.force_raycast_update()

    if not _raycast.get_collider() == _target:
        # go back to no-threat position while searching for the player again
        _rest(lerp_angle(_sprite.rotation, _normal_rotation, lerp_smoothness))

        var is_mob_at_origin_pos: bool = _my_is_equal_approx(global_position, _ORIGINAL_POS)

        # if this condition is met, the mob should be suspicious
        # and at the timeout set up the first position to look for the player
        if _awaremeter.is_stopped() and not _next_position and _walk_counts < MAX_WALK_CYCLES:
            _awaremeter.start()

        if _next_position and _walk_counts < MAX_WALK_CYCLES:
            if get_last_slide_collision() and _stuck_timer.is_stopped():
                _stuck_timer.start()
                _set_next_position()

            # the mob dind't arrived at the location it should search for the player
            # and should move until there
            if not _my_is_equal_approx(global_position, _next_position):
                follow(_next_position)

                return false
            else:
                _next_position = Vector2.ZERO
                _awaremeter.start()

                return false
        elif _walk_counts > MAX_WALK_CYCLES-1 and not is_mob_at_origin_pos:
            follow(_ORIGINAL_POS)

            return false
        elif is_mob_at_origin_pos:
            _target = null
            _sprite_alert.visible = false
            _walk_counts = 0

        return false
    else:
        _next_position = Vector2.ZERO
        _walk_counts =  0

    return true


func _my_is_equal_approx(vec: Vector2, vec2: Vector2) -> bool:
    return (abs(vec.x - vec2.x) <= 50 and abs(vec.y - vec2.y) <= 50)


func _set_next_position() -> void:
    _next_position = _calculate_new_path()


func _calculate_new_path() -> Vector2:
    var direction: Vector2 = Vector2(rand_range(-1, 1), rand_range(-1, 1))

    var new_pos: Vector2 = position + _RADIUS * direction

    _walk_counts += 1

    return new_pos


# everytime the suspicious timer's mob timeout, look for another position
# to search for the player
func _on_Awaremeter_timeout() -> void:
    _set_next_position()
