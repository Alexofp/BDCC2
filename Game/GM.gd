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
	return characterRegistry

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

static func startNewGame(_holder:StartGameHolder):
	assert(!changingScene, "Already changing a scene!")
	LoadingScreen.startLoad()
	changingScene = true
	GI.get_tree().paused = true
	GI.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GI.get_tree().scene_changed
	#await GI.get_tree().current_scene.loadModeOnMap(_map, _mode, _args, {})
	await GI.get_tree().current_scene.loadStartGameHolder(_holder)
	var _connector := _holder.multiplayer.createNetworkConnector()
	LoadingScreen.setText("Hosting.." if _connector else "Loading..")
	
	#Network.setMyNickname("SERVER")
	
	if(_connector):
		var res = await Network.host(_connector)#hostFunc.call(_nickname) #Network.hostLAN(_nickname)
		if(res.isError()):
			errorOutToMainMenu(res.result if res.result is String else "Unable to start hosting")
			return
	GM.main.startGame()
	#await GI.get_tree().create_timer(2.0).timeout
	GI.get_tree().paused = false
	changingScene = false
	LoadingScreen.finishLoad()
	
static func startGame_OLD(_map:String, _mode:String, _args:Array = []):
	assert(!changingScene, "Already changing a scene!")
	LoadingScreen.startLoad()
	changingScene = true
	GI.get_tree().paused = true
	GI.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GI.get_tree().scene_changed
	await GI.get_tree().current_scene.loadModeOnMap(_map, _mode, _args, {})
	GM.main.startGame()
	GI.get_tree().paused = false
	changingScene = false
	LoadingScreen.finishLoad()

# Uses async
static func startMainMenu():
	assert(!changingScene, "Already changing a scene!")
	changingScene = true
	#TODO: STOP NETWORK
	Network.stopMultiplayer()
	GI.get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn")
	await GI.get_tree().scene_changed
	changingScene = false

# Uses async
static func startMainGameScene():
	assert(!changingScene, "Already changing a scene!")
	changingScene = true
	Network.stopMultiplayer()
	GI.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GI.get_tree().scene_changed
	changingScene = false

static func isChangingScene() -> bool:
	return changingScene

static func internal_hostGame(_connector:ConnectorNetworkBase, _nickname:String, _map:String, _mode:String, _args:Array = []):
	assert(!changingScene, "Already changing a scene!")
	LoadingScreen.startLoad()
	changingScene = true
	GI.get_tree().paused = true
	GI.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GI.get_tree().scene_changed
	await GI.get_tree().current_scene.loadModeOnMap(_map, _mode, _args, {})
	LoadingScreen.setText("Hosting..")
	
	#Network.setMyNickname(_nickname)
	
	var res = await Network.host(_connector)#hostFunc.call(_nickname) #Network.hostLAN(_nickname)
	if(res.isError()):
		errorOutToMainMenu(res.result if res.result is String else "Unable to start hosting")
		return
	GM.main.startGame()
	#await GI.get_tree().create_timer(2.0).timeout
	GI.get_tree().paused = false
	changingScene = false
	LoadingScreen.finishLoad()

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
	var modeToLoad:String = res.result["mode"]
	var modeDataToLoad:Dictionary = res.result["modeData"]
	var modeArgs:Array = []
	LoadingScreen.setText("Loading map..")
	GI.get_tree().change_scene_to_file("res://Game/Main.tscn")
	await GI.get_tree().scene_changed
	await GI.get_tree().current_scene.loadModeOnMap(mapToLoad, modeToLoad, modeArgs, modeDataToLoad)
	LoadingScreen.setText("Loading game state..")
	res = await Network.clientAskToJoin(_nickname)
	if(res.error):
		errorOutToMainMenu(res.result if res.result is String else "Failed to load game state")
		return
	GM.main.startGame()
	GI.get_tree().paused = false
	LoadingScreen.finishLoad()

static func joinMultiplayerGame(_connector:ConnectorNetworkBase):
	Network.serverPassword = _connector.password
	await internal_joinGame(_connector, "")

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

static func loadSavedGame(_savePath:String, _multiplayer:StartGameMultiplayer = null):
	#var theInfo := GameShortInfo.tryGetInfoFromSavePath(_savePath)
	#if(theInfo):
	#	print(theInfo.saveData())
	LoadingScreen.startLoad()
	LoadingScreen.setText("Starting..")
	var file := FileAccess.open(_savePath, FileAccess.READ)
	if(!file):
		errorOutToMainMenu("Failed to load saved game: "+error_string(FileAccess.get_open_error()))
		return
	var saveContent:String = file.get_as_text()
	#var theJsonSave := JSON.new()
	#var _jsonError:int = theJsonSave.parse(saveContent)
	#if(_jsonError != OK):
	#	errorOutToMainMenu("Failed to parse saved game: "+error_string(_jsonError)+". Json Error: Line: "+str(theJsonSave.get_error_line())+" Error: "+theJsonSave.get_error_message())
	#	return
	#if(theJsonSave.data == null || !(theJsonSave.data is Dictionary)):
	#	errorOutToMainMenu("Failed to parse saved game, corrupt data")
	#	return
	#var theGameData:Dictionary = theJsonSave.data
	var theData = str_to_var(saveContent)
	if(theData == null || !(theData is Dictionary)):
		errorOutToMainMenu("Failed to parse saved game, corrupt data")
		return
	var theGameData:Dictionary = theData
	
	await startMainGameScene()
	GI.get_tree().paused = true
	changingScene = true
	LoadingScreen.setText("Loading game..")
	GM.main.gameSavePath = _savePath
	var _succ:bool = await GI.get_tree().current_scene.loadData(theGameData)
	if(!_succ):
		errorOutToMainMenu("Failed to load gamemode data, corrupt save?")
		return

	var _connector := _multiplayer.createNetworkConnector() if _multiplayer else null
	LoadingScreen.setText("Hosting.." if _connector else "Loading..")
	if(_connector):
		var res = await Network.host(_connector)#hostFunc.call(_nickname) #Network.hostLAN(_nickname)
		if(res.isError()):
			errorOutToMainMenu(res.result if res.result is String else "Unable to start hosting")
			return
	changingScene = false
	GI.get_tree().paused = false
	LoadingScreen.finishLoad()

static var fallbackGB:GameBalance
static func getGameBalance() -> GameBalance:
	if(!main):
		if(!fallbackGB):
			fallbackGB = GameBalance.new()
		Log.Printerr("Accessed fallback GameBalance object, something went wrong!")
		assert(false, "Accessed fallback GameBalance object, something went wrong!")
		return fallbackGB
	return main.GB

static func getGameVersionStr() -> String:
	return ProjectSettings.get_setting("application/config/version")
