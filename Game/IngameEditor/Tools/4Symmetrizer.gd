extends PCEditorToolBase

var gridHorizontal:float = 1.0

func _init():
	id = "4Symmetrizer"
	toolHotkey = KEY_4

func getName() -> String:
	return "Symmetrizer"

func getSettings() -> Dictionary:
	return {
		"gridHorizontal": {
			name = "Axis snap",
			type = "floatPresets",
			value = gridHorizontal,
			presets = [
				0.1, 0.2, 0.5, 1.0, 2.0, 4.0,
			],
			step = 0.01,
		},
	}

func applySetting(_id:String, _value:Variant) -> bool:
	if(_id == "gridHorizontal"):
		gridHorizontal = _value
	return false

func onApply(_pc:PlayerEditor):
	var creatorTool = getTool("1Creator")
	if(creatorTool == null):
		return
	if(creatorTool.symmAxis == ""):
		return
	var _id:int = _pc.getRaycastPropID()
	if(_id >= 0):
		var theProp:PCEditorProp = _pc.getPropByID(_id)
		var theNode:Node3D = _pc.getNodeByID(_id)
		
		var mirrorPos:Vector3 = _pc.symmetrize_position(theNode.position, creatorTool.symmAxis, creatorTool.symmPoint)
		var _symmID:int = _pc.findEntryIDNearPos(theProp, mirrorPos)
		
		var newTransform:Transform3D = theNode.transform
		newTransform.origin = _pc.symmetrize_position(newTransform.origin, creatorTool.symmAxis, creatorTool.symmPoint)
		newTransform.basis = _pc.mirror_basis_across_axis(newTransform.basis, creatorTool.symmAxis)
		_pc.doCommand("PlaceProp", {prop=theProp, gtransform=newTransform, settings=_pc.getPropSettingsByID(_id)})
		
		if(_symmID >= 0):
			_pc.doCommand("RemoveProp", {id=_symmID})
			showMessage("Removed duplicate and symmetrized")
		else:
			showMessage("Symmetrized")
		#print(_symmID)
		##getPC().applySettingsToProp(_id, settings)
		#_pc.doCommand("ChangeSettings", {id=_id, settings=settings})
		#showMessage("Pasted settings", 1.0)
	#pass
	pass

func onApplyAlt(_pc:PlayerEditor):
	var creatorTool = getTool("1Creator")
	if(creatorTool == null):
		return
	var oldGridEnabled = creatorTool.gridEnabled
	var oldGridHorizontal = creatorTool.gridHorizontal
	creatorTool.gridEnabled = true
	creatorTool.gridHorizontal = gridHorizontal
	creatorTool.onKeyPressed(KEY_L, null)
	creatorTool.gridEnabled = oldGridEnabled
	creatorTool.gridHorizontal = oldGridHorizontal
	#var angDot:float = getPC().basis.tdotx(Vector3.FORWARD) + 1.0
	#var newAxis:String = "x"
	#if(angDot > 0.5 && angDot < 1.5):
		#newAxis = "x"
	#else:
		#newAxis = "z"
	#var newSymmPoint:Vector3 = creatorTool.processCursorPosition(getPC().position)
	##print(newSymmPoint, " ",symmPoint)
	#if(creatorTool.symmAxis == newAxis && newSymmPoint == creatorTool.symmPoint):
		#creatorTool.symmAxis = ""
		#showMessage("Symmetry disabled")
	#else:
		#creatorTool.symmAxis = newAxis
		#showMessage("Symmetry: "+newAxis+", symmetry point: "+str(creatorTool.symmPoint))
	#creatorTool.symmPoint = newSymmPoint

func process(_delta:float, _pc:PlayerEditor):
	var _node:Node3D = getPC().getRaycastNode()
	var _id:int = getPC().getRaycastPropID()
	#print(_node)
	if(_id >= 0 && _node != null):
		var aabb:=PlayerEditor.calculateSpatialBounds(_node, true)
		drawBoxAABB(aabb, _node.global_transform, Color.GREEN)

	var creatorTool = getTool("1Creator")
	if(creatorTool != null):
		var symmAxis:String = creatorTool.symmAxis
		var symmPoint:Vector3 = creatorTool.symmPoint
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

func getText() -> String:
	var resultText:String = ""
	resultText += "Right click - set symmetry axis\n"
	resultText += "Left click - symmetrize prop\n"
	
	return resultText

#func onKeyPressed(_physicalCode:int, _event:InputEventKey):
	#if(_physicalCode == KEY_R && !_event.ctrl_pressed):# && isShifting):
		#showMessage("Cleared settings buffer", 1.0)
