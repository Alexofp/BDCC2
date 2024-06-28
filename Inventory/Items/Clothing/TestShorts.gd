extends ClothingBase

func _init():
	super._init()
	
	id = "TestShorts"

func getItemSlots() -> Array:
	return [InventorySlot.Legs]

func getMeshStructure(_baseCharacter: BaseCharacter) -> Dictionary:
	return {
		"hat": {
			"attachTo": [],
			"attachSlot": "",
			"path": "res://Mesh/Clothing/TestShorts/test_shorts.tscn",
		}
	}

func getOptions() -> Dictionary:
	return {
		"pulledDown": {
			"name": "Pulled down",
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
