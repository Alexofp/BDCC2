extends VBoxContainer
class_name SexParticipantUIEntry

var charID:String = ""

@onready var name_label: Label = %NameLabel
@onready var arousal_bar: ProgressBar = %ArousalBar

func setCharID(_charID:String):
	charID = _charID

func _process(_delta: float) -> void:
	var character:BaseCharacter = GM.characterRegistry.getCharacter(charID)
	if(!character):
		return
	name_label.text = character.getName()
	arousal_bar.set_value_no_signal(character.getArousal())
