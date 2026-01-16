extends VarUIBase

#@onready var tex_selector_button: OptionButton = %TexSelectorButton
@onready var color_rect_r: ColorPickerButton = %ColorRectR
@onready var color_rect_g: ColorPickerButton = %ColorRectG
@onready var color_rect_b: ColorPickerButton = %ColorRectB
@onready var select_texture_var_button: Button = %SelectTextureVarButton
@onready var select_texture_icon: TextureRect = %SelectTextureIcon

signal onUpButtonPressed
signal onDownButtonPressed
signal onDeleteButtonPressed

var selectedID:String = ""
var colorR:Color = Color.RED
var colorG:Color = Color.GREEN
var colorB:Color = Color.BLUE

var texType:String = ""
var texSubType:String = ""

var allIDs:Array = []

func setData(_data:Dictionary):
	#if(_data.has("name")):
	#	$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("texType")):
		texType = _data["texType"]
	if(_data.has("texSubType")):
		texSubType = _data["texSubType"]
	if(_data.has("value")):
		var theData:Dictionary = _data["value"]
		selectedID = theData["id"]
		if(theData.has("r")):
			colorR = theData["r"]
		elif(theData.has("colorR")):
			colorR = theData["colorR"]
		if(theData.has("g")):
			colorG = theData["g"]
		elif(theData.has("colorG")):
			colorG = theData["colorG"]
		if(theData.has("b")):
			colorB = theData["b"]
		elif(theData.has("colorB")):
			colorB = theData["colorB"]
	
	updateTexSelector()
	updateColors()

func updateColors():
	var texVariant:TextureVariant = GlobalRegistry.getTextureVariant(selectedID)
	if(texVariant == null):
		color_rect_r.visible = false
		color_rect_g.visible = false
		color_rect_b.visible = false
		return
	
	var hasR:bool = texVariant.getFlag("hasR", true)
	var hasG:bool = texVariant.getFlag("hasG", false)
	var hasB:bool = texVariant.getFlag("hasB", false)
	
	color_rect_r.visible = hasR
	color_rect_r.color = colorR
	color_rect_g.visible = hasG
	color_rect_g.color = colorG
	color_rect_b.visible = hasB
	color_rect_b.color = colorB

func getFinalData() -> Dictionary:
	return {
		id = selectedID,
		r = colorR,
		g = colorG,
		b = colorB,
	}

func updateTexSelector():
	#tex_selector_button.clear()
	
	allIDs = GlobalRegistry.getTextureVariantsIDsOfTypeAndSubType(texType, texSubType)
	if(!allIDs.has(selectedID)):
		allIDs.append(selectedID)
	
	if(selectedID == ""):
		select_texture_var_button.text = "- Empty -"
	else:
		var theSelectedTexVariant:TextureVariant = GlobalRegistry.getTextureVariant(selectedID)
		if(!theSelectedTexVariant):
			select_texture_var_button.text = "- Missing -"
		else:
			select_texture_var_button.text = theSelectedTexVariant.getName()
			select_texture_icon.texture = load(theSelectedTexVariant.previewPath) if theSelectedTexVariant.previewPath != "" else null
			if(select_texture_icon.texture):
				select_texture_var_button.custom_minimum_size.y = 32.0
			else:
				select_texture_var_button.custom_minimum_size.y = 0.0
			
	#var _i:int = 0
	#
	#for theID in allIDs:
		#var texVariant:TextureVariant = GlobalRegistry.getTextureVariant(theID)
		#if(texVariant == null):
			#tex_selector_button.add_item(theID)
			#
			#if(theID == selectedID):
				#tex_selector_button.select(_i)
			#_i += 1
			#continue
		#
		#tex_selector_button.add_item(texVariant.getName())
			#
		#if(theID == selectedID):
			#tex_selector_button.select(_i)
		#_i += 1
		#continue

func _on_up_button_pressed() -> void:
	onUpButtonPressed.emit()

func _on_down_button_pressed() -> void:
	onDownButtonPressed.emit()

func _on_delete_button_pressed() -> void:
	onDeleteButtonPressed.emit()

func _on_tex_selector_button_item_selected(index: int) -> void:
	if(index < 0 || index >= allIDs.size()):
		return
	
	selectedID = allIDs[index]
	updateColors()
	
	triggerChange(getFinalData())

var isChanging:bool = false

func _on_color_rect_r_color_changed(_color: Color) -> void:
	if(isChanging):
		return
	isChanging = true
	await get_tree().create_timer(0.1).timeout
	colorR = color_rect_r.color
	triggerChange(getFinalData())
	isChanging = false

func _on_color_rect_g_color_changed(_color: Color) -> void:
	if(isChanging):
		return
	isChanging = true
	await get_tree().create_timer(0.1).timeout
	colorG = color_rect_g.color
	triggerChange(getFinalData())
	isChanging = false

func _on_color_rect_b_color_changed(_color: Color) -> void:
	if(isChanging):
		return
	isChanging = true
	await get_tree().create_timer(0.1).timeout
	colorB = color_rect_b.color
	triggerChange(getFinalData())
	isChanging = false

var texVarSelWindow
func _on_select_texture_var_button_pressed() -> void:
	if(texVarSelWindow):
		texVarSelWindow.queue_free()
		texVarSelWindow = null
	
	texVarSelWindow = preload("res://UI/VarList/Util/texture_variant_selector_window.tscn").instantiate()
	add_child(texVarSelWindow)
	texVarSelWindow.popup_centered()
	
	texVarSelWindow.setData({
		value = selectedID,
		values = allIDs,
	})
	texVarSelWindow.onClose.connect(onTexVarSelWindowClose)
	texVarSelWindow.onApply.connect(onTexVarSelWindowApply)

func onTexVarSelWindowClose(_window):
	if(texVarSelWindow):
		texVarSelWindow.queue_free()
		texVarSelWindow = null

func onTexVarSelWindowApply(_window, _id:String):
	if(texVarSelWindow):
		texVarSelWindow.queue_free()
		texVarSelWindow = null
	selectedID = _id
	updateTexSelector()
	updateColors()
	triggerChange(getFinalData())

func getValue():
	return getFinalData()
