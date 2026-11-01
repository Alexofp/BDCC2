extends CharacterTypeBase

func _init() -> void:
	id = CharacterType.InmateGeneral

	inmate = true
	staff = false
	allowPickAsPlayer = true
	colorMain = Color("ff6600")

func getName() -> String:
	return "Inmate (General)"

func giveDefaultClothes(_char:BaseCharacter):
	if(_char.gender.getGender() != Gender.Male):
		var theTop:ItemBase = GlobalRegistry.createItem("InmateTop")
		theTop.recolorForCharacterType(self)
		_char.inventory.equipItem(theTop, InventorySlot.Top)
	else:
		var theTop:ItemBase = GlobalRegistry.createItem("InmateTankTop")
		theTop.recolorForCharacterType(self)
		_char.inventory.equipItem(theTop, InventorySlot.Top)
	var theShorts:ItemBase = GlobalRegistry.createItem("InmateShorts")
	theShorts.recolorForCharacterType(self)
	_char.inventory.equipItem(theShorts, InventorySlot.Bottom)
	_char.inventory.equipItem(GlobalRegistry.createItem("InmateCollar"), InventorySlot.Collar)
