extends Node3D

@onready var interactable: Interactable = %Interactable

func _ready() -> void:
	interactable.dynamicActionsFunc = getActions

func getActions(_interactor:Interactor, _user:DollController) -> Array[InteractAction]:
	if(!_user):
		return []
	var thePawn:CharacterPawn = _user.getPawn()
	if(!thePawn):
		return []
	
	var result:Array[InteractAction] = []
	
	result.append(InteractAction.create("openUI", "Get any item menu"))
	
	return result

func _on_interactable_on_interact(_user: DollController, _action: InteractAction) -> void:
	if(_action.id == "openUI"):
		var nid := _user.getNetworkPlayerID()
		if(nid < 0):
			return
		GM.NetNodes.sendGlobalEvent(self, "openUI", [nid])
		# get player net id from the doll controller
		# send a rpc (or a local call if we are the server) to open the menu. RPC how?
		# That rpc contains this object?
		# The player presses a button to get some item
		# This sends an RPC to a server (or a local call) to this object
		# This object checks if the player is 'allowed' to get an item and gives them if they do
		# This (automatically) syncs everything
		pass

func handleGlobalEvent(_id:String, _args:Array):
	pass
