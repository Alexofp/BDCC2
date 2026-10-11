extends GameModeBase

func _init() -> void:
	id = GameMode.Sandbox

func start():
	if(Network.isServer()):
		#var thePC:BaseCharacter = GM.characterRegistry.createCharacter()
		#thePC.resetToDefaultPCCharacter()
		#var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(thePC.getID())
		#var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
		#myInfo.charID = thePC.getID()
		
		#var char2:BaseCharacter = GM.characterRegistry.createCharacter()
		#char2.resetToDefaultPCCharacter()
		#var _thePawn2:CharacterPawn = GM.pawnRegistry.createPawn(char2.getID())
		#_thePawn2.position.x = 2.0
		pass
