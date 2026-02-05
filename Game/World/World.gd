extends Node
class_name World

## Class responsible for finding nearby points of interest

const CHUNK_SIZE = 50.0

var chunks:Dictionary[Vector3i, WorldChunk]
var nodeToChunk:Dictionary[Node3D, WorldChunk]
var stocks:Array[PropHandlerBase]

func _ready() -> void:
	GI.world = self

func getChunkPos(_pos:Vector3) -> Vector3i:
	return Vector3i(int(round(_pos.x/CHUNK_SIZE)), int(round(_pos.y/CHUNK_SIZE)), int(round(_pos.z/CHUNK_SIZE)))

func getChunkOrCreate(_pos:Vector3) -> WorldChunk:
	var theChunkPos := getChunkPos(_pos)
	
	if(!chunks.has(theChunkPos)):
		var newChunk:WorldChunk = WorldChunk.new()
		newChunk.pos = theChunkPos
		chunks[theChunkPos] = newChunk
		return newChunk
	
	return chunks[theChunkPos]

func getChunk(_pos:Vector3) -> WorldChunk:
	var theChunkPos := getChunkPos(_pos)
	if(!chunks.has(theChunkPos)):
		return null
	return chunks[theChunkPos]

# static point of interest
static func addPOI(_node:Node3D) -> bool:
	var theWorld:World = GI.world
	if(!theWorld):
		Log.error("World.addPOI(): TRIED TO ADD POI BUT THE WORLD IS NULL. NODE="+str(_node))
		return false
	theWorld.internal_addPOI.call_deferred(_node)
	return true

func internal_addPOI(_node:Node3D) -> bool:
	if(_node is AIWanderArea):
		var thePos := _node.global_position
		var theChunk := getChunkOrCreate(thePos)
		theChunk.wanderAreas.append(_node)
		return true
	if(_node is AILeanLine):
		var thePos := _node.global_position
		var theChunk := getChunkOrCreate(thePos)
		theChunk.leanLines.append(_node)
		return true
	
	return false

func addActiveLeaner(_prop:PropHandlerBase):
	var thePos := _prop.global_position
	var theChunk := getChunkOrCreate(thePos)
	if(!theChunk):
		return
	nodeToChunk[_prop] = theChunk
	theChunk.activeLeaners.append(_prop)
	_prop.tree_exiting.connect(onActiveLeanerDeleted.bind(_prop))

func onActiveLeanerDeleted(_prop:PropHandlerBase):
	if(nodeToChunk.has(_prop)):
		var theChunk := nodeToChunk[_prop]
		theChunk.activeLeaners.erase(_prop)
		nodeToChunk.erase(_prop)

static func addSitSpot(_prop:PropHandlerBase):
	var theWorld:World = GI.world
	if(!theWorld):
		Log.error("World.addSitSpot(): TRIED TO ADD SITTING PROP BUT THE WORLD IS NULL. PROP="+str(_prop))
		return false
	theWorld.internal_addSitSpot.call_deferred(_prop)
	return true

func internal_addSitSpot(_prop:PropHandlerBase) -> bool:
	var thePos := _prop.global_position
	var theChunk := getChunkOrCreate(thePos)
	if(!theChunk):
		return false
	nodeToChunk[_prop] = theChunk
	theChunk.sittingSpots.append(_prop)
	_prop.tree_exiting.connect(onSitPropDeleted.bind(_prop))
	return true

func onSitPropDeleted(_prop:PropHandlerBase):
	if(nodeToChunk.has(_prop)):
		var theChunk := nodeToChunk[_prop]
		theChunk.sittingSpots.erase(_prop)
		nodeToChunk.erase(_prop)

func updateSitPropChunk(_prop:PropHandlerBase):
	if(!nodeToChunk.has(_prop)):
		return
	var theChunk := nodeToChunk[_prop]
	var newChunk := getChunkOrCreate(getChunkPos(_prop.global_position))
	if(theChunk == newChunk):
		return
	theChunk.sittingSpots.erase(_prop)
	#nodeToChunk.erase(_prop) # No reason to
	
	newChunk.sittingSpots.append(_prop)
	nodeToChunk[_prop] = newChunk

func getAffectedRect(_pos:Vector3, _radius:float) -> Array[Vector3i]:
	var theResult:Array[Vector3i] = [getLowCorner(_pos, _radius), getHighCorner(_pos, _radius)]
	return theResult

func getHighCorner(_pos:Vector3, _radius:float) -> Vector3i:
	return getChunkPos(_pos + Vector3(_radius, _radius, _radius))
	#return Vector3i(int(ceil(_pos.x+_radius)),int(ceil(_pos.y+_radius)),int(ceil(_pos.z+_radius)))

func getLowCorner(_pos:Vector3, _radius:float) -> Vector3i:
	return getChunkPos(_pos - Vector3(_radius, _radius, _radius))
	#return Vector3i(int(floor(_pos.x-_radius)),int(floor(_pos.y-_radius)),int(floor(_pos.z-_radius)))

func getAllAffectedChunkPoses(_pos:Vector3, _radius:float) -> Array[Vector3i]:
	var result:Array[Vector3i]
	var theLowCorner := getLowCorner(_pos, _radius)
	var theHighCorner := getHighCorner(_pos, _radius)
	
	for _ix in theHighCorner.x-theLowCorner.x+1:
		var _x:int = theLowCorner.x + _ix
		for _iy in theHighCorner.y-theLowCorner.y+1:
			var _y:int = theLowCorner.y + _iy
			for _iz in theHighCorner.z-theLowCorner.z+1:
				var _z:int = theLowCorner.z + _iz
				result.append(Vector3i(_x, _y, _z))
		
	return result

#func getRingPoses(_pos:Vector3i, _ring:int) -> Array[Vector3i]:

func getNearbyChunks(_pos:Vector3, _radius:float) -> Array[WorldChunk]:
	var thePoses := getAllAffectedChunkPoses(_pos, _radius)
	var result:Array[WorldChunk]
	
	for thePos in thePoses:
		var theChunk := getChunk(thePos)
		if(!theChunk):
			continue
		result.append(theChunk)
	
	return result

func getNearbyWanderAreas(_pos:Vector3, _radius:float) -> Array[AIWanderArea]:
	var result:Array[AIWanderArea]
	var theChunks := getNearbyChunks(_pos, _radius)
	var radiusSquared:float = _radius * _radius
	for chunk in theChunks:
		var theAreas := chunk.wanderAreas
		for theArea in theAreas:
			if(theArea.global_position.distance_squared_to(_pos) <= radiusSquared):
				result.append(theArea)
	return result

func getRandomWanderArea(_pos:Vector3, _radius:float = 100.0) -> AIWanderArea:
	var theAreas := getNearbyWanderAreas(_pos, _radius)
	if(theAreas.is_empty()):
		return null
	return RNG.pick(theAreas)

func getNearbyLeanLines(_pos:Vector3, _radius:float) -> Array[AILeanLine]:
	var result:Array[AILeanLine]
	var theChunks := getNearbyChunks(_pos, _radius)
	var radiusSquared:float = _radius * _radius
	for chunk in theChunks:
		var theObjs := chunk.leanLines
		for theNode in theObjs:
			if(theNode.global_position.distance_squared_to(_pos) <= radiusSquared):
				result.append(theNode)
	return result

func getCloseLeanLine(_pos:Vector3, _radius:float = 50.0) -> AILeanLine:
	return getClosest(getNearbyLeanLines(_pos, _radius), _pos, _radius)

func getClosest(_ar:Array, _pos:Vector3, _radius:float = 50.0) -> Node3D:
	var closest:Node3D
	var theMinDist:float = _radius*_radius
	
	for theNode in _ar:
		var theNewDist:float = theNode.global_position.distance_squared_to(_pos)
		if(theNewDist < theMinDist):
			theMinDist = theNewDist
			closest = theNode
	return closest

func getNearbyActiveLeaners(_pos:Vector3, _radius:float) -> Array[PropHandlerBase]:
	var result:Array[PropHandlerBase]
	var theChunks := getNearbyChunks(_pos, _radius)
	var radiusSquared:float = _radius * _radius
	for chunk in theChunks:
		var theObjs := chunk.activeLeaners
		for theNode in theObjs:
			#if(!theNode.getAllFreeSitterSlots().is_empty()):
			#	continue
			if(theNode.global_position.distance_squared_to(_pos) <= radiusSquared):
				result.append(theNode)
	return result

func getNearbySitProps(_pos:Vector3, _radius:float, _mustBeFree:bool = true) -> Array[PropHandlerBase]:
	var result:Array[PropHandlerBase]
	var theChunks := getNearbyChunks(_pos, _radius)
	var radiusSquared:float = _radius * _radius
	for chunk in theChunks:
		var theObjs := chunk.sittingSpots
		for theNode in theObjs:
			if(_mustBeFree && theNode.getAllFreeSitterSlots().is_empty()):
				continue
			if(theNode.global_position.distance_squared_to(_pos) <= radiusSquared):
				result.append(theNode)
	return result

func getNearestFreeSitSpot(_pos:Vector3, _radius:float = 50.0) -> PropHandlerBase:
	return getClosest(getNearbySitProps(_pos, _radius), _pos, _radius)

func addStocks(_prop:PropHandlerBase):
	stocks.append(_prop)
	_prop.tree_exiting.connect(onStocksRemoved.bind(_prop))

func onStocksRemoved(_prop:PropHandlerBase):
	stocks.erase(_prop)

func getNearbyStocks(_pos:Vector3, _radius:float, _mustBeFree:bool = true) -> PropHandlerBase:
	#var radiusSquared:float = _radius * _radius
	
	if(!_mustBeFree):
		return getClosest(stocks, _pos, _radius)
	
	var possible:Array[PropHandlerBase]
	
	for theNode in stocks:
		if(_mustBeFree && theNode.getAllFreeSitterSlots().is_empty()):
			continue
		#if(theNode.global_position.distance_squared_to(_pos) <= radiusSquared):
		possible.append(theNode)
	
	return getClosest(possible, _pos, _radius)
