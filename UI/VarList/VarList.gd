extends VBoxContainer
class_name VarList

signal onVarChange(id, value)

var widgets:Array = []

func setVars(_vars:Dictionary):
	delete_children(self)
	widgets.clear()
	
	for dataID in _vars:
		var varLine:Dictionary = _vars[dataID]
		
		var theType:String = varLine["type"]
		
		var newWidget:VarUIBase
		
		if(theType == "int"):
			newWidget = preload("res://UI/VarList/Vars/int_var.tscn").instantiate()
		elif(theType == "float"):
			newWidget = preload("res://UI/VarList/Vars/float_var.tscn").instantiate()
		elif(theType == "bool"):
			newWidget = preload("res://UI/VarList/Vars/bool_var.tscn").instantiate()
		elif(theType == "string"):
			newWidget = preload("res://UI/VarList/Vars/string_var.tscn").instantiate()
		elif(theType == "floatPresets"):
			newWidget = preload("res://UI/VarList/Vars/float_preset_var.tscn").instantiate()
		elif(theType == "vec3"):
			newWidget = preload("res://UI/VarList/Vars/vec3_var.tscn").instantiate()
		elif(theType == "color"):
			newWidget = preload("res://UI/VarList/Vars/color_var.tscn").instantiate()
		elif(theType == "colorPalette"):
			newWidget = preload("res://UI/VarList/Vars/color_palette_var.tscn").instantiate()
		elif(theType in "selector"):
			newWidget = preload("res://UI/VarList/Vars/dropdown_var.tscn").instantiate()
		
		if(newWidget == null):
			printerr("Uknown property type found: "+theType)
			continue
		
		add_child(newWidget)
		newWidget.id = dataID
		newWidget.onValueChange.connect(onWidgetValueChange)
		newWidget.setData(varLine)

func onWidgetValueChange(id, value):
	onVarChange.emit(id, value)

func checkWidgetsFinished():
	for widget in widgets:
		widget.onEditorClose()
	return true

static func delete_children(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
