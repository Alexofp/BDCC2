extends Object
class_name GM

static var game:GameBase
static var pcDoll:DollController: get = getPCDoll
static var cachedPcDoll:DollController

static var pc:BaseCharacter: get = getPC
static var characterRegistry:CharacterRegistry: get = getCharacterRegistry
static var pawnRegistry:PawnRegistry: get = getPawnRegistry
static var dollHolder:DollHolder: get = getDollHolder
static var sitManager:SitManager: get = getSitManager
static var sexManager:SexManager: get = getSexManager
static var IS:InteractionSystem: get = getInteractionSystem

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
	if(game != null):
		return game.getCharacterRegistry()
	return null

static func getPawnRegistry() -> PawnRegistry:
	if(game != null):
		return game.getPawnRegistry()
	return null

static func getDollHolder() -> DollHolder:
	if(game != null):
		return game.getDollHolder()
	return null

static func getSitManager() -> SitManager:
	if(game != null):
		return game.sit_manager
	return null

static func getSexManager() -> SexManager:
	if(game != null):
		return game.getSexManager()
	return null

static func getInteractionSystem() -> InteractionSystem:
	if(game != null):
		return game.interactionSystem
	return null
