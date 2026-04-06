extends Node3D
class_name PropHandlerBase

func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	var category := InteractCategory.new()
	
	category.categoryName = "Prop"
	#category.interactEntries.append(InteractEntryDo.create("SitProp", ["dom"]))
	#category.interactEntries.append_array(getQuickInteractActions(_pawn))
	
	return category

func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	#result.append(InteractEntryDo.create("SitProp", ["dom",]))
	return result

func getGenericActionName(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> String:
	return "ERROR!"

func canDoGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	return true

func doGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	return true

func canDoGenericDelayedAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	return canDoGenericAction(_id, _args, _context, _action)

func doGenericDelayedAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	return true

func getAllSitterSlots() -> Array[String]:
	return []

func getAllFreeSitterSlots() -> Array[String]:
	var theSlots := getAllSitterSlots()
	var result:Array[String]
	
	for theSlot in theSlots:
		if(!getSitterSlot(theSlot)):
			result.append(theSlot)
	
	return result

func canUseSitterSlot(_slot:String) -> bool:
	return true

func canGetUpFromSlot(_slot:String) -> bool:
	return true

func getSitterSlot(_slot:String) -> CharacterPawn:
	#return sit_spawner.getSitter(_slot)
	return null

func getSlotOfPawn(_pawn:CharacterPawn) -> String:
	for theSlot in getAllSitterSlots():
		if(getSitterSlot(theSlot) == _pawn):
			return theSlot
	return ""

func setSitter(_slot:String, _pawn:CharacterPawn) -> bool:
	#if(!_pawn):
		#sit_spawner.despawn()
		#return true
	#if(!sit_spawner.isSpawned()):
		#sit_spawner.spawn()
		##sit_spawner.setProp("stocks", stocks)
	#sit_spawner.setSitter(_slot, _pawn)
	return false

# pawns should be in the order of importance [main, target, extra1, extra2, etc]
# returns {sexType=SexType.AgainstWall, roles={dom=pawn1,sub=pawn2}, pos=vec3, ang=vec3}
# returns {} if no support
func getSexStartInfo(_pawns:Array[CharacterPawn]) -> Dictionary:
	return {}

func createSexStartInfo(_sexType:String, _roles:Dictionary[String, CharacterPawn], _pos:Vector3, _ang:Vector3) -> Dictionary:
	return {
		sexType = _sexType,
		roles = _roles,
		pos = _pos,
		ang = _ang,
	}

func canStartSexOnProp(_pawns:Array[CharacterPawn]) -> bool:
	return !getSexStartInfo(_pawns).is_empty()
