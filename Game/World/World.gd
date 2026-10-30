extends Node
class_name World

## Class responsible for finding nearby points of interest

const DEBUG_WORLD:bool = true
const CHUNK_SIZE = 50.0

var things:Dictionary[int, Dictionary] # dict[kind, dict[vec2i, array[thing]]]
var thingToKinds:Dictionary[Node3D, Array] # dict[node, array[kind]]
var thingToCachedPos:Dictionary[Node3D, Vector2i] # dict[node, vec2]
var thingsDynamic:Array[Node3D]
var thingsCheckOnce:Array[Node3D]

func _ready() -> void:
	GI.world = self

func getChunkPos2(_pos:Vector3) -> Vector2i:
	return Vector2i(int(round(_pos.x/CHUNK_SIZE)), int(round(_pos.z/CHUNK_SIZE)))

func getChunkPos2Of(_node:Node3D) -> Vector2i:
	return getChunkPos2(_node.global_position)

static func addThing(_kind:int, _node:Node3D, _dynamic:bool = false):
	if(!GM.world):
		Log.error("World doesn't exist!")
		return
	GM.world.addThingToWorld(_kind, _node, _dynamic)

func addThingToWorld(_kind:int, _node:Node3D, _dynamic:bool = false):
	if(!_node):
		return
	if(!_node.is_inside_tree()):
		assert(false, "Trying to add a node into the world that is not added to the tree")
		return
	if(!things.has(_kind)):
		var newThingDict:Dictionary[Vector2i, Array]
		things[_kind] = newThingDict
	var theDict:Dictionary[Vector2i, Array] = things[_kind]
	var theVec2:Vector2i = getChunkPos2Of(_node)
	
	if(thingToCachedPos.has(_node)):
		var theExistingVec2:Vector2i = thingToCachedPos[_node]
		if(!theExistingVec2 != theVec2):
			notifyThingMoved(_node)
	else:
		thingToCachedPos[_node] = theVec2
	
	if(!theDict.has(theVec2)):
		var theAr:Array[Node3D] = [_node]
		theDict[theVec2] = theAr
	else:
		theDict[theVec2].append(_node)
	if(!thingToKinds.has(_node)):
		var theAr:Array[int] = [_kind]
		thingToKinds[_node] = theAr
		_node.tree_exiting.connect(onThingRemoved.bind(_node))
	else:
		thingToKinds[_node].append(_kind)
	if(_dynamic):
		thingsDynamic.append(_node)
	else:
		thingsCheckOnce.append(_node)
	if(DEBUG_WORLD):
		Log.Print("(World) thing added "+str(theVec2)+": "+str(_node))

func onThingRemoved(_node:Node3D):
	if(!thingToCachedPos.has(_node)):
		return
	var thePos:Vector2i = thingToCachedPos[_node]
	var theKinds:Array[int] = thingToKinds[_node]
	for theKind:int in theKinds:
		if(!things.has(theKind)):
			continue
		var thePosToThings:Dictionary[Vector2i, Array] = things[theKind]
		if(!thePosToThings.has(thePos)):
			continue
		var theThings:Array[Node3D] = thePosToThings[thePos]
		theThings.erase(_node)
		if(theThings.is_empty()):
			thePosToThings.erase(thePos)
	
	thingToKinds.erase(_node)
	thingToCachedPos.erase(_node)
	thingsDynamic.erase(_node)
	thingsCheckOnce.erase(_node)
	if(DEBUG_WORLD):
		Log.Print("(World) thing removed "+str(thePos)+": "+str(_node))

func _physics_process(_delta: float) -> void:
	for theNode:Node3D in thingsDynamic:
		notifyThingMoved(theNode)
	if(!thingsCheckOnce.is_empty()):
		for theNode:Node3D in thingsCheckOnce:
			notifyThingMoved(theNode)
		thingsCheckOnce.clear()

func notifyThingMoved(_node:Node3D):
	if(!thingToCachedPos.has(_node)):
		return
	var theNewPos:Vector2i = getChunkPos2Of(_node)
	var theExistingPos:Vector2i = thingToCachedPos[_node]
	if(theNewPos == theExistingPos):
		return
	thingToCachedPos[_node] = theNewPos
	var theKinds:Array[int] = thingToKinds[_node]
	for theKind:int in theKinds:
		#var things:Dictionary[int, Dictionary] # dict[kind, dict[vec2i, array[thing]]]
		if(!things.has(theKind)):
			continue
		var thePosToThings:Dictionary[Vector2i, Array] = things[theKind]
		if(!thePosToThings.has(theExistingPos)):
			continue
		var theThings:Array[Node3D] = thePosToThings[theExistingPos]
		theThings.erase(_node)
		#if(theThings.is_empty()):
		#	thePosToThings.erase(theExistingPos)
		
		if(!thePosToThings.has(theNewPos)):
			var theAr:Array[Node3D] = [_node]
			thePosToThings[theNewPos] = theAr
		else:
			thePosToThings[theNewPos].append(_node)

func getChunkPos(_pos:Vector3) -> Vector3i:
	return Vector3i(int(round(_pos.x/CHUNK_SIZE)), int(round(_pos.y/CHUNK_SIZE)), int(round(_pos.z/CHUNK_SIZE)))

func getThingsNear(_kind:int, _pos:Vector3, _radius:float) -> Array[Node3D]:
	var distSquared:float = _radius*_radius
	var theThings:Array[Node3D] = getThingsRoughlyNear(_kind, _pos, _radius)
	var theThingsAm:int = theThings.size()
	for _i:int in theThingsAm:
		var _index:int = theThingsAm - 1 - _i
		var theNode:Node3D = theThings[_index]
		if(theNode.global_position.distance_squared_to(_pos) > distSquared):
			theThings.remove_at(_index)
	return theThings

func getPropsNear(_kind:int, _pos:Vector3, _radius:float) -> Array[PropHandlerBase]:
	var theThings:Array[Node3D] = getThingsNear(_kind, _pos, _radius)
	var result:Array[PropHandlerBase]
	for theThing:Node3D in theThings:
		if(theThing is PropHandlerBase):
			result.append(theThing)
	return result

# Might include things that are outside of the radius
func getThingsRoughlyNear(_kind:int, _pos:Vector3, _radius:float) -> Array[Node3D]:
	if(!things.has(_kind)):
		return []
	var result:Array[Node3D]
	
	var thePosToThings:Dictionary[Vector2i, Array] = things[_kind]
	
	var thePoses:Array[Vector2i] = getAllAffectedChunkPoses2(_pos, _radius)
	for thePos:Vector2i in thePoses:
		if(!thePosToThings.has(thePos)):
			continue
		result.append_array(thePosToThings[thePos])
	
	return result

func getHighCorner2(_pos:Vector3, _radius:float) -> Vector2i:
	return getChunkPos2(_pos + Vector3(_radius, 0.0, _radius))
	#return Vector3i(int(ceil(_pos.x+_radius)),int(ceil(_pos.y+_radius)),int(ceil(_pos.z+_radius)))

func getLowCorner2(_pos:Vector3, _radius:float) -> Vector2i:
	return getChunkPos2(_pos - Vector3(_radius, 0.0, _radius))
	#return Vector3i(int(floor(_pos.x-_radius)),int(floor(_pos.y-_radius)),int(floor(_pos.z-_radius)))

func getAllAffectedChunkPoses2(_pos:Vector3, _radius:float) -> Array[Vector2i]:
	var result:Array[Vector2i]
	var theLowCorner := getLowCorner2(_pos, _radius)
	var theHighCorner := getHighCorner2(_pos, _radius)
	
	for _ix in theHighCorner.x-theLowCorner.x+1:
		var _x:int = theLowCorner.x + _ix
		for _iy in theHighCorner.y-theLowCorner.y+1:
			var _y:int = theLowCorner.y + _iy
			#for _iz in theHighCorner.z-theLowCorner.z+1:
			#	var _z:int = theLowCorner.z + _iz
				#result.append(Vector3i(_x, _y, _z))
			result.append(Vector2i(_x, _y))
	return result

func getNearbyWanderAreas(_pos:Vector3, _radius:float) -> Array[AIWanderArea]:
	var theThings:Array[Node3D] = getThingsNear(WorldThing.WanderArea, _pos, _radius)
	var result:Array[AIWanderArea]
	for theThing:Node3D in theThings:
		if(theThing is AIWanderArea):
			result.append(theThing)
	return result

func getRandomWanderArea(_pos:Vector3, _radius:float = 100.0) -> AIWanderArea:
	var theAreas := getNearbyWanderAreas(_pos, _radius)
	if(theAreas.is_empty()):
		return null
	return RNG.pick(theAreas)

func getNearbyLeanLines(_pos:Vector3, _radius:float) -> Array[AILeanLine]:
	var theThings:Array[Node3D] = getThingsNear(WorldThing.LeanLine, _pos, _radius)
	var result:Array[AILeanLine]
	for theThing:Node3D in theThings:
		if(theThing is AILeanLine):
			result.append(theThing)
	return result

func getCloseLeanLine(_pos:Vector3, _radius:float = 50.0) -> AILeanLine:
	return getClosest(getNearbyLeanLines(_pos, _radius), _pos)

# Generic, slow
func getClosest(_ar:Array, _pos:Vector3):
	if(_ar.is_empty()):
		return null
	var closest = _ar[0]
	var theMinDist:float = _ar[0].global_position.distance_squared_to(_pos)
	for theNode in _ar:
		var theNewMinDist:float = theNode.global_position.distance_squared_to(_pos)
		if(theNewMinDist < theMinDist):
			closest = theNode
			theMinDist = theNewMinDist
	return closest

func getClosestThing(_ar:Array[Node3D], _pos:Vector3) -> Node3D:
	if(_ar.is_empty()):
		return null
	var closest:Node3D = _ar[0]
	var theMinDist:float = _ar[0].global_position.distance_squared_to(_pos)
	for theNode:Node3D in _ar:
		var theNewMinDist:float = theNode.global_position.distance_squared_to(_pos)
		if(theNewMinDist < theMinDist):
			closest = theNode
			theMinDist = theNewMinDist
	return closest

func getClosestProp(_ar:Array[PropHandlerBase], _pos:Vector3) -> PropHandlerBase:
	if(_ar.is_empty()):
		return null
	var closest:PropHandlerBase = _ar[0]
	var theMinDist:float = _ar[0].global_position.distance_squared_to(_pos)
	for theNode:PropHandlerBase in _ar:
		var theNewMinDist:float = theNode.global_position.distance_squared_to(_pos)
		if(theNewMinDist < theMinDist):
			closest = theNode
			theMinDist = theNewMinDist
	return closest
#	
func getNearbyActiveLeaners(_pos:Vector3, _radius:float) -> Array[Node3D]:
	return getThingsNear(WorldThing.Leaner, _pos, _radius)

func getNearestFreeSitSpot(_pos:Vector3, _radius:float = 50.0) -> PropHandlerBase:
	#return getClosest(getNearbySitProps(_pos, _radius), _pos, _radius)
	return getNearbyFreeSitterPropGeneric(WorldThing.SittingSpot, _pos, _radius)

func getNearbyFreeSitterPropsGeneric(_kind:int, _pos:Vector3, _radius:float, _mustBeFree:bool = true) -> Array[PropHandlerBase]:
	var theStocks:Array[Node3D] = getThingsNear(_kind, _pos, _radius)
	var possible:Array[PropHandlerBase]
	for theNode:Node3D in theStocks:
		if(!(theNode is PropHandlerBase)):
			continue
		if(_mustBeFree && theNode.getAllFreeSitterSlots().is_empty()):
			continue
		possible.append(theNode)
	return possible

func getNearbyFreeSitterPropGeneric(_kind:int, _pos:Vector3, _radius:float, _mustBeFree:bool = true) -> PropHandlerBase:
	return getClosestProp(getNearbyFreeSitterPropsGeneric(_kind, _pos, _radius, _mustBeFree), _pos)

func getNearbyStocks(_pos:Vector3, _radius:float, _mustBeFree:bool = true) -> PropHandlerBase:
	return getNearbyFreeSitterPropGeneric(WorldThing.Stocks, _pos, _radius, _mustBeFree)

func getClosestPlayerDist(_pos:Vector3) -> float:
	var theDist:float = 999999.9
	var _theClosestDoll:DollController
	
	for theDoll:DollController in GM.dollHolder.dollList:
		if(!theDoll.isControlledByAnyPlayer()):
			continue
		var theDistSqr:float = theDoll.global_position.distance_squared_to(_pos)
		if(theDistSqr < theDist):
			theDist = theDistSqr
			_theClosestDoll = theDoll
	
	if(!_theClosestDoll):
		return 999999.9
	return sqrt(theDist)

func getThings(_kind:int) -> Array[Node3D]:
	if(!things.has(_kind)):
		return []
	var result:Array[Node3D]
	var theThings:Dictionary[Vector2i, Array] = things[_kind]
	for thePos:Vector2i in theThings:
		result.append_array(theThings[thePos])
	return result

const SafePlayerDistance:float = 10.0
func getRandomInmateSpawn() -> InmateSpawnPoint:
	var _allPoints:Array[Node3D] = getThings(WorldThing.InmateSpawn)
	
	var _tryCount:int = 5
	while(_tryCount > 0):
		var _aRandomThing:Node3D = RNG.pick(_allPoints)
		if((_aRandomThing is InmateSpawnPoint) && getClosestPlayerDist(_aRandomThing.global_position) > SafePlayerDistance):
			return _aRandomThing
		_tryCount -= 1
	
	var theRandom:Node3D = RNG.pick(_allPoints)
	if(theRandom is InmateSpawnPoint):
		return theRandom
	return null

func getClosestInmateDespawnPoint(_pos:Vector3) -> InmateSpawnPoint:
	var theThing:Node3D = getClosest(getThingsRoughlyNear(WorldThing.InmateDespawn, _pos, 1.0), _pos)
	if(theThing && (theThing is InmateSpawnPoint)):
		return theThing
	return null
