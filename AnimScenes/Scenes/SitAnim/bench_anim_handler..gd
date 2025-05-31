extends Node3D

@onready var sit_spawner_left: AnimSceneSpawner = $SitSpawnerLeft
@onready var sit_spawner_right: AnimSceneSpawner = $SitSpawnerRight
@onready var interactable: Interactable = %Interactable
@onready var sit_spawner_cuddle: AnimSceneSpawner = $SitSpawnerCuddle

func _ready():
	interactable.dynamicActionsFunc = getActions

func isPawnCuddling(thePawn:CharacterPawn) -> bool:
	if(sit_spawner_cuddle.getSitter("dom") == thePawn || sit_spawner_cuddle.getSitter("sub") == thePawn):
		return true
	return false
	
func isPawnSittingLeft(thePawn:CharacterPawn) -> bool:
	if(sit_spawner_cuddle.getSitter("dom")==thePawn || sit_spawner_left.getSitter("dom")==thePawn):
		return true
	return false
	
func isPawnSittingRight(thePawn:CharacterPawn) -> bool:
	if(sit_spawner_cuddle.getSitter("sub")==thePawn || sit_spawner_right.getSitter("dom")==thePawn):
		return true
	return false

func isLeftSeatFree() -> bool:
	if(!sit_spawner_cuddle.hasSitter("dom") && !sit_spawner_left.hasSitter("dom")):
		return true
	return false

func isRightSeatFree() -> bool:
	if(!sit_spawner_cuddle.hasSitter("sub") && !sit_spawner_right.hasSitter("dom")):
		return true
	return false
	
func getActions(_interactor:Interactor, _user:DollController) -> Array[InteractAction]:
	if(!_user):
		return []
	var thePawn:CharacterPawn = _user.getPawn()
	if(!thePawn):
		return []
	var isSittingOnLeft:bool = isPawnSittingLeft(thePawn)
	var isSittingOnRight:bool = isPawnSittingRight(thePawn)
	var isCuddling:bool = sit_spawner_cuddle.isSpawned()

	var result:Array[InteractAction] = []
	
	if(isSittingOnLeft || isSittingOnRight):
		result.append(InteractAction.create(
			"unsit", "Get up",
		))
	else:
		if(isLeftSeatFree() && thePawn.canSit()):
			result.append(InteractAction.create(
				"sitLeft", "Sit (left)",
			))
		if(isRightSeatFree() && thePawn.canSit()):
			result.append(InteractAction.create(
				"sitRight", "Sit (right)",
			))
	
	if(!isLeftSeatFree() && !isRightSeatFree() && (isSittingOnLeft || isSittingOnRight)):
		if(!isCuddling):
			result.append(InteractAction.create(
				"cuddle", "Cuddle!",
			))
		else:
			result.append(InteractAction.create(
				"stopCuddle", "Stop cuddling",
			))
	
	return result

func _on_interactable_on_interact(user: DollController, action: InteractAction) -> void:
	if(action.id == "sitLeft"):
		if(!sit_spawner_left.isSpawned()):
			sit_spawner_left.spawn()
		sit_spawner_left.setSitter("dom", user.getPawn())
	if(action.id == "sitRight"):
		if(!sit_spawner_right.isSpawned()):
			sit_spawner_right.spawn()
		sit_spawner_right.setSitter("dom", user.getPawn())
	if(action.id == "unsit"):
		var thePawn:CharacterPawn = user.getPawn()
		if(!thePawn):
			return
		if(isPawnSittingLeft(thePawn) || isPawnSittingRight(thePawn)):
			sit_spawner_cuddle.despawn()
			sit_spawner_left.despawn()
			sit_spawner_right.despawn()
			
	if(action.id == "cuddle"):
		var leftSitter:CharacterPawn = sit_spawner_left.getSitter("dom")
		var rightSitter:CharacterPawn = sit_spawner_right.getSitter("dom")
		sit_spawner_left.despawn()
		sit_spawner_right.despawn()
		sit_spawner_cuddle.spawn()
		sit_spawner_cuddle.setSitter("dom", leftSitter)
		sit_spawner_cuddle.setSitter("sub", rightSitter)
	if(action.id == "stopCuddle"):
		var leftSitter:CharacterPawn = sit_spawner_cuddle.getSitter("dom")
		var rightSitter:CharacterPawn = sit_spawner_cuddle.getSitter("sub")
		sit_spawner_cuddle.despawn()
		sit_spawner_left.spawn()
		sit_spawner_right.spawn()
		sit_spawner_left.setSitter("dom", leftSitter)
		sit_spawner_right.setSitter("dom", rightSitter)
	
func saveNetworkData() -> Dictionary:
	return {
		left = sit_spawner_left.saveNetworkedData(),
		right = sit_spawner_right.saveNetworkedData(),
		cuddle = sit_spawner_cuddle.saveNetworkedData(),
	}

func loadNetworkData(_data:Dictionary):
	sit_spawner_left.loadNetworkData(SAVE.loadVar(_data, "left", {}))
	sit_spawner_right.loadNetworkData(SAVE.loadVar(_data, "right", {}))
	sit_spawner_cuddle.loadNetworkData(SAVE.loadVar(_data, "cuddle", {}))
