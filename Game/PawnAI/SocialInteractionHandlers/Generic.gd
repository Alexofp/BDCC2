extends SocialInteractionHandler

var kind:String = ""

func _init() -> void:
	id = "Generic"

#func trySocialInteraction() -> void:
#	agree = 0.0

func setKind(_t:String):
	kind = _t
