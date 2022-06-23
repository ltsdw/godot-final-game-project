# Gives the player a new spell.
extends Pickup

# This is the spell that will be set on the player's SpellHolder
export var spell_scene: PackedScene


func _on_spell_holder_pickup(holder: SpellHolder) -> void:
    # We use the "set_spell_scene" method to pass our spell_scene to the
    # player's spell holder.
    holder.set_spell_scene(spell_scene)
    _disable()
    _animation_player.play("destroy")
