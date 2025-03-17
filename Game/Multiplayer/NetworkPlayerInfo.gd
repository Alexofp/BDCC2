extends Node
class_name NetworkPlayerInfo

var id:int = 1 # no save

@export var nickname:String = "ERROR_BAD_NAME?": set = changeNickname
@export var charID:String = "": set = changeCurrentCharID # Which character does this player currently control

# No save of all these
#var doll:DollController # The doll that this player is currently controlling

func changeCurrentCharID(newID:String):
	var oldCharID:=charID
	charID = newID
	Network.notifyPlayerSwitchedCharacter(self, oldCharID, charID)
	#if(isUs()):
	#	GM.handlePlayerCharIDChanged(charID)

func changeNickname(newName:String):
	Log.Print("SWITCHED NAME: "+newName)
	nickname = newName
	if(is_inside_tree()):
		Network.notifyNameChanged(self)

func saveNetworkData() -> Dictionary:
	return {
		id = id,
		nickname = nickname,
	}

func loadNetworkData(_data:Dictionary):
	id = SAVE.loadVar(_data, "id", -1)
	nickname = SAVE.loadVar(_data, "nickname", "ERROR??")

func getDebugData() -> Dictionary:
	return {
		nickname = nickname,
	}

func isUs() -> bool:
	return Network.getMultiplayerID() == id

func getName() -> String:
	return nickname
