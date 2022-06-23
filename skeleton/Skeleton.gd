extends Robot


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var scene: PackedScene = _spell_holder.spell_scene
    _spell_holder.set_spell_scene(null)
    _spell_holder.set_spell_scene(scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
