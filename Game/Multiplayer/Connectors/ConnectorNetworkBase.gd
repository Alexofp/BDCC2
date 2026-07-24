extends Node
class_name ConnectorNetworkBase

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
