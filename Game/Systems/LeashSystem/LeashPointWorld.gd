extends LeashPoint

@onready var pawn_interactable: PawnInteractable = %PawnInteractable

func _ready() -> void:
	super._ready()
	
	pawn_interactable.setTarget(self)

func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	var category := InteractCategory.new()
	category.categoryName = leashPointName
	
	var theLeashes := GM.leashSystem.getAllLeashesOfSourceNode(_pawn)
	for theLeash in theLeashes:
		if(!theLeash.isTargetAPawn()):
			continue
		# Filter out leashes that aren't connected to source's hands?
		var theCon := theLeash.p2con
		var targetPointName:String = theCon.pawn.getCharacter().getName()+"'s "+theCon.pawn.getDollLeashPointName(theCon.pawnLeashPoint)
		
		category.interactEntries.append(InteractEntryDo.create("LeashToWorldPoint", [theLeash.p1con.pawnLeashPoint, theCon.pawn.getCharID(), theCon.pawnLeashPoint, targetPointName]))
	
	var ourLeashes := GM.leashSystem.getAllLeashesOfSourceNode(self)
	for theLeash in ourLeashes:
		if(!theLeash.isTargetAPawn()):
			continue
		var theCon := theLeash.p2con
		var targetPointName:String = theCon.pawn.getCharacter().getName()+"'s "+theCon.pawn.getDollLeashPointName(theCon.pawnLeashPoint)
		
		category.interactEntries.append(InteractEntryDo.create("LeashUnleashWorldPoint", ["", theCon.pawn.getCharID(), theCon.pawnLeashPoint, targetPointName]))
		category.interactEntries.append(InteractEntryDo.create("LeashGrabWorldPoint", ["", theCon.pawn.getCharID(), theCon.pawnLeashPoint, targetPointName]))
	
	return category
#func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	#var result:Array[InteractEntryDo] = []
	#result.append(InteractEntryDo.create("SitProp", ["dom",]))
	#return result
