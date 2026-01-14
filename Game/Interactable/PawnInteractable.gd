extends Area3D
class_name PawnInteractable

var target:Node

var foundGetInteractCategoryFunc:bool = false
var foundGetQuickInteractActionsFunc:bool = false

#Example
#func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	#var category := InteractCategory.new()
	#category.categoryName = categoryName
	#category.interactEntries.append(InteractEntryDo.create("SitProp", ["dom",]))
	#return category
#func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	#var result:Array[InteractEntryDo] = []
	#result.append(InteractEntryDo.create("SitProp", ["dom",]))
	#return result

func setTarget(_target:Node):
	target = _target
	
	if(target):
		foundGetInteractCategoryFunc = target.has_method("getInteractCategory")
		foundGetQuickInteractActionsFunc = target.has_method("getQuickInteractActions")
	else:
		foundGetInteractCategoryFunc = false
		foundGetQuickInteractActionsFunc = false

func getInteractEntryCategory(_pawn:CharacterPawn) -> InteractCategory:
	if(!target || !foundGetInteractCategoryFunc):
		return null
	
	var theCategory:InteractCategory = target.getInteractCategory(_pawn)
	if(!theCategory):
		return null
	theCategory.target = target
	return theCategory

func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	if(!target || !foundGetQuickInteractActionsFunc):
		return []
	
	return target.getQuickInteractActions(_pawn)
