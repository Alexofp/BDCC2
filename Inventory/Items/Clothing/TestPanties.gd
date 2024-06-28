extends ClothingBase

func _init():
	super._init()
	
	id = "TestPanties"

func getItemSlots() -> Array:
	return [InventorySlot.UnderwearBottom]

func getMeshStructure(_baseCharacter: BaseCharacter) -> Dictionary:
	return {
		"hat": {
			"attachTo": [],
			"attachSlot": "",
			"path": "res://Mesh/Clothing/TestPanties/test_panties.tscn",
		}
	}

func getOptions() -> Dictionary:
	return {
		"shiftedAside": {
			"name": "Shifted aside",
			"type": "checkbox",
			"default": false,
			#"menu": ["skin"],
		},
	}

# I Think I have to create a class that has all of the common functions for the part with options

#func getOptionValue(_valueID: String, defaultValue = null):
#	return super.getOptionValue(_valueID, defaultValue)


#func setOptionValue(valueID: String, value):
#	print("TRYING TO SET "+str(valueID)+" TO VALUE: "+str(value))
