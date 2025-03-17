extends Node3D
class_name AnimSceneSpawner

@export var scene:PackedScene

var spawnedScene:AnimSceneBase

func isSpawned() -> bool:
	return !!spawnedScene

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
	add_child(newScene)
	return spawnedScene

func getScene() -> AnimSceneBase:
	return spawnedScene

func despawn():
	if(!isSpawned()):
		return
	spawnedScene.queue_free()
	spawnedScene = null
