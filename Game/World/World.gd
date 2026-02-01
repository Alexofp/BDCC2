extends Node
class_name World

## Class responsible for finding nearby points of interest

const CHUNK_SIZE = 50.0

var chunks:Dictionary[Vector3i, WorldChunk]
var nodeToChunk:Dictionary[Node3D, WorldChunk]

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
	return theWorld.internal_addPOI(_node)

func internal_addPOI(_node:Node3D) -> bool:
	if(_node is AIWanderArea):
		var thePos := _node.global_position
		var theChunk := getChunkOrCreate(thePos)
		
		theChunk.wanderAreas.append(_node)
		
		return true
	
	return false

static func addSitSpot(_prop:PropHandlerBase):
	var theWorld:World = GI.world
	if(!theWorld):
		Log.error("World.addSitSpot(): TRIED TO ADD SITTING PROP BUT THE WORLD IS NULL. PROP="+str(_prop))
		return false
	return theWorld.internal_addSitSpot(_prop)

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

func getNearbyChunks(_pos:Vector3, _radius:float) -> Array[WorldChunk]:
	var result:Array[WorldChunk] = chunks.values() #TODO: CODE THIS PROPERLY
	
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

func getRandomWanderArea(_pos:Vector3) -> AIWanderArea:
	var theAreas := getNearbyWanderAreas(_pos, 100.0)
	if(theAreas.is_empty()):
		return null
	return RNG.pick(theAreas)

func getNearestFreeSitSpot(_pos:Vector3, _radius:float = 50.0) -> PropHandlerBase:
	#TODO: Some kind of ring-based finder
	
	var nearestSpot:PropHandlerBase
	var theMinDist:float = _radius*_radius
	
	for chunkPos in chunks:
		var theChunk := chunks[chunkPos]
		
		for theProp in theChunk.sittingSpots:
			var theNewDist := theProp.global_position.distance_squared_to(_pos)
			
			if(theNewDist < theMinDist):
				# Check if someone else is already going to sit there?
				if(!theProp.getAllFreeSitterSlots().is_empty()):
					theMinDist = theNewDist
					nearestSpot = theProp
	
	return nearestSpot
