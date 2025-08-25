extends VBoxContainer
class_name VarList

signal onVarChange(id, value)

@export var addSeparators:bool = false
var widgets:Array = []

func setVars(_vars:Dictionary):
	delete_children(self)
	widgets.clear()
	
	for dataID in _vars:
		var varLine:Dictionary = _vars[dataID]
		
		var theType:String = varLine["type"]
		
		var newWidget:VarUIBase
		
		match theType:
			"int":
				newWidget = preload("res://UI/VarList/Vars/int_var.tscn").instantiate()
			"float":
				newWidget = preload("res://UI/VarList/Vars/float_var.tscn").instantiate()
			"bool":
				newWidget = preload("res://UI/VarList/Vars/bool_var.tscn").instantiate()
			"string":
				newWidget = preload("res://UI/VarList/Vars/string_var.tscn").instantiate()
			"floatPresets":
				newWidget = preload("res://UI/VarList/Vars/float_preset_var.tscn").instantiate()
			"vec3":
				newWidget = preload("res://UI/VarList/Vars/vec3_var.tscn").instantiate()
			"color":
				newWidget = preload("res://UI/VarList/Vars/color_var.tscn").instantiate()
			"colorPalette":
				newWidget = preload("res://UI/VarList/Vars/color_palette_var.tscn").instantiate()
			"selector":
				newWidget = preload("res://UI/VarList/Vars/dropdown_var.tscn").instantiate()
			"slider":
				newWidget = preload("res://UI/VarList/Vars/slider_var.tscn").instantiate()
			"texVarLayerList":
				newWidget = preload("res://UI/VarList/Vars/texture_variant_layers_var.tscn").instantiate()
			"pattern":
				newWidget = preload("res://UI/VarList/Vars/pattern_var.tscn").instantiate()
			"stringWindow":
				newWidget = preload("res://UI/VarList/Vars/string_window_var.tscn").instantiate()
			"genderProfile":
				newWidget = preload("res://UI/VarList/Vars/gender_profile_var.tscn").instantiate()
			"speciesProfile":
				newWidget = preload("res://UI/VarList/Vars/species_var.tscn").instantiate()
			"sexVoice":
				newWidget = preload("res://UI/VarList/Vars/sex_voice_var.tscn").instantiate()
			"faceOverride":
				newWidget = preload("res://UI/VarList/Vars/face_override_var.tscn").instantiate()
			"bodyMess":
				newWidget = preload("res://UI/VarList/Vars/body_mess_var.tscn").instantiate()
			"skinDataOverride":
				newWidget = preload("res://UI/VarList/Vars/skin_type_override_var.tscn").instantiate()
			"extraColored":
				newWidget = preload("res://UI/VarList/Vars/extra_colored_var.tscn").instantiate()
			"eyePattern":
				newWidget = preload("res://UI/VarList/Vars/eye_pattern_var.tscn").instantiate()
			
		if(newWidget == null):
			printerr("Uknown property type found: "+theType)
			continue
		
		add_child(newWidget)
		newWidget.id = dataID
		newWidget.onValueChange.connect(onWidgetValueChange)
		newWidget.setData(varLine)
		
		if((varLine.has("addSeparator") && varLine["addSeparator"]) || (addSeparators && (!varLine.has("noSeparator") || !varLine["noSeparator"]))):
			var newSep:HSeparator = HSeparator.new()
			add_child(newSep)

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
