extends RefCounted
class_name PlayerData

var charID:String = ""
var gid:String = "" # Profile id of the player who this charID belongs to

var playerName:String = "" # The nickname of the player who created this character

func isPlayerConnected() -> bool:
	for theID:int in Network.players:
		var theInfo:NetworkPlayerInfo = Network.players[theID]
		if(theInfo.profile && theInfo.profile.gid == gid):
			return true
	return false

func saveData() -> Dictionary:
	return {
		charID = charID,
		gid = gid,
		playerName = playerName,
	}

func loadData(_data:Dictionary):
	charID = SAVE.loadVar(_data, "charID", "")
	gid = SAVE.loadVar(_data, "gid", "")
	playerName = SAVE.loadVar(_data, "playerName", "")
