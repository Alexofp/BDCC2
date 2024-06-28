extends ClothingBase

func _init():
	super._init()
	
	id = "TestShirt"

func getItemSlots() -> Array:
	return [InventorySlot.Chest]

func getMeshStructure(_baseCharacter: BaseCharacter) -> Dictionary:
	return {
		"hat": {
			"attachTo": [],
			"attachSlot": "",
			"path": "res://Mesh/Clothing/TestShirt/test_shirt.tscn",
		}
	}

func getOptions() -> Dictionary:
	return {
		"opened": {
			"name": "Opened",
			"type": "checkbox",
			"default": false,
			#"menu": ["skin"],
		},
	}

func checkOptionChanged(_valueID, _oldValue, _newValue):
	super.checkOptionChanged(_valueID, _oldValue, _newValue)
	
	if(_valueID == "opened"):
		updateCharacterPartTags()

func getPartTags() -> Dictionary:
	if(getOptionValue("opened", false)):
		return {}
	return {
		PartTag.Body_HideNipples: true,
		PartTag.Body_MinimalBreastJiggle: true,
	}
