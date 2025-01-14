extends PCEditorToolBase

func _init():
	id = "2Remover"
	toolHotkey = KEY_2

func getName() -> String:
	return "Remover"

func onApply(_pc:PlayerEditor):
	var _id:int = getPC().getRaycastPropID()
	if(_id >= 0):
		_pc.doCommand("RemoveProp", {id=_id})

func process(_delta:float, _pc:PlayerEditor):
	var _node:Node3D = getPC().getRaycastNode()
	var _id:int = getPC().getRaycastPropID()
	#print(_node)
	
	if(_id < 0 || _node == null):
		return
	
	var aabb:=PlayerEditor.calculateSpatialBounds(_node, true)
	drawBoxAABB(aabb, _node.global_transform, Color.RED)
