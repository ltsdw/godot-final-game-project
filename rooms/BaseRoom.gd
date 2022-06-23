# This is the base script each room should use or extend.
#
# It takes care of spawing enemies and items, but can also optionally spawn a
# player and a teleporter.
#
# It also handles hiding and showing bridges.
#
# Note: we would rather call this class "Room", but there is already a node
# named Room in Godot, so we cannot use that name.
class_name BaseRoom
extends Node2D

# Default size of the rectangle encompassing bridges drawn in the tilemap, to
# erase the ones that don't lead to a room.
const BRIDGES_DEFAULT_SIZE := Vector2(2, 2)

# The tiles indices in the "invisible wall" tileset
const INVISIBLE_WALL_TILE_INDEX := 1
const INVISIBLE_LEDGE_TILE_INDEX := 0

# We use Rect2 values to represents the regions of the tile map where we drew
# bridges. This allows us to erase bridges that are outside of the game grid
# (the ones that don't lead to a room).
export var top_bridge := Rect2(Vector2(5, -2), BRIDGES_DEFAULT_SIZE)
export var right_bridge := Rect2(Vector2(11, 4), BRIDGES_DEFAULT_SIZE)
export var left_bridge := Rect2(Vector2(-2, 4), BRIDGES_DEFAULT_SIZE)
export var bottom_bridge := Rect2(Vector2(5, 11), BRIDGES_DEFAULT_SIZE)

onready var _bridges := $bridges
onready var _limits := $Limits
onready var _mobs_spawners := $Mobs
onready var _items_spawners := $Items
onready var _spawner_robot := $SpawnerRobot
onready var _spawner_teleporter := $SpawnerTeleporter


func _ready() -> void:
    # If we instantiate this room in another scene, we want the other scene to
    # manage the robot and the teleporter.
    #
    # But if we run the room scene directly with F6, we want to spawn the player
    # and teleporter to test the room.
    var is_main_scene = get_tree().current_scene == self
    if is_main_scene:
        spawn_robot()
        spawn_teleporter()
        spawn_mobs()
        spawn_items()
        hide_top_bridge()
        hide_right_bridge()
        hide_left_bridge()
        hide_bottom_bridge()
    else:
        # hide invisible walls
        _limits.hide()


    print(Vector2.ZERO == Vector2.ZERO)

# Spawns all the mobs
func spawn_mobs() -> void:
    for child in _mobs_spawners.get_children():
        if child is Spawner:
            child.spawn()


# Spawns all the items
func spawn_items() -> void:
    for child in _items_spawners.get_children():
        if child is Spawner:
            child.spawn()


# Spawns the player character. This should be called by the parent scene, but
# will be called by the room itself if it's run with F6.
func spawn_robot() -> void:
    _spawner_robot.spawn()


# Spawns the teleporter. This should be called by the parent scene, but will be
# called by the room itself if it's run with F6.
func spawn_teleporter() -> void:
    _spawner_teleporter.spawn()


# Hides a set of bridge cells within a 2D rectangle and replaces them with
# invisible walls to prevent the player from leaving the room and walking over
# the sky.
func _hide_bridge(bridge_region: Rect2) -> void:
    var start := bridge_region.position
    var end := start + bridge_region.size

    var x_range := range(start.x, end.x)
    var y_range := range(start.y, end.y)

    # We loop over all cells between
    for x in x_range:
        for y in y_range:
            var cell_coordinates := Vector2(x, y)
            # We remove the tile from the bridge tilemap. Passing -1 to the
            # set_cellv() function erases the tile at cell_coordinates.
            _bridges.set_cellv(cell_coordinates, -1)
            # In the limits tilemap, we draw an invisible wall to block the
            # player.
            _limits.set_cellv(cell_coordinates, INVISIBLE_WALL_TILE_INDEX)

    # There's a ledge at the bottom of islands, we need to add extra half-size
    # invisible walls in this case.
    if bridge_region == bottom_bridge:
        for x in range(start.x, end.x):
            var ledge_cell_coordinates := Vector2(x, bottom_bridge.position.y - 1)
            _limits.set_cellv(ledge_cell_coordinates, INVISIBLE_LEDGE_TILE_INDEX)


func hide_top_bridge() -> void:
    _hide_bridge(top_bridge)


func hide_left_bridge() -> void:
    _hide_bridge(left_bridge)


func hide_right_bridge() -> void:
    _hide_bridge(right_bridge)


func hide_bottom_bridge() -> void:
    _hide_bridge(bottom_bridge)
