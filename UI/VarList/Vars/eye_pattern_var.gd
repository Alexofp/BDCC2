extends VarUIBase

@onready var two_colors_check_box: CheckBox = %TwoColorsCheckBox
@onready var pattern_left_eye: VBoxContainer = %PatternLeftEye
@onready var pattern_right_eye: VBoxContainer = %PatternRightEye

var texType:String = ""
var texSubType:String = ""

var data:Dictionary = {
	id = "",
	r = Color.WHITE,
	g = Color.WHITE,
	b = Color.WHITE,
}

var alpha:bool = false

func setData(_data:Dictionary):
	#if(_data.has("name")):
	#	theName = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("alpha")):
		alpha = _data["alpha"]
	if(_data.has("texType")):
		texType = _data["texType"]
	if(_data.has("texSubType")):
		texSubType = _data["texSubType"]
	if(_data.has("value")):
		data = _data["value"].duplicate()
		if(!data.has("id")):
			data["id"] = ""
		if(!data.has("r")):
			data["r"] = Color.WHITE
		if(!data.has("g")):
			data["g"] = Color.WHITE
		if(!data.has("b")):
			data["b"] = Color.WHITE
	updatePatternVars()
	two_colors_check_box.set_pressed_no_signal(isTwoColors())

func _on_two_colors_check_box_toggled(_toggled_on: bool) -> void:
	if(!_toggled_on):
		data.erase("id2")
		data.erase("r2")
		data.erase("g2")
		data.erase("b2")
	else:
		data["id2"] = data["id"]
		data["r2"] = data["r"]
		data["g2"] = data["g"]
		data["b2"] = data["b"]
	
	updatePatternVars()
	triggerChange(data.duplicate(true))

func isTwoColors() -> bool:
	return data.has("id2")

func updatePatternVars():
	pattern_left_eye.setData({
		name = "Left eye" if isTwoColors() else "Eyes",
		value = {
			id = data["id"],
			r = data["r"],
			g = data["g"],
			b = data["b"],
		},
		texType = texType,
		texSubType = texSubType,
		alpha = alpha,
	})
	if(isTwoColors()):
		pattern_right_eye.visible = true
		pattern_right_eye.setData({
			name = "Right eye",
			value = {
				id = data["id2"],
				r = data["r2"],
				g = data["g2"],
				b = data["b2"],
			},
			texType = texType,
			texSubType = texSubType,
			alpha = alpha,
		})
	else:
		pattern_right_eye.visible = false

func _on_pattern_left_eye_on_value_change(_id: Variant, _newValue: Dictionary) -> void:
	data["id"] = _newValue["id"]
	data["r"] = _newValue["r"]
	data["g"] = _newValue["g"]
	data["b"] = _newValue["b"]
	triggerChange(data.duplicate(true))

func _on_pattern_right_eye_on_value_change(_id: Variant, _newValue: Dictionary) -> void:
	data["id2"] = _newValue["id"]
	data["r2"] = _newValue["r"]
	data["g2"] = _newValue["g"]
	data["b2"] = _newValue["b"]
	triggerChange(data.duplicate(true))
