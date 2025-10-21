extends VBoxContainer

@onready var pers_entry_list: VBoxContainer = %PersEntryList

const PERSONALITY_EDIT_UI_ENTRY = preload("res://Game/CharacterCreator/PersonalityEditUI/personality_edit_ui_entry.tscn")

var statToEntry:Dictionary[String, Control] = {}
var personality:Personality = Personality.new()

func _ready() -> void:
	if(!GlobalRegistry.finishedInit):
		await GlobalRegistry.initialized
	Util.delete_children(pers_entry_list)
	for persStat in GlobalRegistry.getPersonalityStatIDsSorted():
		var newEntry:Control = PERSONALITY_EDIT_UI_ENTRY.instantiate()
		pers_entry_list.add_child(newEntry)
		newEntry.setStatID(persStat)
		newEntry.onValueChange.connect(onEntryStatValueChange)
		statToEntry[persStat] = newEntry
	updateEntries()

func onEntryStatValueChange(statID:String, value:float):
	personality.setStat(statID, value)

func setPersonality(_pers:Personality):
	personality = _pers
	updateEntries()

func updateEntries():
	for persStat in statToEntry:
		var theEntry:Control = statToEntry[persStat]
		theEntry.setValue(personality.getStat(persStat) if personality else 0.0)
