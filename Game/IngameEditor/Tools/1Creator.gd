extends PCEditorToolBase

var isShifting:bool = false
var shiftAxis:Vector3 = Vector3.ZERO

var addPos:Vector3 = Vector3(0.0, 0.0, 0.0)
var addAng:Vector3 = Vector3(0.0, 0.0, 0.0)
var curScale:float = 1.0

var gridEnabled:bool = true
var angSnap:float = 45.0
var angFromNormal:bool = false

var gridVertical:float = 1.0
var gridHorizontal:float = 1.0
var gridOffsetSnap:float = 0.1

var symmAxis:String = ""
var symmPoint:Vector3 = Vector3(0.0, 0.0, 0.0)

enum WheelActionType {
	RotateY,
	RotateY45,
	RotateY90,
	MoveZ,
	Scale,
	Scale01,
	SwitchMesh,
}

var wheelAction := WheelActionType.RotateY
var wheelShiftAction := WheelActionType.MoveZ
var wheelAltAction := WheelActionType.SwitchMesh

const wheelActionSelectorTypes := [
	[WheelActionType.RotateY, "Rotate 15 deg"],
	[WheelActionType.RotateY45, "Rotate 45 deg"],
	[WheelActionType.RotateY90, "Rotate 90 deg"],
	[WheelActionType.MoveZ, "Move on Z"],
	[WheelActionType.Scale, "Scale"],
	[WheelActionType.Scale01, "Scale by 0.1"],
	[WheelActionType.SwitchMesh, "Select next prop"],
]

func _init():
	id = "1Creator"
	toolHotkey = KEY_1

func getName() -> String:
	return "Creator"

func getSettings() -> Dictionary:
	return {
		"gridEnabled": {
			name = "Grid snap enabled (HotKey = G)",
			type = "bool",
			value = gridEnabled,
		},
		"gridOffset": {
			name = "Grid offset (HotKeys = Z/X/C, Reset = R)",
			type = "vec3",
			value = addPos,
			step = 0.01,
		},
		"gridOffsetSnap": {
			name = "Grid offset snap",
			type = "floatPresets",
			value = gridOffsetSnap,
			presets = [
				0.1, 0.2, 0.5, 1.0, 2.0, 4.0,
			],
			step = 0.01,
		},
		"gridHorizontal": {
			name = "Horizontal grid snap",
			type = "floatPresets",
			value = gridHorizontal,
			presets = [
				0.1, 0.2, 0.5, 1.0, 2.0, 4.0,
			],
			step = 0.01,
		},
		"gridVertical": {
			name = "Vertical grid snap",
			type = "floatPresets",
			value = gridVertical,
			presets = [
				0.1, 0.2, 0.5, 1.0, 2.0, 4.0,
			],
			step = 0.01,
		},
		"angSnap": {
			name = "Angle snap",
			type = "floatPresets",
			value = angSnap,
			presets = [
				0.0, 5.0, 15.0, 30.0, 45.0, 90.0,
			],
		},
		"addAng": {
			name = "Angle extra",
			type = "vec3",
			value = addAng,
			step = 0.01,
		},
		"angFromNormal": {
			name = "Angle from normal (HotKey = N)",
			type = "bool",
			value = angFromNormal,
		},
		"curScale": {
			name = "Scale",
			type = "floatPresets",
			value = curScale,
			presets = [
				0.25, 0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 8.0, 10.0,
			],
		},
		"wheelAction": {
			name = "Wheel action",
			type = "selector",
			value = wheelAction,
			values = wheelActionSelectorTypes,
		},
		"wheelShiftAction": {
			name = "Wheel+Shift action",
			type = "selector",
			value = wheelShiftAction,
			values = wheelActionSelectorTypes,
		},
		"wheelAltAction": {
			name = "Wheel+Alt action",
			type = "selector",
			value = wheelAltAction,
			values = wheelActionSelectorTypes,
		},
		"symmAxis": {
			name = "Symmetry",
			type = "selector",
			value = symmAxis,
			values = [
				["", "Disable"],
				["x", "X"],
				["y", "Y"],
				["z", "Z"],
			],
		},
		"symmPoint": {
			name = "Symmetry Point",
			type = "vec3",
			value = symmPoint,
			step = 0.01,
		},
	}

func applySetting(_id:String, _value:Variant) -> bool:
	if(_id == "gridEnabled"):
		gridEnabled = _value
	if(_id == "gridOffset"):
		addPos = _value
	if(_id == "angSnap"):
		angSnap = _value
	if(_id == "gridHorizontal"):
		gridHorizontal = _value
	if(_id == "gridVertical"):
		gridVertical = _value
	if(_id == "gridOffsetSnap"):
		gridOffsetSnap = _value
	if(_id == "addAng"):
		addAng = _value
	if(_id == "wheelAction"):
		wheelAction = _value
	if(_id == "wheelShiftAction"):
		wheelShiftAction = _value
	if(_id == "wheelAltAction"):
		wheelAltAction = _value
	if(_id == "angFromNormal"):
		angFromNormal = _value
	if(_id == "curScale"):
		curScale = _value
	if(_id == "symmAxis"):
		if(symmAxis == "" && _value != ""):
			symmPoint = processCursorPosition(getPC().position)
		symmAxis = _value
	if(_id == "symmPoint"):
		symmPoint = _value
	
	return false

func onApply(_pc:PlayerEditor):
	var theProp:PCEditorProp = getPC().getCurrentProp()
	if(theProp == null):
		return
	#addEditorChildToMousePos(preload("res://Mapping/Walls/test_wall.tscn").instantiate())
	_pc.doCommand("PlaceProp", {prop=theProp})
	if(symmAxis != ""):
		_pc.doCommand("PlaceProp", {prop=theProp, symmetry=symmAxis, symmetryPoint=symmPoint})

func onApplyAlt(_pc:PlayerEditor):
	var _id:int = getPC().getRaycastPropID()
	if(_id >= 0):
		var newProp := getPC().getPropByID(_id)
		if(newProp != null):
			getPC().setNewSelectedProp(newProp, getPC().getPropSettingsByID(_id))
			showMessage("Picked prop", 1.0)

func onSelect(_pc:PlayerEditor):
	addPos = Vector3()
	updatePreview()

func updatePreview():
	var theProp:PCEditorProp = getPC().getCurrentProp()
	if(theProp == null):
		getPC().setPreviewNode(null)
		return
	
	var greenPreview:bool = true
	if(theProp.path.get_file().begins_with("Decal")):
		greenPreview = false
	getPC().setPreviewNode(load(theProp.path).instantiate(), greenPreview)

func onSelectedPropChanged(_pc:PlayerEditor):
	updatePreview()

func shouldFreezeCameraRotation() -> bool:
	#return true
	return isShifting

func shouldUnlockMouse() -> bool:
	return false#isShifting

func onCapturedMouseMotion(_event:InputEventMouseMotion):
	if(isShifting):
		var mouse_delta:Vector2 = _event.relative
		var camera := getPC().get_viewport().get_camera_3d()
		#var camera_to_object := (getPC().getRaycastPositionRaw() - camera.global_transform.origin).normalized()
		
		var sensitivity: float = 0.002
		var screen_delta = Vector3(mouse_delta.x, -mouse_delta.y, 0) * sensitivity
		
		var movement_3d:Vector3= camera.global_transform.basis.x * screen_delta.x + camera.global_transform.basis.y * screen_delta.y
		var constrained_movement := (shiftAxis) * rotatePosByAngle(shiftAxis).dot(movement_3d)
		
		addPos += constrained_movement
		#var movementAmount:Vector2= _event.relative * 0.03  
		#
		#var movementVector:Vector3 = shiftDir * movementAmount.x
		#if(shiftDir == Vector3.UP):
			#movementVector = shiftDir * -movementAmount.y
		#
		#if(shiftDir != Vector3.ZERO):
			#var thePreview:Node3D = getPC().getPreviewNode()
			#if(thePreview != null):
				#thePreview.global_position += (movementVector)
	pass

func onKeyPressed(_physicalCode:int, _event:InputEventKey):
	if(_physicalCode == KEY_R):# && isShifting):
		isShifting = false
		addPos = Vector3()
		addAng = Vector3()
		curScale = 1.0
	if(_physicalCode == KEY_L):# && isShifting):
		var angDot:float = getPC().basis.tdotx(Vector3.FORWARD) + 1.0
		var newAxis:String = "x"
		if(angDot > 0.5 && angDot < 1.5):
			newAxis = "x"
		else:
			newAxis = "z"
		var newSymmPoint:Vector3 = processCursorPosition(getPC().position)
		#print(newSymmPoint, " ",symmPoint)
		if(symmAxis == newAxis && newSymmPoint == symmPoint):
			symmAxis = ""
			showMessage("Symmetry disabled")
		else:
			symmAxis = newAxis
			showMessage("Symmetry: "+newAxis+", symmetry point: "+str(symmPoint))
		symmPoint = newSymmPoint
	if(_physicalCode == KEY_N):
		angFromNormal = !angFromNormal
	if(_physicalCode == KEY_Z):
		if(isShifting && shiftAxis == Vector3.UP):
			isShifting = false
			shiftAxis = Vector3.ZERO
			return
		isShifting = true
		shiftAxis = Vector3.UP
	if(_physicalCode == KEY_X):
		if(isShifting && shiftAxis == Vector3.RIGHT):
			isShifting = false
			shiftAxis = Vector3.ZERO
			return
		isShifting = true
		shiftAxis = Vector3.RIGHT
	if(_physicalCode == KEY_C):
		if(isShifting && shiftAxis == Vector3.FORWARD):
			isShifting = false
			shiftAxis = Vector3.ZERO
			return
		isShifting = true
		shiftAxis = Vector3.FORWARD
	if(_physicalCode == KEY_G):
		gridEnabled = !gridEnabled

func processCursorScale(_scale:Vector3) -> Vector3:
	return _scale * curScale

func processCursorPosition(_pos:Vector3) -> Vector3:
	var newPos:Vector3 = roundVecSep(_pos, gridHorizontal, gridVertical, gridHorizontal) if gridEnabled else _pos
	
	#if(isAddingShiftLocally()):
		#var angle:=getPC().getRaycastAngleRad()
		#var rotation_basis: Basis = Basis().rotated(Vector3(1, 0, 0), angle.x)
		#rotation_basis = rotation_basis.rotated(Vector3(0, 1, 0), angle.y)
		#rotation_basis = rotation_basis.rotated(Vector3(0, 0, 1), angle.z)
		#
		#var rotated_position: Vector3 = rotation_basis * (addPos)
		#
		#newPos += roundVec(rotated_position, gridOffsetSnap)
	#else:
	newPos += roundVec(rotatePosByAngle(addPos), gridOffsetSnap)
	
	return newPos

func isAddingShiftLocally() -> bool:
	return true

func rotatePosByAngle(somepose:Vector3) -> Vector3:
	if(isAddingShiftLocally()):
		var angle:=getPC().getRaycastAngleRad()
		var rotation_basis: Basis = Basis().rotated(Vector3(1, 0, 0), angle.x)
		rotation_basis = rotation_basis.rotated(Vector3(0, 1, 0), angle.y)
		rotation_basis = rotation_basis.rotated(Vector3(0, 0, 1), angle.z)
		
		var rotated_position: Vector3 = rotation_basis * (somepose)
		return rotated_position
	else:
		return somepose

func processCursorRotationDeg(_ang:Vector3) -> Vector3:
	var theGrid:float = angSnap
	if(angFromNormal):
		return roundVec(getPC().getRaycastNormalAngRaw(), 0.001) + addAng
	return roundVec(_ang, theGrid) + addAng

func process(_delta:float, _pc:PlayerEditor):
	if(isShifting):
		DebugDraw.draw_ray_3d(_pc.getRaycastPosition(), rotatePosByAngle(shiftAxis), 1.0, Color.YELLOW)
		DebugDraw.draw_ray_3d(_pc.getRaycastPosition(), -rotatePosByAngle(shiftAxis), 1.0, Color.ORANGE)
	
	if(symmAxis != ""):
		var startBoxPos:Vector3 = Vector3(0.0, 0.0, 0.0)
		if(symmAxis == "x"):
			startBoxPos = Vector3(symmPoint.x, _pc.position.y, _pc.position.z)
		if(symmAxis == "y"):
			startBoxPos = Vector3(_pc.position.x, symmPoint.y, _pc.position.z)
		if(symmAxis == "z"):
			startBoxPos = Vector3(_pc.position.x, _pc.position.y, symmPoint.z)
		for _i in range(5):
			var debBoxSize:Vector3 = Vector3(0.1, 0.1, 0.1)
			var debBoxSizeS:float = 2.0*_i+0.01
			if(symmAxis == "x"):
				debBoxSize = Vector3(0.01, 5.0, debBoxSizeS)
			if(symmAxis == "y"):
				debBoxSize = Vector3(debBoxSizeS, 0.01, debBoxSizeS)
			if(symmAxis == "z"):
				debBoxSize = Vector3(debBoxSizeS, 5.0, 0.01)
			DebugDraw.draw_box(startBoxPos, debBoxSize, Color.RED)
	#var aabb:=PlayerEditor.calculateSpatialBounds(_node, true)
	#drawBoxAABB(aabb, _node.global_transform, Color.RED)

func getText() -> String:
	var resultText:String = ""
	resultText += "Offset: "+ str(roundVec(addPos, gridOffsetSnap))+"\n"
	resultText += "Pos: "+ str(getPC().getRaycastPosition())+"\n"
	resultText += "Ang: "+ str(getPC().getRaycastAngleDeg())+(" (normal-aligned)" if angFromNormal else "")+"\n"
	resultText += "Scale: "+ str(curScale)+"\n"
	
	return resultText

func onMouseWheel(_isUp:bool):
	var isShiftPressed:bool = Input.is_physical_key_pressed(KEY_SHIFT)
	var isAltPressed:bool = Input.is_physical_key_pressed(KEY_ALT)
	var wheelActToTest := wheelAction
	if(isShiftPressed):
		wheelActToTest = wheelShiftAction
	if(isAltPressed):
		wheelActToTest = wheelAltAction
	
	if(wheelActToTest == WheelActionType.RotateY):
		if(angFromNormal):
			addAng.z += (15.0 if _isUp else -15.0)
			addAng.z = fmod(addAng.z, 360.0)
		else:
			addAng.y += (15.0 if _isUp else -15.0)
			addAng.y = fmod(addAng.y, 360.0)
	if(wheelActToTest == WheelActionType.RotateY45):
		if(angFromNormal):
			addAng.z += (45.0 if _isUp else -45.0)
			addAng.z = fmod(addAng.z, 360.0)
		else:
			addAng.y += (45.0 if _isUp else -45.0)
			addAng.y = fmod(addAng.y, 360.0)
	if(wheelActToTest == WheelActionType.RotateY90):
		if(angFromNormal):
			addAng.z += (90.0 if _isUp else -90.0)
			addAng.z = fmod(addAng.z, 360.0)
		else:
			addAng.y += (90.0 if _isUp else -90.0)
			addAng.y = fmod(addAng.y, 360.0)
	if(wheelActToTest == WheelActionType.MoveZ):
		addPos.y += (0.1 if _isUp else -0.1)
	if(wheelActToTest == WheelActionType.SwitchMesh):
		if(!_isUp):
			getPC().selectNextProp()
		else:
			getPC().selectPrevProp()
	if(wheelActToTest == WheelActionType.Scale):
		if(!_isUp):
			if(curScale <= 1.0):
				curScale *= 0.5
			else:
				curScale -= 1.0
		else:
			if(curScale >= 1.0):
				curScale += 1
			else:
				curScale *= 2.0
	if(wheelActToTest == WheelActionType.Scale01):
		if(!_isUp):
			curScale -= 0.1
		else:
			curScale += 0.1
