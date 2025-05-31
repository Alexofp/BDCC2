extends VarUIBase

var messProfile:FluidsOnBodyProfile = FluidsOnBodyProfile.new()
@onready var mess_entries_list: VBoxContainer = %MessEntriesList

var sliderVarScene := preload("res://UI/VarList/Vars/slider_var.tscn")
var sliders:Dictionary = {}

func _ready() -> void:
	Util.delete_children(mess_entries_list)
	
	for messZone in FluidsOnBodyZone.getAll():
		var newSlider := sliderVarScene.instantiate()
		mess_entries_list.add_child(newSlider)
		newSlider.setData({
			name = FluidsOnBodyZone.getName(messZone),
			min = 0.0,
			max = 1.0,
			value = messProfile.getMess(messZone),
		})
		sliders[messZone] = newSlider
		newSlider.onValueChange.connect(onSliderValueChange.bind(messZone))

func onSliderValueChange(_id, _val:float, _messZone:int):
	messProfile.setMess(_messZone, _val)
	triggerChange(messProfile.saveData().duplicate(true))

func updateSliders():
	for messZone in FluidsOnBodyZone.getAll():
		sliders[messZone].setData({
			value = messProfile.getMess(messZone),
		})

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		messProfile.loadData(_data["value"].duplicate(true))
	updateSliders()
	
