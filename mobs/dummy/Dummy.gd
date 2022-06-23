extends Mob


#onready var _tween := $Tween
onready var _dummy_area: Area2D = $DummyArea

func _ready() -> void:
    _dummy_area.connect("body_entered", self, "_on_DummyArea_entered")


#func take_damage(damage = 1,element = "Neutral"):
#    _tween.interpolate_property(self,"rotation",-1,0,0.8,Tween.TRANS_ELASTIC,Tween.EASE_OUT)
#    _tween.start()
#    match element:
#        "FIRE":
#            pass
#        "THUNDER":
#            pass
#        "ICE":
#            pass


func _on_DummyArea_entered(body: Robot) -> void:
    pass
