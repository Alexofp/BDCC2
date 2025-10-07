extends RigidBody3D

var inventory:Inventory = Inventory.new()
@onready var interactable: Interactable = %Interactable

func _init() -> void:
	inventory.register()

func _exit_tree() -> void:
	inventory.unregister()

func _ready() -> void:
	interactable.dynamicActionsFunc = getActions

func getActions(_interactor:Interactor, _user:DollController) -> Array[InteractAction]:
	if(!_user):
		return []
	var thePawn:CharacterPawn = _user.getPawn()
	if(!thePawn):
		return []
	
	var result:Array[InteractAction] = []
	
	result.append(InteractAction.create("pickUp", "Pick up "+inventory.getPickupName()))
	
	return result

func _on_interactable_on_interact(_user: DollController, _action: InteractAction) -> void:
	if(_action.id == "pickUp"):
		var theCharacter := _user.getCharacter()
		if(!theCharacter):
			return
		while(!inventory.items.is_empty()):
			var theItem:ItemBase = inventory.items.front()
			inventory.removeItem(theItem)
			theCharacter.inventory.addItem(theItem)
		queue_free()

func saveData() -> Dictionary:
	return {
		inventory = inventory.saveData(),
	}

func loadData(_data:Dictionary):
	inventory.loadData(SAVE.loadVar(_data, "inventory", {}))
