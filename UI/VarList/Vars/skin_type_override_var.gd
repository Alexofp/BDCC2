extends VarUIBase

@onready var check_box: CheckBox = $HBoxContainer/CheckBox
var skinTypeData:SkinTypeData = null

@onready var override_data_list: VBoxContainer = %OverrideDataList
@onready var custom_color_picker: ColorPickerButton = %CustomColorPicker

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		setValueRaw(_data["value"])
	updateUIStuff()

func setValueRaw(_value):
	if(_value is Dictionary):
		var _newVal:SkinTypeData = SkinTypeData.new()
		_newVal.loadData(_value)
		_value = _newVal
	
	if(!_value):
		skinTypeData = null
	else:
		skinTypeData = SkinTypeData.new()
		skinTypeData.loadData(_value.saveData().duplicate(true))

func updateUIStuff():
	if(!skinTypeData):
		check_box.set_pressed_no_signal(true)
		override_data_list.visible = false
	else:
		check_box.set_pressed_no_signal(false)
		override_data_list.visible = true
		custom_color_picker.color = skinTypeData.color

func _on_check_box_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		skinTypeData = null
	else:
		skinTypeData = SkinTypeData.new()
	updateUIStuff()
	
	triggerChange(skinTypeData.saveData().duplicate(true) if skinTypeData else {})

func _on_label_button_pressed() -> void:
	if(check_box.disabled):
		return
	check_box.button_pressed = !check_box.button_pressed

func _on_custom_color_picker_color_changed(newColor: Color) -> void:
	if(!skinTypeData):
		return
	skinTypeData.color = newColor
	triggerChange(skinTypeData.saveData().duplicate(true) if skinTypeData else {})
