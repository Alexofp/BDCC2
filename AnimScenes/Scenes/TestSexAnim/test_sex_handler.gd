extends Node3D

@onready var anim_scene_spawner: AnimSceneSpawner = %AnimSceneSpawner
@onready var interactable: Interactable = %Interactable
@export var isVag:bool = true: set = onIsVagSet
var state:String = "tease"

func onIsVagSet(_newIsVag:bool):
	isVag = _newIsVag
	playStateLocal()

func _ready():
	interactable.dynamicActionsFunc = getActions
	updatePoseballs()

func getActions(_interactor:Interactor, _user:DollController) -> Array[InteractAction]:
	if(!_user):
		return []
	var thePawn:CharacterPawn = _user.getPawn()
	if(!thePawn):
		return []
	var result:Array[InteractAction] = []
	
	if(thePawn.canSit()):
		if(!anim_scene_spawner.hasSitter("dom")):
			result.append(InteractAction.create(
				"joinTop", "Join (Top)"
			))
		if(!anim_scene_spawner.hasSitter("sub")):
			result.append(InteractAction.create(
				"joinBottom", "Join (Bottom)"
			))
	
	if(anim_scene_spawner.getSitter("dom") == thePawn || anim_scene_spawner.getSitter("sub") == thePawn):
		result.append(InteractAction.create(
			"unsit", "Stop"
		))
		result.append(InteractAction.create(
			"switchHole", ("Vaginal" if !isVag else "Anal"),
		))
		if(state == "tease"):
			result.append(InteractAction.create(
				"sex", "Sex"
			))
		else:
			result.append(InteractAction.create(
				"tease", "Tease"
			))
	
	return result

func _on_interactable_on_interact(user: DollController, action: InteractAction) -> void:
	var thePawn := user.getPawn()
	
	if(action.id == "unsit"):
		anim_scene_spawner.despawn()
		queue_free()
	if(action.id == "joinTop"):
		anim_scene_spawner.spawn()
		anim_scene_spawner.getScene().setSitter("dom", thePawn)
	if(action.id == "joinBottom"):
		anim_scene_spawner.spawn()
		anim_scene_spawner.getScene().setSitter("sub", thePawn)
	if(action.id == "switchHole"):
		isVag = !isVag
		
		#if(!isVag):
		#	anim_scene_spawner.getScene().playState("sex")
		#else:
		#	anim_scene_spawner.getScene().playState("tease")
	if(action.id == "sex"):
		playState("sex")
	if(action.id == "tease"):
		playState("tease")
		
func playStateLocal(resetAnim:bool = false):
	if(anim_scene_spawner.isSpawned()):
		anim_scene_spawner.getScene().playState(state, resetAnim)
		anim_scene_spawner.getScene().alignPenisToSitterHole("dom", "sub", AnimSceneBase.HOLE_VAGINA if isVag else AnimSceneBase.HOLE_ANUS)

func playState(theState:String, resetAnim:bool = false):
	state = theState
	playStateLocal(resetAnim)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(playState_RPC, [state, resetAnim])

@rpc("authority", "call_remote", "reliable")
func playState_RPC(theState:String, resetAnim:bool = false):
	playState(theState, resetAnim)

func saveNetworkData() -> Dictionary:
	return {
		anim = anim_scene_spawner.saveNetworkedData(),
		isVag = isVag,
		state = state,
	}

func loadNetworkData(_data:Dictionary):
	anim_scene_spawner.loadNetworkData(SAVE.loadVar(_data, "anim", {}))
	isVag = SAVE.loadVar(_data, "isVag", true)
	state = SAVE.loadVar(_data, "state", "tease")
	playStateLocal(true)

@onready var ball_top: MeshInstance3D = %BallTop
@onready var ball_bottom: MeshInstance3D = %BallBottom

func updatePoseballs():
	ball_top.visible = !anim_scene_spawner.hasSitter("dom")
	ball_bottom.visible = !anim_scene_spawner.hasSitter("sub")

func _on_anim_scene_spawner_on_spawned_changed(_isSpawned: Variant) -> void:
	updatePoseballs()
	playStateLocal(true)

func _on_anim_scene_spawner_on_doll_switch(_id: String, _doll: DollController) -> void:
	updatePoseballs()
