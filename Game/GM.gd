extends Object
class_name GM

static var main:MainScene
static var game:GameModeBase: get = getGameMode
static var pcDoll:DollController: get = getPCDoll
static var pcPawn:CharacterPawn: get = getPCPawn
static var cachedPcDoll:DollController

static var pc:BaseCharacter: get = getPC
static var characterRegistry:CharacterRegistry: get = getCharacterRegistry
static var inventoryRegistry:InventoryRegistry: get = getInventoryRegistry
static var pawnRegistry:PawnRegistry: get = getPawnRegistry
static var dollHolder:DollHolder: get = getDollHolder
static var sitManager:SitManager: get = getSitManager
static var sexManager:SexManager: get = getSexManager
static var leashSystem:LeashSystem: get = getLeashSystem
static var IS:InteractionSystem: get = getInteractionSystem
static var netNodes:NetworkedNodes: get = getNetworkedNodes
static var actionSystem:ActionSystem: get = getActionSystem
static var presets:CharacterPresetHolder
static var textParser:SimpleGameTextParser = SimpleGameTextParser.new()
static var world:World: get = getWorld
static var GB:GameBalance: get = getGameBalance

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

static func getInventoryRegistry() -> InventoryRegistry:
	if(main != null):
		return main.getInventoryRegistry()
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

static func getLeashSystem() -> LeashSystem:
	if(main != null):
		return main.getLeashSystem()
	return null

static func getActionSystem() -> ActionSystem:
	if(main != null):
		return main.getActionSystem()
	return null

static func getInteractionSystem() -> InteractionSystem:
	if(main != null):
		return main.interactionSystem
	return null

static func getNetworkedNodes() -> NetworkedNodes:
	return GI.networkedNodes

static func getGameMode() -> GameModeBase:
	if(main):
		return main.getGameMode()
	return null

static func sendChat(_text:String):
	GI.askChatSend(_text)

static var changingScene:bool = false

static func startGame(_map:String, _mode:int, _args:Array = []):
	assert(!changingScene, "Already changing a scene!")
	LoadingScreen.startLoad()
	changingScene = true
	GI.get_tree().paused = true
	GI.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GI.get_tree().scene_changed
	await GI.get_tree().current_scene.loadModeOnMap(_map, _mode, _args)
	GM.main.startGame()
	GI.get_tree().paused = false
	changingScene = false
	LoadingScreen.finishLoad()

static func startMainMenu():
	assert(!changingScene, "Already changing a scene!")
	changingScene = true
	#TODO: STOP NETWORK
	Network.stopMultiplayer()
	GI.get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn")
	await GI.get_tree().scene_changed
	changingScene = false

static func isChangingScene() -> bool:
	return changingScene

static func internal_hostGame(_connector:ConnectorNetworkBase, _nickname:String, _map:String, _mode:int, _args:Array = []):
	assert(!changingScene, "Already changing a scene!")
	LoadingScreen.startLoad()
	changingScene = true
	GI.get_tree().paused = true
	GI.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GI.get_tree().scene_changed
	await GI.get_tree().current_scene.loadModeOnMap(_map, _mode, _args)
	LoadingScreen.setText("Hosting..")
	
	Network.setMyNickname(_nickname)
	
	var res = await Network.host(_connector)#hostFunc.call(_nickname) #Network.hostLAN(_nickname)
	if(res.isError()):
		errorOutToMainMenu(res.result if res.result is String else "Unable to start hosting")
		return
	GM.main.startGame()
	#await GI.get_tree().create_timer(2.0).timeout
	GI.get_tree().paused = false
	changingScene = false
	LoadingScreen.finishLoad()

static func hostLANGame(_nickname:String, _map:String, _mode:int, _args:Array = []):
	var theConnector := LANNetworkConnector.new()
	#theConnector.setHostPort(relayServer, relayServerPort)
	
	await internal_hostGame(theConnector, _nickname, _map, _mode, _args)
	pass

static func hostNoray(_nickname:String, _map:String, _mode:int, _args:Array = [], relayServer:String = Network.NORAY_SERVER, relayServerPort:int = Network.NORAY_PORT):
	var theConnector := NorayNetworkConnector.new()
	theConnector.setRelay(relayServer, relayServerPort)
	
	await internal_hostGame(theConnector, _nickname, _map, _mode, _args)

static func internal_joinGame(_connector:ConnectorNetworkBase, _nickname:String):
	#Network.joinGame(_nickname, _ip)
	LoadingScreen.startLoad()
	GI.get_tree().paused = true
	LoadingScreen.setText("Connecting..")
	var res = await Network.join(_connector)#await joinFunc.call()#Network.connectLAN(_ip)
	if(res.error):
		errorOutToMainMenu(res.result if res.result is String else "Unable to connect")
		return
	LoadingScreen.setText("Getting game info..")
	res = await Network.clientAskGameInfo()
	if(res.error):
		errorOutToMainMenu(res.result if res.result is String else "Failed to get game info")
		return
	var mapToLoad:String = res.result["map"]
	var modeToLoad:int = res.result["mode"]
	var modeArgs:Array = []
	LoadingScreen.setText("Loading map..")
	GI.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GI.get_tree().scene_changed
	await GI.get_tree().current_scene.loadModeOnMap(mapToLoad, modeToLoad, modeArgs)
	LoadingScreen.setText("Loading game state..")
	res = await Network.clientAskToJoin(_nickname)
	if(res.error):
		errorOutToMainMenu(res.result if res.result is String else "Failed to load game state")
		return
	GM.main.startGame()
	GI.get_tree().paused = false
	LoadingScreen.finishLoad()

static func joinLANGame(_nickname:String, _ip:String):
	var theConnector := LANNetworkConnector.new()
	theConnector.setJoinIPAndPortFromString(_ip)
	
	await internal_joinGame(theConnector, _nickname)

static func joinNorayGame(_nickname:String, _roomID:String, relayServer:String = Network.NORAY_SERVER, relayServerPort:int = Network.NORAY_PORT, forceRelay:bool = false):
	var theConnector := NorayNetworkConnector.new()
	theConnector.setRelay(relayServer, relayServerPort, forceRelay)
	theConnector.setRoomID(_roomID)
	
	await internal_joinGame(theConnector, _nickname)
	
static func isInGame() -> bool:
	return main != null

static func errorOutToMainMenu(_errorText:String):
	Network.stopMultiplayer()
	changingScene = false
	if(isInGame()):
		await startMainMenu()
	LoadingScreen.showError(_errorText)
	GI.get_tree().paused = false
	changingScene = false
	LoadingScreen.finishLoad()

static func getWorld() -> World:
	return GI.world

static var fallbackGB:GameBalance
static func getGameBalance() -> GameBalance:
	if(!main):
		if(!fallbackGB):
			fallbackGB = GameBalance.new()
		Log.Printerr("Accessed fallback GameBalance object, something went wrong!")
		assert(false, "Accessed fallback GameBalance object, something went wrong!")
		return fallbackGB
	return main.GB
