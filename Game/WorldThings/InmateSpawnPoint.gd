extends Node3D
class_name InmateSpawnPoint

@export var canSpawn:bool = true
@export var canDespawn:bool = true

func _ready() -> void:
	if(canSpawn):
		World.addThing(WorldThing.InmateSpawn, self)
	if(canDespawn):
		World.addThing(WorldThing.InmateDespawn, self)
