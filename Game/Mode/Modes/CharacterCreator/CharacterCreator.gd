extends GameModeBase

@onready var helpful_label: Label = %HelpfulLabel
@onready var hide_label_timer: Timer = %HideLabelTimer
var showedLabel:bool = false

func _init() -> void:
	id = GameMode.CharacterCreator

func start():
	Log.Print("GameMode.CharacterCreator START()")
	if(Network.isServer()):
		var thePC:BaseCharacter = GM.characterRegistry.createCharacter()
		var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(thePC.getID())
		var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
		myInfo.charID = thePC.getID()
	
	showCharacterCreator()

func onCharacterCreatorConfirm():
	if(!showedLabel):
		helpful_label.visible = true
		hide_label_timer.start(5.0)
		showedLabel = true
	
func _on_hide_label_timer_timeout() -> void:
	helpful_label.visible = false
