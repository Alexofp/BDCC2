extends ClothingBase

func _init():
	super._init()
	
	id = "TestBra"

func getItemSlots() -> Array:
	return [InventorySlot.UnderwearTop]

func getMeshStructure(_baseCharacter: BaseCharacter) -> Dictionary:
	return {
		"hat": {
			"attachTo": [],
			"attachSlot": "",
			"path": "res://Mesh/Clothing/TestBra/test_bra.tscn",
		}
	}

func getOptions() -> Dictionary:
	return {
		"raised": {
			"name": "Pulled up",
			"type": "checkbox",
			"default": false,
			#"menu": ["skin"],
		},
	}

func checkOptionChanged(_valueID, _oldValue, _newValue):
	super.checkOptionChanged(_valueID, _oldValue, _newValue)
	
	if(_valueID == "raised"):
		updateCharacterPartTags()

func getPartTags() -> Dictionary:
	if(getOptionValue("raised", false)):
		return {}
	return {
		PartTag.Body_HideNipples: true,
		PartTag.Body_MinimalBreastJiggle: true,
	}

# I Think I have to create a class that has all of the common functions for the part with options

#func getOptionValue(_valueID: String, defaultValue = null):
#	return super.getOptionValue(_valueID, defaultValue)


#func setOptionValue(valueID: String, value):
#	print("TRYING TO SET "+str(valueID)+" TO VALUE: "+str(value))
