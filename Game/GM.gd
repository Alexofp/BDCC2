extends Object
class_name GM

static var main:MainScene
static var game:GameModeBase: get = getGameMode
static var pcDoll:DollController: get = getPCDoll
static var pcPawn:CharacterPawn: get = getPCPawn
static var cachedPcDoll:DollController

static var pc:BaseCharacter: get = getPC
static var characterRegistry:CharacterRegistry: get = getCharacterRegistry
static var pawnRegistry:PawnRegistry: get = getPawnRegistry
static var dollHolder:DollHolder: get = getDollHolder
static var sitManager:SitManager: get = getSitManager
static var sexManager:SexManager: get = getSexManager
static var IS:InteractionSystem: get = getInteractionSystem
static var presets:CharacterPresetHolder

static func getPC() -> BaseCharacter:
	var myNetworkPlayer:NetworkPlayerInfo = Network.getMyPlayerInfo()
	if(!myNetworkPlayer):
		return null
	var theCharID:String = myNetworkPlayer.charID
	if(theCharID == ""):
		return null
	if(!characterRegistry):
		return null
	return characterRegistry.getCharacter(theCharID)

static func getPCDoll() -> DollController:
	var thePC:BaseCharacter = pc
	if(!thePC):
		return null
	if(!pawnRegistry):
		return null
	var pawn:CharacterPawn = pawnRegistry.getPawn(thePC.getID())
	return pawn.getDoll()
#
static func getPCPawn() -> CharacterPawn:
	var thePC:BaseCharacter = pc
	if(!thePC):
		return null
	if(!pawnRegistry):
		return null
	var pawn:CharacterPawn = pawnRegistry.getPawn(thePC.getID())
	return pawn
#
#static func handlePlayerCharIDChanged(_charID:String):
	#updateCurrentDoll(pcDoll)
#
#static func updateCurrentDoll(newPcDoll:DollController):
	#if(cachedPcDoll):
		#cachedPcDoll.onLoseControl()
	##pcDoll = newPcDoll
	#cachedPcDoll = newPcDoll
	#if(newPcDoll):
		#newPcDoll.onGainControl()

static func getCharacterRegistry() -> CharacterRegistry:
	if(main != null):
		return main.getCharacterRegistry()
	return null

static func getPawnRegistry() -> PawnRegistry:
	if(main != null):
		return main.getPawnRegistry()
	return null

static func getDollHolder() -> DollHolder:
	if(main != null):
		return main.getDollHolder()
	return null

static func getSitManager() -> SitManager:
	if(main != null):
		return main.sit_manager
	return null

static func getSexManager() -> SexManager:
	if(main != null):
		return main.getSexManager()
	return null

static func getInteractionSystem() -> InteractionSystem:
	if(main != null):
		return main.interactionSystem
	return null

static func getGameMode() -> GameModeBase:
	if(main):
		return main.getGame	
	return null

static func sendChat(_text:String):
	GameInteractor.askChatSend(_text)

static var changingScene:bool = false

static func startGame(_map:String, _mode:int, _args:Array = []):
	assert(!changingScene, "Already changing a scene!")
	LoadingScreen.startLoad()
	changingScene = true
	GameInteractor.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GameInteractor.get_tree().scene_changed
	await GameInteractor.get_tree().current_scene.loadModeOnMap(_map, _mode, _args)
	changingScene = false
	LoadingScreen.finishLoad()

static func startMainMenu():
	assert(!changingScene, "Already changing a scene!")
	changingScene = true
	GameInteractor.get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn")
	await GameInteractor.get_tree().scene_changed
	changingScene = false

static func isChangingScene() -> bool:
	return changingScene
