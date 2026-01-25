extends Node3D
class_name AnimSceneSpawner

@export var scene:PackedScene
var scenePath:String

signal onSpawned
signal onDespawned
signal onSpawnedChanged(isSpawned)
signal onPawnSwitch(id, pawn)
signal onDollSwitch(id, doll)
signal onAnimEvent(eventID, args)
signal onAnimPlay(state)

var spawnedScene:AnimSceneBase

@rpc("authority", "call_remote", "reliable")
func setScenePath(thePath:String):
	scenePath = thePath
	scene = load(scenePath)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(setScenePath.bind(thePath))

func isSpawned() -> bool:
	return !!spawnedScene

@rpc("authority", "call_remote", "reliable")
func spawn() -> AnimSceneBase:
	if(isSpawned() || scene == null):
		return null
	
	var newScene = scene.instantiate()
	if(newScene == null):
		return null
	if(!(newScene is AnimSceneBase)):
		newScene.queue_free()
		return null
	spawnedScene = newScene
	spawnedScene.onDollSwitch.connect(onSpawnedSceneDollSwitch)
	spawnedScene.onPawnSwitch.connect(onSpawnedScenePawnSwitch)
	spawnedScene.onAnimEvent.connect(onSpawnedSceneAnimEvent)
	spawnedScene.onAnimPlay.connect(onSpawnSceneAnimPlay)
	add_child(newScene, true)
	onSpawned.emit()
	onSpawnedChanged.emit(true)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(spawn)
	return spawnedScene

func onSpawnedSceneDollSwitch(_theID:String, _theDoll:DollController):
	onDollSwitch.emit(_theID, _theDoll)

func onSpawnedScenePawnSwitch(_theID:String, _thePawn:CharacterPawn):
	onPawnSwitch.emit(_theID, _thePawn)

func onSpawnedSceneAnimEvent(_eventID:String, _args:Variant):
	onAnimEvent.emit(_eventID, _args)

func onSpawnSceneAnimPlay(_state:String):
	onAnimPlay.emit(_state)

func getScene() -> AnimSceneBase:
	return spawnedScene

func unsitToStandSpot(_theID:String, _marker:Node3D) -> bool:
	if(!Network.isServer()):
		return false
	if(!isSpawned()):
		return false
	var thePawn := spawnedScene.getSitter(_theID)
	var theDoll := spawnedScene.getSitterDoll(_theID)
	if(!thePawn):
		return false
	spawnedScene.setSitter(_theID, null)
	var thePos := _marker.global_position
	thePawn.global_position = thePos
	if(theDoll):
		theDoll.global_position = thePos
	return true

@rpc("authority", "call_remote", "reliable")
func despawn():
	if(!isSpawned()):
		return
	spawnedScene.queue_free()
	spawnedScene = null
	onDespawned.emit()
	onSpawnedChanged.emit(false)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(despawn)

func despawnIfNoSitters() -> bool:
	if(!Network.isServer()):
		return false
	if(!isSpawned()):
		return false
	
	for sitterID in spawnedScene.sitters:
		if(spawnedScene.hasSitter(sitterID)):
			return false
	despawn()
	return true

func getSitter(_theID:String) -> CharacterPawn:
	if(!isSpawned()):
		return null
	return spawnedScene.getSitter(_theID)

func hasSitter(_theID:String) -> bool:
	if(!isSpawned()):
		return false
	return !!spawnedScene.getSitter(_theID)

func setSitter(_theID:String, _thePawn:CharacterPawn):
	if(!isSpawned()):
		return
	spawnedScene.setSitter(_theID, _thePawn)

func setProp(theSeat:String, theProp:Node3D):
	if(!isSpawned()):
		return
	spawnedScene.setProp(theSeat, theProp)

func getSitterDoll(_theID:String) -> DollController:
	if(!isSpawned()):
		return null
	return spawnedScene.getSitterDoll(_theID)

func hasSitterDoll(_theID:String) -> bool:
	if(!isSpawned()):
		return false
	return !!spawnedScene.getSitterDoll(_theID)

func updateAnim():
	if(spawnedScene):
		spawnedScene.updateAnim()

func getAverageBodyPos() -> Vector3:
	if(!spawnedScene):
		return global_position
	return spawnedScene.getAverageBodyPos()

func saveNetworkData() -> Bins:
	var data := Bins.saveStart([
		Bins.Bool, isSpawned(),
		Bins.StrShort, scenePath,
		Bins.BINS if isSpawned() else Bins.Ignore, spawnedScene.saveNetworkData() if isSpawned() else null,
	])
	return data.endSave()

func loadNetworkData(_data:Bins):
	_data.loadStart()
	var shouldBeSpawned:bool = _data.readBool()
	var newScenePath = _data.readStrShort()
	if(newScenePath != ""):
		setScenePath(newScenePath)
	if(shouldBeSpawned):
		spawn()
		var theSceneData := _data.readBins()
		if(spawnedScene):
			spawnedScene.loadNetworkData(theSceneData)
		else:
			Log.error("BAD SPAWNED SCENE? PATH="+str(newScenePath))
	else:
		despawn()
	_data.endLoad()
	
	updateAnim.call_deferred()

func saveData() -> Dictionary:
	var sceneData = null
	if(spawnedScene):
		sceneData = spawnedScene.saveData()
	return {
		spawned = isSpawned(),
		scenePath = scenePath,
		spawnedScene = sceneData,
	}

func loadData(_data:Dictionary):
	var shouldBeSpawned:bool = SAVE.loadVar(_data, "spawned", false)
	var newScenePath = SAVE.loadVar(_data, "scenePath", "")
	if(newScenePath != ""):
		setScenePath(newScenePath)
	if(shouldBeSpawned):
		spawn()
		
		var sceneData = SAVE.loadVar(_data, "spawnedScene", null)
		if((sceneData is Dictionary) && spawnedScene):
			spawnedScene.loadData(sceneData)
	else:
		despawn()
	
	updateAnim.call_deferred()
