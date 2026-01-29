extends Node
class_name NetworkPlayerInfo

var id:int = 1 # no save

@export var nickname:String = "ERROR_BAD_NAME?": set = changeNickname
var charID:String: # = "": set = changeCurrentCharID # Which character does this player currently control
	get:
		return Network.getCharIDOfPlayer(self)
	set(value):
		Network.setControlledCharID(id, value)

# No save of all these
#var doll:DollController # The doll that this player is currently controlling

var connecting:bool = false # Is this player still connecting to the server. If true, they won't receive game RPCs

func changeNickname(newName:String):
	Log.Print("SWITCHED NAME: "+newName)
	nickname = newName
	if(is_inside_tree()):
		Network.notifyNameChanged(self)

func getCharID() -> String:
	return charID

func saveNetworkData() -> Bins:
	var data := Bins.saveStart([
		Bins.I32, id,
		Bins.Str, nickname,
	])
	return data.endSave()

func loadNetworkData(_data:Bins):
	_data.loadStart()
	id = _data.readI32()
	nickname = _data.readStr()
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		id = id,
		nickname = nickname,
	}

func loadData(_data:Dictionary):
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

func sendToChat(_text:String):
	Network.sentToChat(id, _text)
