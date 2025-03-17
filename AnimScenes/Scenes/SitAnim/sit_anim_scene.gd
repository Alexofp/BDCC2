extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var stand_spot: Marker3D = %StandSpot
@onready var interactable: Interactable = %Interactable
@onready var animation_tree: AnimationTree = %AnimationTree

func updateInteractable():
	interactable.actions[0].hidden = sit_spot.hasSitter()
	interactable.actions[0].disabled = sit_spot.hasSitter()
	interactable.actions[1].hidden = !sit_spot.hasSitter()
	interactable.actions[1].allowedUsers = [sit_spot.getSitterPawn()] if sit_spot.hasSitter() else []

func _ready():
	updateInteractable()
	pass
	
	#var someUniqueID:=GameInteractor.getUniqueIDOf(self)
	#print(someUniqueID)
	#print(GameInteractor.getNodeByUniqueID(someUniqueID))
	

func _on_interactable_on_interact(user: DollController, action: InteractAction) -> void:
	if(action.id == "sit"):
		if(sit_spot.hasSitter()):
			return
		sit_spot.doSitDoll(user)
		#updateAnim()
		#user.playSitAnim()
		#var someUniqueID:=GameInteractor.getUniqueIDOf(self)
		#print(someUniqueID)
		#print(GameInteractor.getNodeByUniqueID(someUniqueID))
	if(action.id == "unsit"):
		if(sit_spot.getSitterDoll() == user):
			sit_spot.unSit()
			user.global_position = stand_spot.global_position
			#animation_tree.active = false
			#animation_tree.root_node = NodePath("")
	
	updateInteractable()

func _on_sit_spot_on_doll_switch(_newDoll: Variant) -> void:
	Log.Print("NEW DOLL "+str(_newDoll))
	updateAnim()

func updateAnim():
	var sitDoll:DollController = sit_spot.getSitterDoll()
	
	if(sitDoll):
		applyAnimPlayer(sitDoll, animation_tree)
		animation_tree.active = true
	else:
		animation_tree.active = false
		animation_tree.root_node = NodePath("")

func _on_sit_spot_on_pawn_switch(_newPawn: Variant) -> void:
	updateInteractable()
