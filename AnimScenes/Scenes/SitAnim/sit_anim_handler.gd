extends Node3D

@onready var sit_spawner: AnimSceneSpawner = $SitSpawner
@onready var interactable: Interactable = %Interactable

func _ready():
	interactable.dynamicActionsFunc = getActions

func getActions(_interactor:Interactor, _user:DollController) -> Array[InteractAction]:
	if(!_user):
		return []
	var thePawn:CharacterPawn = _user.getPawn()
	if(!thePawn):
		return []

	var result:Array[InteractAction] = []
	
	if(sit_spawner.getSitter("dom") == thePawn):
		result.append(InteractAction.create(
			"unsit", "Get up",
		))
	
	if(!sit_spawner.hasSitter("dom") && thePawn.canSit()):
		result.append(InteractAction.create(
			"sit", "Sit",
		))
	
	return result

func _on_interactable_on_interact(user: DollController, action: InteractAction) -> void:
	if(action.id == "sit"):
		if(!sit_spawner.isSpawned()):
			sit_spawner.spawn()
		sit_spawner.setSitter("dom", user.getPawn())
	if(action.id == "unsit"):
		if(sit_spawner.getSitter("dom") == user.getPawn()):
			sit_spawner.despawn()
			
func saveNetworkData() -> Dictionary:
	return {
		sit = sit_spawner.saveNetworkedData(),
	}

func loadNetworkData(_data:Dictionary):
	sit_spawner.loadNetworkData(SAVE.loadVar(_data, "sit", {}))
