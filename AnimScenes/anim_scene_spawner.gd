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
		Network.rpcClients(setScenePath, [thePath])

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

func saveNetworkedData() -> Dictionary:
	var sceneData = null
	if(spawnedScene):
		sceneData = spawnedScene.saveNetworkData()
	return {
		spawned = isSpawned(),
		scenePath = scenePath,
		spawnedScene = sceneData,
	}

func loadNetworkData(_data:Dictionary):
	var shouldBeSpawned:bool = SAVE.loadVar(_data, "spawned", false)
	var newScenePath = SAVE.loadVar(_data, "scenePath", "")
	if(newScenePath != ""):
		setScenePath(newScenePath)
	if(shouldBeSpawned):
		spawn()
		
		var sceneData = SAVE.loadVar(_data, "spawnedScene", null)
		if((sceneData is Dictionary) && spawnedScene):
			spawnedScene.loadNetworkData(sceneData)
	else:
		despawn()
	
	updateAnim.call_deferred()
