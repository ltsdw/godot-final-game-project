extends Shield

var _ORIGINAL_POS: Vector2

onready var _raycast: RayCast2D = $RayCast2D
onready var _awaremeter: Timer = $Awaremeter
onready var _RADIUS: float = get_node("DetectionArea/CollisionShape2D").shape.radius

# used to tell if the mob got stuck and should search for another path
onready var _stuck_timer: Timer = $StuckTimer


var _should_walk: bool = false
var _next_position: Vector2
var _walk_counts: int = 0
const _MAX_WALKS: int = 4
const _ROT: float = 15.0


func _ready() -> void:
    randomize()

    _ORIGINAL_POS = global_position

    _awaremeter.connect("timeout", self, "_on_Awaremeter_timeout")


func _on_DetectionArea_body_exited(_body: Robot) -> void:
    pass


func _my_is_equal_approx(vec: Vector2, vec2: Vector2) -> bool:
    return (abs(vec.x - vec2.x) <= 50 and abs(vec.y - vec2.y) <= 50)


func _on_BeforeAttackTimer_timeout() -> void:
    if not _target:
        return

    _cannon.rot = 0

    for _i in range(3):
        _cannon.shoot_at_target(_target)
        _cannon.rot += _ROT

    _cooldown_timer.start()

func _on_physics_process() -> void:
    if not _target:
        return

    _raycast.look_at(_target.global_position)
    _raycast.force_raycast_update()

    if not _raycast.get_collider() == _target:
        var is_mob_at_origin_pos: bool = _my_is_equal_approx(global_position, _ORIGINAL_POS)

        # if this condition is met, the mob should be suspicious
        # and at the timeout set up the first position to look for the player
        if _awaremeter.is_stopped() and not _next_position and _walk_counts < _MAX_WALKS:
            _awaremeter.start()

        if _next_position and _walk_counts < _MAX_WALKS:
            if get_last_slide_collision() and _stuck_timer.is_stopped():
                _stuck_timer.start()
                _set_next_position()
            # the mob dind't arrived at the location it should search for the player
            # and should move until there
            if not _my_is_equal_approx(global_position, _next_position):
                follow(_next_position)
                return
            else:
                _next_position = Vector2.ZERO
                _awaremeter.start()
                return

        elif _walk_counts > _MAX_WALKS-1 and not is_mob_at_origin_pos:
            follow(_ORIGINAL_POS)

        elif is_mob_at_origin_pos:
            _target = null
            _sprite_alert.visible = false
            _walk_counts = 0

        return
    else:
        _next_position = Vector2.ZERO
        _walk_counts =  0

    if _target_within_range:
        orbit_target()

        _prepare_to_attack()
    else:
        follow(_target.global_position)


func _on_DetectionArea_body_entered(body: Robot) -> void:
    _target = body

    _sprite_alert.visible = true


func _set_next_position() -> void:
    _next_position = _calculate_new_path()


# everytime the suspicious timer's mob timeout, look for another position
# to search for the player
func _on_Awaremeter_timeout() -> void:
    _set_next_position()


func _calculate_new_path() -> Vector2:
    var direction: Vector2 = Vector2(rand_range(-1, 1), rand_range(-1, 1))

    var new_pos: Vector2 = position + _RADIUS * direction

    _walk_counts += 1

    return new_pos


func _on_collision_detection_entered(_body) -> void:
    _next_position = Vector2.ZERO
