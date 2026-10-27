extends RefCounted
class_name StartGameMultiplayer

var multiplayer:String = ""
var connector:ConnectorNetworkBase

func createNetworkConnector() -> ConnectorNetworkBase:
	return connector

func getSettings() -> Dictionary:
	var theGameModesValues:Array = []
	for theGameModeID:String in GlobalRegistry.getGameModeDefRefs():
		var theGameModeDefRef:GameModeDef = GlobalRegistry.getGameModeDefRef(theGameModeID)
		theGameModesValues.append([theGameModeID, theGameModeDefRef.getName()])
	
	var theMultList:Array = [
		["", "Singleplayer"],
	]
	for theID:String in GlobalRegistry.networkConnectorRefs:
		var theConnector:ConnectorNetworkBase = GlobalRegistry.networkConnectorRefs[theID]
		theMultList.append([
			theID, theConnector.getListName(),
		])
	
	var result:Dictionary = {
		"multiplayer": {
			name = "Multiplayer",
			type = "selector",
			value = multiplayer,
			values = theMultList,
		},
	}
	if(connector):
		result.merge(connector.getHostSettings())
	
	return result

func applySetting(_id:String, _value) -> bool:
	set(_id, _value)
	if(_id == "multiplayer"):
		if(_value == ""):
			connector = null
		else:
			connector = GlobalRegistry.createNetworkConnector(_value)
		return true
	elif(connector):
		return connector.applyHostSetting(_id, _value)
	return false
