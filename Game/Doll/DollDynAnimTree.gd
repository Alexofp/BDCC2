@warning_ignore("missing_tool")
extends DynamicAnimTree
class_name DollDynAnimTree

func _ready() -> void:
	super._ready()
	setTreeDef(preload("res://Game/Doll/DollDynAnimTreeDef.gd").new())
