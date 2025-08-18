extends GameModeBase

func _init() -> void:
	id = GameMode.CharacterCreator

func start():
	var thePC:BaseCharacter = GM.characterRegistry.createCharacter()
	var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(thePC.getID())
	var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	myInfo.charID = thePC.getID()
