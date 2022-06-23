# This is a simple node. All it does is:
#
# 1. Look at the mouse.
# 2. Set a weapon (spell) as a child.
#
# Since it's an Area2D, it is detected by pickups, which can use it to change
# the currently selected spell.
#
# This script only takes care of rotating towards the mouse and holding a spell.
#
# What happens when the player presses "fire" is entirely up to the spell. And
# what happens when the SpellHolder goes over a pickup is entirely up to the
# pickup.
class_name SpellHolder
extends Area2D

export var spell_scene: PackedScene setget set_spell_scene

# This is the unique child of the node. It only accepts a spell
var spell: Spell

onready var _spell_spawning_point := $SpellSpawningPoint


func _physics_process(_delta: float):
    # This function makes the node rotate towards the mouse
    look_at(get_global_mouse_position())


# This function takes care of replacing the current spell instance with a new
# one.
func set_spell_scene(scene: PackedScene) -> void:
    spell_scene = scene

    # If the node hasn't been added to the scene tree yet, pause the function until it emits its "ready" signal.
    # This is necessary if you assign a spell scene in the Inspector, as Godot will try to run this function right after creating this node in memory, before adding it to the scene tree.
    if not is_inside_tree():
        yield(self, "ready")

    if spell:
        spell.queue_free()

    if spell_scene:
        var new_spell = scene.instance()
        assert(new_spell is Spell, "You passed a scene that is not a Spell to the SpellHolder.")

        spell = new_spell
        _spell_spawning_point.add_child(spell)


func _disable() -> void:
    set_spell_scene(null)
