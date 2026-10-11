extends RefCounted
class_name StartGameMultiplayer

const NO:int = 0
const LAN:int = 1
const NORAY:int = 2

var multiplayer:int = NO
var maxPlayers:int = 32
var password:String = ""

# Lan-specific
var lanPort:int = LANNetworkConnector.DEFAULT_PORT

# Noray-specific
var norayServer:String = ""
var norayServerCustom:String = ""

func _init() -> void:
	norayServer = NorayNetworkConnector.NORAY_SERVERS[0]

func createNetworkConnector() -> ConnectorNetworkBase:
	if(multiplayer == LAN):
		var newLan := LANNetworkConnector.new()
		newLan.port = lanPort
		return newLan
	
	if(multiplayer == NORAY):
		var newCon := NorayNetworkConnector.new()
		var theSpread:Array = getNorayServer().split(":")
		if(theSpread.size() > 0):
			newCon.relayServer = theSpread[0]
		if(theSpread.size() > 1):
			newCon.relayServerPort = int(theSpread[1])
		return newCon
	
	return null

func getSettings() -> Dictionary:
	var theGameModesValues:Array = []
	for theGameModeID:String in GlobalRegistry.getGameModeDefRefs():
		var theGameModeDefRef:GameModeDef = GlobalRegistry.getGameModeDefRef(theGameModeID)
		theGameModesValues.append([theGameModeID, theGameModeDefRef.getName()])
	
	var result:Dictionary = {
		"multiplayer": {
			name = "Multiplayer",
			type = "selector",
			value = multiplayer,
			values = [
				[NO, "Singleplayer"],
				[LAN, "LAN (connect by ip)"],
				[NORAY, "Internet (connect by room code)"],
			],
		},
	}
	if(multiplayer != NO):
		result["maxPlayers"] = {
			name = "Max players",
			type = "int",
			value = maxPlayers,
		}
		result["password"] = {
			name = "Password",
			type = "string",
			value = password,
		}
	if(multiplayer == LAN):
		result["lanPort"] = {
			name = "LAN port",
			type = "int",
			value = lanPort,
		}
	if(multiplayer == NORAY):
		result["norayServer"] = {
			name = "Relay server",
			type = "selector",
			value = norayServer,
			values = NorayNetworkConnector.NORAY_SERVERS+["-Custom-"],
		}
	if(norayServer == "-Custom-"):
		result["norayServerCustom"] = {
			name = "Relay server ip/port",
			type = "string",
			value = norayServerCustom,
		}
	
	return result

func applySetting(_id:String, _value) -> bool:
	set(_id, _value)
	if(_id == "multiplayer"):
		return true
	if(_id == "norayServer"):
		if(norayServer == "-Custom-"):
			norayServerCustom = ""
		return true
	return false

func getNorayServer() -> String:
	if(!norayServerCustom.is_empty()):
		return norayServerCustom
	return norayServer
