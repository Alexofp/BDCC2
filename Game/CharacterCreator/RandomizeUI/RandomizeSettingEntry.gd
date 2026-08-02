extends HBoxContainer

@onready var label: Label = %Label
@onready var option_button: OptionButton = %OptionButton

var id:String
var entry:Dictionary
var value

signal onSettingChange(_id:String, _value)

func setEntry(_id:String, _entry:Dictionary):
	id = _id
	entry = _entry
	
	updateEntry()
	
func updateEntry():
	if(entry.is_empty()):
		return
	option_button.clear()
	label.text = entry.get("name", "???")
	var theValues:Array = entry.get("values", [])
	var theCurrentValue = entry["value"]
	var _i:int = 0
	for theValueNamePair in theValues:
		option_button.add_item(theValueNamePair[1])
		if(theValueNamePair[0] == theCurrentValue):
			option_button.select(_i)
		_i += 1

func _on_option_button_item_selected(index: int) -> void:
	var theValues:Array = entry.get("values", [])
	if(index < 0 || index >= theValues.size()):
		return
	onSettingChange.emit(id, theValues[index][0])
