extends RigidBody3D

var inventory:Inventory = Inventory.new()
@onready var pawn_interactable: PawnInteractable = %PawnInteractable

func _init() -> void:
	inventory.register()

func _exit_tree() -> void:
	inventory.unregister()

func _ready() -> void:
	pawn_interactable.setTarget(self)

func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	var category := InteractCategory.new()
	category.categoryName = inventory.getPickupName()#"Dropped item"
	category.interactEntries.append(InteractEntryDo.create("ItemPickUp"))
	return category

func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	result.append(InteractEntryDo.create("ItemPickUp"))
	return result

func saveData() -> Dictionary:
	return {
		inventory = inventory.saveData(),
	}

func loadData(_data:Dictionary):
	inventory.loadData(SAVE.loadVar(_data, "inventory", {}))
