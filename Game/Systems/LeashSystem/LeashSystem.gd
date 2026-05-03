extends Node3D
class_name LeashSystem

const LEASH_INSTANCE = preload("res://Game/Systems/LeashSystem/LeashInstance.tscn")

var lastNetworkID:int = 0 # Doesn't get saved anywhere, always gets counted from zero after any restart

var leashes:Array[LeashInstance] = []
var sourceToLeashes:Dictionary[Node3D, Array]
var targetToLeashes:Dictionary[Node3D, Array]
# Could probably have dictionaries to help find leashes faster
# a dictionary by leash point (serialized to node path)
# a dictionary of source by pawn id and zone
# a dictionary of target by pawn id and zone

func _ready() -> void:
	GI.leashSystem = self

func connectLeashExclusive(_source:LeashPointConnection, _target:LeashPointConnection, _leashSettings:LeashSettings):
	deleteAllLeashesWithTarget(_target.getCacheNode())
	connectLeash(_source, _target, _leashSettings)

func connectLeash(_source:LeashPointConnection, _target:LeashPointConnection, _leashSettings:LeashSettings):
	removeLeash(_source, _target) # Remove duplicate
	
	var newLeash:LeashInstance= LEASH_INSTANCE.instantiate()
	leashes.append(newLeash)
	
	add_child(newLeash)
	newLeash.networkID = lastNetworkID
	newLeash.setLeashSettings(_leashSettings)
	newLeash.setPoints(_source, _target)
	newLeash.name = str(lastNetworkID)
	
	doCachePoint(sourceToLeashes, _source, newLeash)
	doCachePoint(targetToLeashes, _target, newLeash)
	onLeashAdded(newLeash)
	
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(connectLeash_RPC.bind(newLeash.saveNetworkData().getBytes()))
	
	lastNetworkID += 1

func onLeashAdded(_leash:LeashInstance):
	var theTarget := _leash.getTargetPawn()
	if(theTarget):
		theTarget.updateCollisions()

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
	
	doCachePoint(sourceToLeashes, newLeash.p1con, newLeash)
	doCachePoint(targetToLeashes, newLeash.p2con, newLeash)
	onLeashAdded(newLeash)
	
func connectLeash_DATA(_data:Dictionary):
	var newLeash:LeashInstance= LEASH_INSTANCE.instantiate()
	leashes.append(newLeash)
	add_child(newLeash)
	newLeash.loadData(_data)
	newLeash.name = str(newLeash.networkID)
	
	if(newLeash.networkID > lastNetworkID):
		lastNetworkID = newLeash.networkID

	doCachePoint(sourceToLeashes, newLeash.p1con, newLeash)
	doCachePoint(targetToLeashes, newLeash.p2con, newLeash)
	onLeashAdded(newLeash)

func getAllLeashesOfSourceNode(_node:Node3D) -> Array[LeashInstance]:
	if(!sourceToLeashes.has(_node)):
		return []
	return sourceToLeashes[_node]

func getAllLeashesOfTargetNode(_node:Node3D) -> Array[LeashInstance]:
	if(!targetToLeashes.has(_node)):
		return []
	return targetToLeashes[_node]

func getLeashToChainTo(_source:LeashPointConnection, _target:LeashPointConnection) -> LeashInstance:
	var allLeashes := getAllLeashesOfSourceNode(_source.getCacheNode())
	
	var prevLeash:LeashInstance = null
	for theLeash in allLeashes:
		if(theLeash.p2con.isSameAs(_target)):
			return prevLeash
		
		if(!theLeash.p1con.isSameAs(_source)):
			continue
		
		prevLeash = theLeash
	return prevLeash

func getLeash(_source:LeashPointConnection, _target:LeashPointConnection) -> LeashInstance:
	var theCachePoint := _source.getCacheNode()
	if(!sourceToLeashes.has(theCachePoint)):
		return null
	var leashesToCheck:Array[LeashInstance] = sourceToLeashes[theCachePoint]
	for leash in leashesToCheck:
		if(leash.p1con.isSameAs(_source) && leash.p2con.isSameAs(_target)):
			return leash
	
	return null
	
func hasLeash(_source:LeashPointConnection, _target:LeashPointConnection) -> bool:
	if(getLeash(_source, _target)):
		return true
	
	return false

func findPawnLeashSimple(_sourcePawn:CharacterPawn, _sourcePoint:String, _targetPawn:CharacterPawn, _targetPoint:String) -> LeashInstance:
	if(!sourceToLeashes.has(_sourcePawn)):
		return null
	var leashesToCheck:Array[LeashInstance] = sourceToLeashes[_sourcePawn]
	for leash in leashesToCheck:
		if(leash.p1con.pawnLeashPoint == _sourcePoint && leash.p2con.getCacheNode() == _targetPawn && leash.p2con.pawnLeashPoint == _targetPoint):
			return leash
	return null
	
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
	if(_leash.wasDeleted):
		return
	_leash.wasDeleted = true
	var theTarget := _leash.getTargetPawn()
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(removeLeash_RPC.bind(_leash.networkID))
	leashes.erase(_leash)
	removePointFromCache(sourceToLeashes, _leash.p1con, _leash)
	removePointFromCache(targetToLeashes, _leash.p2con, _leash)
	if(theTarget):
		theTarget.updateCollisions()

func clearLeashes():
	var leashesToClear := leashes.duplicate()
	for leash in leashesToClear:
		leash.queue_free()
	sourceToLeashes.clear()
	targetToLeashes.clear()
	leashes.clear()

func deleteAllSourceLeashes_SLOW(_connection:LeashPointConnection):
	var toDelete:Array[LeashInstance] = []
	for leash in leashes:
		if(leash.p1con && leash.p1con.isSameAs(_connection)):
			toDelete.append(leash)
	for leash in toDelete:
		leash.queue_free()

func deleteAllSourceLeashes(_connection:LeashPointConnection):
	var theCachePoint := _connection.getCacheNode()
	if(!theCachePoint || !sourceToLeashes.has(theCachePoint)):
		return
	
	var toDelete:Array[LeashInstance] = sourceToLeashes[theCachePoint]
	var toDeleteAm:int = toDelete.size()
	for _i in toDeleteAm:
		var _indx:int = toDeleteAm - 1 - _i
		toDelete[_indx].queue_free()

func deleteAllTargetLeashes_SLOW(_connection:LeashPointConnection):
	var toDelete:Array[LeashInstance] = []
	for leash in leashes:
		if(leash.p2con && leash.p2con.isSameAs(_connection)):
			toDelete.append(leash)
	for leash in toDelete:
		leash.queue_free()

func deleteAllTargetLeashes(_connection:LeashPointConnection):
	var theCachePoint := _connection.getCacheNode()
	if(!theCachePoint || !targetToLeashes.has(theCachePoint)):
		return
	
	var toDelete:Array[LeashInstance] = targetToLeashes[theCachePoint]
	var toDeleteAm:int = toDelete.size()
	for _i in toDeleteAm:
		var _indx:int = toDeleteAm - 1 - _i
		toDelete[_indx].queue_free()

func doCachePoint(_cache:Dictionary[Node3D, Array], _point:LeashPointConnection, _leash:LeashInstance) -> bool:
	var theCachePoint := _point.getCacheNode()
	if(!theCachePoint):
		return false
	
	if(!_cache.has(theCachePoint)):
		var newAr:Array[LeashInstance] = [_leash]
		_cache[theCachePoint] = newAr
	else:
		_cache[theCachePoint].append(_leash)
	return true

func removePointFromCache(_cache:Dictionary[Node3D, Array], _point:LeashPointConnection, _leash:LeashInstance) -> bool:
	var theCachePoint := _point.getCacheNode()
	if(!theCachePoint):
		return false
	if(!_cache.has(theCachePoint)):
		return false
	_cache[theCachePoint].erase(_leash)
	if(_cache[theCachePoint].is_empty()):
		_cache.erase(theCachePoint)
	return true

func deleteAllLeashesWithTarget(_pawn:Node3D):
	if(!_pawn || !targetToLeashes.has(_pawn)):
		return
	var toDelete:Array[LeashInstance] = targetToLeashes[_pawn]
	var toDeleteAm:int = toDelete.size()
	for _i in toDeleteAm:
		var _indx:int = toDeleteAm - 1 - _i
		var theLeash:LeashInstance = toDelete[_indx]
		clearupLeashInstance(theLeash)
		theLeash.queue_free()

func deleteAllLeashesWithSource(_pawn:Node3D):
	if(!_pawn || !sourceToLeashes.has(_pawn)):
		return
	var toDelete:Array[LeashInstance] = sourceToLeashes[_pawn]
	var toDeleteAm:int = toDelete.size()
	for _i in toDeleteAm:
		var _indx:int = toDeleteAm - 1 - _i
		var theLeash:LeashInstance = toDelete[_indx]
		clearupLeashInstance(theLeash)
		theLeash.queue_free()

func hasAnyLeashesBetween(_pawn:Node3D, _target:Node3D) -> bool:
	if(!_pawn || !sourceToLeashes.has(_pawn)):
		return false
	var toDelete:Array[LeashInstance] = sourceToLeashes[_pawn]
	var toDeleteAm:int = toDelete.size()
	for _i in toDeleteAm:
		var _indx:int = toDeleteAm - 1 - _i
		var theLeash:LeashInstance = toDelete[_indx]
		if(theLeash.p2con.getCacheNode() == _target):
			return true
	return false

func deleteAllLeashesBetween(_pawn:Node3D, _target:Node3D):
	if(!_pawn || !sourceToLeashes.has(_pawn)):
		return
	var toDelete:Array[LeashInstance] = sourceToLeashes[_pawn]
	var toDeleteAm:int = toDelete.size()
	for _i in toDeleteAm:
		var _indx:int = toDeleteAm - 1 - _i
		var theLeash:LeashInstance = toDelete[_indx]
		if(theLeash.p2con.getCacheNode() == _target):
			clearupLeashInstance(theLeash)
			theLeash.queue_free()

func onPawnDeleted(_pawn:CharacterPawn):
	if(Network.isServer()):
		deleteAllLeashesWithTarget(_pawn)
		deleteAllLeashesWithSource(_pawn)

func hasAnyLeashesInRightHand(_pawn:CharacterPawn) -> bool:
	if(!_pawn || !sourceToLeashes.has(_pawn)):
		return false
	var toCheck:Array[LeashInstance] = sourceToLeashes[_pawn]
	for theLeash in toCheck:
		if(theLeash.p1con.mode == LeashPointConnection.MODE_PAWN_LEASHPOINT && theLeash.p1con.pawnLeashPoint == "leashholder.R"):
			return true
	return false

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
