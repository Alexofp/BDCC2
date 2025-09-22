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
	GameInteractor.get_tree().paused = true
	GameInteractor.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GameInteractor.get_tree().scene_changed
	await GameInteractor.get_tree().current_scene.loadModeOnMap(_map, _mode, _args)
	GM.main.startGame()
	GameInteractor.get_tree().paused = false
	changingScene = false
	LoadingScreen.finishLoad()

static func startMainMenu():
	assert(!changingScene, "Already changing a scene!")
	changingScene = true
	#TODO: STOP NETWORK
	Network.stopMultiplayer()
	GameInteractor.get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn")
	await GameInteractor.get_tree().scene_changed
	changingScene = false

static func isChangingScene() -> bool:
	return changingScene

static func internal_hostGame(hostFunc:Callable, _nickname:String, _map:String, _mode:int, _args:Array = []):
	assert(!changingScene, "Already changing a scene!")
	LoadingScreen.startLoad()
	changingScene = true
	GameInteractor.get_tree().paused = true
	GameInteractor.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GameInteractor.get_tree().scene_changed
	await GameInteractor.get_tree().current_scene.loadModeOnMap(_map, _mode, _args)
	LoadingScreen.setText("Hosting..")
	var res = await hostFunc.call(_nickname) #Network.hostLAN(_nickname)
	if(res.isError()):
		errorOutToMainMenu(res.result if res.result is String else "Unable to start hosting")
		return
	GM.main.startGame()
	#await GameInteractor.get_tree().create_timer(2.0).timeout
	GameInteractor.get_tree().paused = false
	changingScene = false
	LoadingScreen.finishLoad()

static func hostLANGame(_nickname:String, _map:String, _mode:int, _args:Array = []):
	await internal_hostGame(Network.hostLAN, _nickname, _map, _mode, _args)

static func hostNodeTunnelGame(_nickname:String, _map:String, _mode:int, _args:Array = [], relayServer:String = Network.NODETUNNEL_SERVER, relayServerPort:int = Network.NODETUNNEL_PORT):
	await internal_hostGame(Network.hostNodeTunnel.bind(relayServer, relayServerPort), _nickname, _map, _mode, _args)

static func hostNoray(_nickname:String, _map:String, _mode:int, _args:Array = [], relayServer:String = Network.NORAY_SERVER, relayServerPort:int = Network.NORAY_PORT):
	await internal_hostGame(Network.hostNoray.bind(relayServer, relayServerPort), _nickname, _map, _mode, _args)

static func internal_joinGame(joinFunc:Callable, _nickname:String):
	#Network.joinGame(_nickname, _ip)
	LoadingScreen.startLoad()
	GameInteractor.get_tree().paused = true
	LoadingScreen.setText("Connecting..")
	var res = await joinFunc.call()#Network.connectLAN(_ip)
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
	GameInteractor.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GameInteractor.get_tree().scene_changed
	await GameInteractor.get_tree().current_scene.loadModeOnMap(mapToLoad, modeToLoad, modeArgs)
	LoadingScreen.setText("Loading game state..")
	res = await Network.clientAskToJoin(_nickname)
	if(res.error):
		errorOutToMainMenu(res.result if res.result is String else "Failed to load game state")
		return
	GM.main.startGame()
	GameInteractor.get_tree().paused = false
	LoadingScreen.finishLoad()

static func joinLANGame(_nickname:String, _ip:String):
	await internal_joinGame(Network.connectLAN.bind(_ip), _nickname)

static func joinNodeTunnelGame(_nickname:String, _roomID:String, relayServer:String = Network.NODETUNNEL_SERVER, relayServerPort:int = Network.NODETUNNEL_PORT):
	await internal_joinGame(Network.connectNodeTunnel.bind(_roomID, relayServer, relayServerPort), _nickname)
	
static func joinNorayGame(_nickname:String, _roomID:String, relayServer:String = Network.NORAY_SERVER, relayServerPort:int = Network.NORAY_PORT, forceRelay:bool = false):
	await internal_joinGame(Network.connectNoray.bind(_roomID, relayServer, relayServerPort, forceRelay), _nickname)
	
static func isInGame() -> bool:
	return main != null

static func errorOutToMainMenu(_errorText:String):
	Network.stopMultiplayer()
	changingScene = false
	if(isInGame()):
		await startMainMenu()
	LoadingScreen.showError(_errorText)
	GameInteractor.get_tree().paused = false
	changingScene = false
	LoadingScreen.finishLoad()
