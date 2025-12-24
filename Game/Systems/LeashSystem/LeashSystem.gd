extends Node3D
class_name LeashSystem

const LEASH_INSTANCE = preload("res://Game/Systems/LeashSystem/LeashInstance.tscn")

var lastNetworkID:int = 0 # Doesn't get saved anywhere, always gets counted from zero after any restart

var leashes:Array[LeashInstance] = []
# Could probably have dictionaries to help find leashes faster
# a dictionary by leash point (serialized to node path)
# a dictionary of source by pawn id and zone
# a dictionary of target by pawn id and zone

func _ready() -> void:
	GI.leashSystem = self

func connectLeash(_source:LeashPointConnection, _target:LeashPointConnection, _leashSettings:LeashSettings):
	removeLeash(_source, _target) # Remove duplicate
	
	var newLeash:LeashInstance= LEASH_INSTANCE.instantiate()
	leashes.append(newLeash)
	
	add_child(newLeash)
	newLeash.networkID = lastNetworkID
	newLeash.setLeashSettings(_leashSettings)
	newLeash.setPoints(_source, _target)
	newLeash.name = str(lastNetworkID)
	
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(connectLeash_RPC.bind(newLeash.saveNetworkData().getBytes()))
	
	lastNetworkID += 1

@rpc("authority", "call_remote", "reliable")
func connectLeash_RPC(_data:PackedByteArray):
	var theBins:Bins = Bins.readUncompressed(_data)
	connectLeash_BINS(theBins)
	
func connectLeash_BINS(theBins:Bins):
	var newLeash:LeashInstance= LEASH_INSTANCE.instantiate()
	leashes.append(newLeash)
	add_child(newLeash)
	newLeash.loadNetworkData(theBins)
	newLeash.name = str(newLeash.networkID)
	
	if(newLeash.networkID > lastNetworkID):
		lastNetworkID = newLeash.networkID
	
func connectLeash_DATA(_data:Dictionary):
	var newLeash:LeashInstance= LEASH_INSTANCE.instantiate()
	leashes.append(newLeash)
	add_child(newLeash)
	newLeash.loadData(_data)
	newLeash.name = str(newLeash.networkID)
	
	if(newLeash.networkID > lastNetworkID):
		lastNetworkID = newLeash.networkID
	

func getLeash(_source:LeashPointConnection, _target:LeashPointConnection) -> LeashInstance:
	for leash in leashes:
		if(leash.p1con.isSameAs(_source) && leash.p2con.isSameAs(_target)):
			return leash
	
	return null
	
func hasLeash(_source:LeashPointConnection, _target:LeashPointConnection) -> bool:
	if(getLeash(_source, _target)):
		return true
	
	return false

func removeLeash(_source:LeashPointConnection, _target:LeashPointConnection) -> bool:
	var theLeash := getLeash(_source, _target)
	if(theLeash && !theLeash.is_queued_for_deletion()):
		theLeash.queue_free()
		return true
	return false

@rpc("authority", "call_remote", "reliable")
func removeLeash_RPC(_nid:int):
	for leash in leashes:
		if(leash.networkID == _nid):
			leash.queue_free()
			return

func clearupLeashInstance(_leash:LeashInstance):
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(removeLeash_RPC.bind(_leash.networkID))
	leashes.erase(_leash)

func clearLeashes():
	var leashesToClear := leashes.duplicate()
	for leash in leashesToClear:
		leash.queue_free()

func deleteAllSourceLeashes(_connection:LeashPointConnection):
	var toDelete:Array[LeashInstance] = []
	for leash in leashes:
		if(leash.p1con && leash.p1con.isSameAs(_connection)):
			toDelete.append(leash)
	for leash in toDelete:
		leash.queue_free()

func deleteAllTargetLeashes(_connection:LeashPointConnection):
	var toDelete:Array[LeashInstance] = []
	for leash in leashes:
		if(leash.p2con && leash.p2con.isSameAs(_connection)):
			toDelete.append(leash)
	for leash in toDelete:
		leash.queue_free()

func saveNetworkData() -> Bins:
	var ar:Array = [Bins.U32, leashes.size()]
	for leash in leashes:
		ar.append_array([
			Bins.BINS, leash.saveNetworkData(),
		])
	return Bins.saveStartEnd(ar)

func loadNetworkData(_data:Bins):
	_data.loadStart()
	
	clearLeashes()
	var amLeashes:int = _data.readU32()
	for _i in amLeashes:
		connectLeash_BINS(_data.readBins())
	
	_data.endLoad()

func saveData() -> Dictionary:
	var leashData:Array = []
	for leash in leashes:
		leashData.append(leash.saveData())
	
	return {
		leashes = leashData,
	}

func loadData(_data:Dictionary):
	clearLeashes()
	var leashData:Array = SAVE.loadVar(_data, "leashes", [])
	for leashEntry in leashData:
		connectLeash_DATA(leashEntry)
	
	pass
