@tool
extends PenisHandlerBase
class_name ChastityCageHandler

@export var part:DollPart
@export var cumForwardNode:Node3D
@export var cumBackNode:Node3D

# Cum particles stuff
#@export_enum(" ") var cumForwardBone: String
#@export_enum(" ") var cumInsideBone: String
var cumForwardScene:Node3D
var cumInsideScene:Node3D
const BACK_CUM_ATTACH = preload("res://Mesh/Parts/Util/Penis/BackCumAttach.tscn")
const TIP_CUM_ATTACH = preload("res://Mesh/Parts/Util/Penis/TipCumAttach.tscn")

func clearModifiers():
	if(cumForwardScene):
		cumForwardScene.queue_free()
		cumForwardScene = null
	if(cumInsideScene):
		cumInsideScene.queue_free()
		cumInsideScene = null

func createModifiers():
	clearModifiers()
	
	if(cumForwardNode):
		cumForwardScene = TIP_CUM_ATTACH.instantiate()
		cumForwardNode.add_child(cumForwardScene)
	if(cumBackNode):
		cumInsideScene = BACK_CUM_ATTACH.instantiate()
		cumBackNode.add_child(cumInsideScene)

func _ready() -> void:
	if(Engine.is_editor_hint()):
		return
	createModifiers()

func cum(_isForward:bool, _isStrapon:bool = false):
	if(_isStrapon):
		return
	if(!_isForward):
		if(cumInsideScene && cumInsideScene.getFirst()):
			CumManager.doShoot(cumInsideScene.getFirst(), RNG.randfRange(1.0, 3.0))
	else:
		if(cumForwardScene && cumForwardScene.getFirst()):
			CumManager.doShoot(cumForwardScene.getFirst(), RNG.randfRange(1.0, 3.0))

	if(_isForward):
		if(cumForwardScene):
			cumForwardScene.cum()
	else:
		if(cumInsideScene):
			cumInsideScene.cum()

@export_tool_button("Test Cum", "Callable") var doTestCum_action = doTestCum
@export_tool_button("TEST STOP ALL", "Callable") var doTestStop_action = doTestStop

func doTestStop():
	clearModifiers()

func doTestCum():
	createModifiers()
	if(cumForwardScene):
		cumForwardScene.cum()
	if(cumInsideScene):
		cumInsideScene.cum()
