extends Node
class_name ConnectorNetworkBase

var id:String = "ERROR"
var disabled:bool = false
var maxPlayers:int = 32
var password:String

func getName() -> String:
	return "Fill me!"

func getListName() -> String:
	return getName()

func getJoinSettings() -> Dictionary:
	return {}

func applyJoinSetting(_id:String, _value) -> bool:
	set(_id, _value)
	return false

func getHostSettings() -> Dictionary:
	return {}

func applyHostSetting(_id:String, _value) -> bool:
	set(_id, _value)
	return false

# Errors
#const OK = 0
const ERROR_GENERIC = 1

func doHost() -> FuncResultOrError:
	await get_tree().process_frame
	return FuncResultOrError.createError(Network.ERROR_GENERIC, "Trying to host using a dummy ConnectorNetworkBase")

func doJoin() -> FuncResultOrError:
	await get_tree().process_frame
	return FuncResultOrError.createError(Network.ERROR_GENERIC, "Trying to join using a dummy ConnectorNetworkBase")

func stopMultiplayer():
	pass

func setRoomID(_roomID:String):
	Network.roomID = _roomID
	Network.roomIDChanged.emit(_roomID)

func asyncCondition(cond: Callable, timeout: float = 10.0) -> Error:
	timeout = Time.get_ticks_msec() + timeout * 1000
	while not cond.call():
		await get_tree().process_frame
		if Time.get_ticks_msec() > timeout:
			return ERR_TIMEOUT
	return OK
