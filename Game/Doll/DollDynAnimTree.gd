@warning_ignore("missing_tool")
extends DynamicAnimTree
class_name DollDynAnimTree

var libHandler:DollAnimLibHandler = DollAnimLibHandler.new()

func _ready() -> void:
	super._ready()
	setTreeDef(preload("res://Game/Doll/DollDynAnimTreeDef.gd").new())
	
	var theAnimPlayer:AnimationPlayer = getAnimPlayer()
	libHandler.setAnimPlayer(theAnimPlayer)
	
	#libHandler.addAnimLib("LocomotionAnims")

func _enter_tree() -> void:
	ProcessBalancer.addAnimTree(self, skeleton)

func getAnimationInfo(_name:String) -> Array:
	var theInfo:Array = libHandler.getAnimationInfo(_name)
	if(!theInfo.is_empty()):
		return theInfo
	
	var theAnimPlayer:AnimationPlayer = getAnimPlayer()
	if(!theAnimPlayer):
		return [-1.0, true]
	var theAnim:Animation = theAnimPlayer.get_animation(_name)
	return [theAnim.length, theAnim.loop_mode != Animation.LOOP_NONE]
