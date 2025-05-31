extends VarUIBase

var faceOverrideProfile:FaceAnimatorOverrideProfile = FaceAnimatorOverrideProfile.new()
@onready var override_list: VBoxContainer = %OverrideList

var sliderVarScene := preload("res://UI/VarList/Vars/slider_var.tscn")

#func _ready() -> void:
#	updateValue()

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
		$HBoxContainer/Label.visible = _data["name"] != ""
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		faceOverrideProfile.loadData(_data["value"].duplicate(true))
	updateValue()

func updateValue():
	Util.delete_children(override_list)
	
	for faceField in FaceValue.getAll():
		var faceFieldName:String = FaceValue.getName(faceField)
		var faceFieldType:int = FaceValue.getType(faceField)
		
		var theCheckbox:CheckBox = CheckBox.new()
		override_list.add_child(theCheckbox)
		theCheckbox.text = faceFieldName
		theCheckbox.set_pressed_no_signal(faceOverrideProfile.isFaceValueOverridden(faceField))
		theCheckbox.toggled.connect(onOverrideToggled.bind(faceField))
		
		if(faceFieldType == FaceValue.FACE_VALUE_FLOAT):
			var newSlider := sliderVarScene.instantiate()
			override_list.add_child(newSlider)
			newSlider.setData({
				name = "",
				value = faceOverrideProfile.getFaceValueOverride(faceField, 0.0),
				min = 0.0,
				max = 1.0,
			})
			newSlider.onValueChange.connect(onOverrideFloatValueChange.bind(faceField))
		elif(faceFieldType == FaceValue.FACE_VALUE_VEC2):
			if(true):
				var newSlider := sliderVarScene.instantiate()
				override_list.add_child(newSlider)
				newSlider.setData({
					name = "X",
					value = faceOverrideProfile.getFaceValueOverride(faceField, Vector2(0.0, 0.0)).x,
					min = -1.0,
					max = 1.0,
				})
				newSlider.onValueChange.connect(onOverrideVec2XValueChange.bind(faceField))
			if(true):
				var newSlider := sliderVarScene.instantiate()
				override_list.add_child(newSlider)
				newSlider.setData({
					name = "Y",
					value = faceOverrideProfile.getFaceValueOverride(faceField, Vector2(0.0, 0.0)).y,
					min = -1.0,
					max = 1.0,
				})
				newSlider.onValueChange.connect(onOverrideVec2YValueChange.bind(faceField))

func onOverrideToggled(_tog:bool, _faceID:int):
	if(_tog):
		faceOverrideProfile.addOverride(_faceID)
	else:
		faceOverrideProfile.removeOverride(_faceID)
	triggerChange(faceOverrideProfile.saveData().duplicate(true))

func onOverrideFloatValueChange(_id:String, _val:float, _faceID:int):
	faceOverrideProfile.setValue(_faceID, _val)
	
	triggerChange(faceOverrideProfile.saveData().duplicate(true))
	
func onOverrideVec2XValueChange(_id:String, _val:float, _faceID:int):
	var theVal:Vector2 = faceOverrideProfile.getFaceValueOverride(_faceID, Vector2(0.0, 0.0))
	theVal.x = _val
	faceOverrideProfile.setValue(_faceID, theVal)
	
	triggerChange(faceOverrideProfile.saveData().duplicate(true))
	
func onOverrideVec2YValueChange(_id:String, _val:float, _faceID:int):
	var theVal:Vector2 = faceOverrideProfile.getFaceValueOverride(_faceID, Vector2(0.0, 0.0))
	theVal.y = _val
	faceOverrideProfile.setValue(_faceID, theVal)
	
	triggerChange(faceOverrideProfile.saveData().duplicate(true))

func _on_line_edit_text_changed(new_text: String) -> void:
	triggerChange(new_text)
