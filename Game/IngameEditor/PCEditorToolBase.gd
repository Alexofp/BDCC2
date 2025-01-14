extends RefCounted
class_name PCEditorToolBase

var id:String = "error"
var pcRef:WeakRef

var toolHotkey:int = -1

func getName() -> String:
	return "FILL ME "+id

func onApply(_pc:PlayerEditor):
	print("USED TOOL "+getName())

func onApplyAlt(_pc:PlayerEditor):
	print("USED (ALT) TOOL "+getName())

func onMouseWheel(_isUp:bool):
	#print(isUp)
	pass

func onSelect(_pc:PlayerEditor):
	pass

func onSelectedPropChanged(_pc:PlayerEditor):
	pass

func onDeselect(_pc:PlayerEditor):
	_pc.clearPreviewNode()

func getSettings() -> Dictionary:
	return {
	}

func applySetting(_id:String, _value:Variant) -> bool:
	return false

func setPC(_newPC):
	pcRef = weakref(_newPC)

func getPC() -> PlayerEditor:
	if(pcRef == null):
		return null
	return pcRef.get_ref()

func shouldFreezeCameraRotation() -> bool:
	return false

func shouldUnlockMouse() -> bool:
	return false

func onCapturedMouseMotion(_event:InputEventMouseMotion):
	pass

func onKeyPressed(_physicalCode:int, _event:InputEventKey):
	pass

func processCursorPosition(_pos:Vector3) -> Vector3:
	return _pos

func processCursorRotationDeg(_ang:Vector3) -> Vector3:
	return _ang
	
func processCursorScale(_scale:Vector3) -> Vector3:
	return _scale

func roundVec(_vec:Vector3, _howMuch:float = 1.0):
	if(_howMuch <= 0.0):
		return _vec
	return Vector3(round(_vec.x/_howMuch)*_howMuch, round(_vec.y/_howMuch)*_howMuch, round(_vec.z/_howMuch)*_howMuch)

func roundVecSep(_vec:Vector3, _howMuchX:float = 1.0, _howMuchY:float = 1.0, _howMuchZ:float = 1.0):
	if(_howMuchX <= 0.0):
		_howMuchX = 0.001
	if(_howMuchY <= 0.0):
		_howMuchY = 0.001
	if(_howMuchZ <= 0.0):
		_howMuchZ = 0.001
	return Vector3(round(_vec.x/_howMuchX)*_howMuchX, round(_vec.y/_howMuchY)*_howMuchY, round(_vec.z/_howMuchZ)*_howMuchZ)

func process(_delta:float, _pc:PlayerEditor):
	pass

func drawBoxAABB(aabb: AABB, transform:Transform3D, color = Color.WHITE, linger_frames = 0):
	var mi := DebugDraw._get_box()
	var mat := DebugDraw._get_line_material()
	mat.albedo_color = color
	mi.material_override = mat
	mi.position = aabb.get_center()
	mi.scale = aabb.size
	mi.transform = transform * mi.transform
	DebugDraw._boxes.append({
		"node": mi,
		"frame": Engine.get_frames_drawn() + DebugDraw.LINES_LINGER_FRAMES + linger_frames
	})

func getText() -> String:
	return ""

func getHotkey() -> int:
	return toolHotkey

func showMessage(theText:String, timeShow:float=3.0):
	getPC().showMessage(theText, timeShow)

func getTool(_otherToolID:String):
	var _pc:PlayerEditor = getPC()
	
	if(_pc.tools.has(_otherToolID)):
		return _pc.tools[_otherToolID]
	return null
