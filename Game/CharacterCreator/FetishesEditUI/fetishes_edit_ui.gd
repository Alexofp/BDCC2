extends VBoxContainer

@onready var fetish_list: VBoxContainer = %FetishList

const FETISH_EDIT_UI_ENTRY = preload("res://Game/CharacterCreator/FetishesEditUI/fetish_edit_ui_entry.tscn")

var fetishes:FetishHolder = FetishHolder.new()
var perfToEntry:Dictionary[String, Control] = {}
var receiveToEntry:Dictionary[String, Control] = {}

func _ready() -> void:
	if(!GlobalRegistry.finishedInit):
		await GlobalRegistry.initialized
	Util.delete_children(fetish_list)
	for fetishID in GlobalRegistry.getFetishes():
		if(true):
			var newLabel:Label = Label.new()
			fetish_list.add_child(newLabel)
			newLabel.text = GlobalRegistry.getFetish(fetishID).getVisibleName()
		if(true):
			var newEntry:Control = FETISH_EDIT_UI_ENTRY.instantiate()
			fetish_list.add_child(newEntry)
			newEntry.setFetishID(fetishID, true)
			newEntry.onValueChange.connect(onPerfFetishValueChange)
			perfToEntry[fetishID] = newEntry
		if(true):
			var newEntry:Control = FETISH_EDIT_UI_ENTRY.instantiate()
			fetish_list.add_child(newEntry)
			newEntry.setFetishID(fetishID, false)
			newEntry.onValueChange.connect(onReceiveFetishValueChange)
			receiveToEntry[fetishID] = newEntry
		if(true):
			var newSep:HSeparator = HSeparator.new()
			fetish_list.add_child(newSep)
	updateEntries()

func updateEntries():
	if(!fetishes):
		return
	for fetishID in GlobalRegistry.getFetishes():
		perfToEntry[fetishID].setValue(fetishes.getPerforming(fetishID))
		receiveToEntry[fetishID].setValue(fetishes.getReceiving(fetishID))

func setFetishHolder(_holder:FetishHolder):
	fetishes = _holder
	updateEntries()

func onPerfFetishValueChange(_fetishID:String, _value:float):
	fetishes.setPerforming(_fetishID, _value)
	
func onReceiveFetishValueChange(_fetishID:String, _value:float):
	fetishes.setReceiving(_fetishID, _value)
