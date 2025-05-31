extends ConfirmationDialog

signal onWizardSubmit(window, data)
signal onCancel(window)
signal onWizardChange(data)

@onready var char_wizard_var_list: VarList = %CharWizardVarList

var charName:String = "New character"
var gender:GenderPronounsProfile = GenderPronounsProfile.new()
var species:SpeciesProfile = SpeciesProfile.new()

func _on_canceled() -> void:
	onCancel.emit(self)

func _ready() -> void:
	pass

func updateData():
	char_wizard_var_list.setVars({
		CharOption.name: {
			name = "Name",
			type = "stringWindow",
			value = charName,
			charNameFilter = true,
		},
		CharOption.gender: {
			name = "Gender",
			type = "genderProfile",
			value = gender.saveData(),
		},
		CharOption.species: {
			name = "Species",
			type = "speciesProfile",
			value = species.saveData(),
		},
	})

func _on_char_wizard_var_list_on_var_change(id: String, value: Variant) -> void:
	if(id == CharOption.name):
		charName = value
	if(id == CharOption.gender):
		gender.loadData(value)
	if(id == CharOption.species):
		species.loadData(value)
	
	if(onWizardChange.has_connections()):
		onWizardChange.emit(getData())

func _on_confirmed() -> void:
	onWizardSubmit.emit(self, getData())

func getData() -> Dictionary:
	return {
		charName = charName,
		gender = gender.saveData().duplicate(true),
		species = species.saveData().duplicate(true),
	}

func setData(_data:Dictionary):
	if(_data.has("charName")):
		charName = _data["charName"]
	if(_data.has("gender")):
		gender.loadData(_data["gender"].duplicate(true))
	if(_data.has("species")):
		species.loadData(_data["species"].duplicate(true))
	
	updateData()
