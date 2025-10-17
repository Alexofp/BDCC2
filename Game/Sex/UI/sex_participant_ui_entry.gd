extends VBoxContainer
class_name SexParticipantUIEntry

var info:SexParticipantInfo

@onready var name_label: Label = %NameLabel
@onready var arousal_bar: ProgressBar = %ArousalBar
@onready var status_label: RichTextLabel = %StatusLabel

func setInfo(_info:SexParticipantInfo):
	info = _info

func _process(_delta: float) -> void:
	if(!info):
		return
	var character:BaseCharacter = GM.characterRegistry.getCharacter(info.getID())
	if(!character):
		return
	name_label.text = character.getName()
	arousal_bar.set_value_no_signal(character.getArousal())
	
	var theStatusTexts := info.getStatusTextArray()
	if(theStatusTexts.is_empty()):
		status_label.visible = false
	else:
		status_label.visible = true
		status_label.text = Util.join(theStatusTexts, "\n")

func _on_debug_switch_button_pressed() -> void:
	if(!info):
		return
	GM.game.askSwitchToCharID(info.getID())
