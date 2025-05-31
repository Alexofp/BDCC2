extends VarUIBase

var species:SpeciesProfile = SpeciesProfile.new()
var mainSpecies:Array = []
var secondarySpecies:Array = []

@onready var species_selector: OptionButton = %SpeciesSelector
@onready var second_species_selector: OptionButton = %SecondSpeciesSelector
@onready var hybrid_check_box: CheckBox = %HybridCheckBox
@onready var hybrid_h_box: HBoxContainer = %HybridHBox

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		species.loadData(_data["value"].duplicate(true))
		
	updateValue()
		
func updateValue():
	species_selector.clear()
	mainSpecies = []
	var _i:int = 0
	for speciesID in GlobalRegistry.getSpeciesAll():
		var theSpecies:SpeciesBase = GlobalRegistry.getSpecies(speciesID)
		species_selector.add_item(theSpecies.getName())
		if(speciesID == species.getMainSpeciesID()):
			species_selector.select(_i)
		mainSpecies.append(speciesID)
		_i += 1

	second_species_selector.clear()
	if(species.isHybrid()):
		hybrid_check_box.set_pressed_no_signal(true)
		hybrid_h_box.visible = true
		
	secondarySpecies = []
	_i = 0
	for speciesID in ([""]+GlobalRegistry.getSpeciesAll().keys()):
		if(speciesID == species.getMainSpeciesID()):
			continue
		if(speciesID == ""):
			second_species_selector.add_item("- Nothing -")
			secondarySpecies.append("")
		else:
			var theSpecies:SpeciesBase = GlobalRegistry.getSpecies(speciesID)
			second_species_selector.add_item(theSpecies.getName())
			secondarySpecies.append(speciesID)
		if(speciesID == species.getSecondarySpeciesID()):
			second_species_selector.select(_i)
		_i += 1

func _on_hybrid_check_box_pressed() -> void:
	hybrid_h_box.visible = hybrid_check_box.button_pressed
	
	if(!hybrid_check_box.button_pressed):
		species.setSecondarySpecies("")
		triggerChange(species.saveData().duplicate(true))
	
	updateValue()

func _on_species_selector_item_selected(index: int) -> void:
	if(index < 0 || index >= mainSpecies.size()):
		return
	species.setMainSpecies(mainSpecies[index])
	triggerChange(species.saveData().duplicate(true))
	updateValue()

func _on_second_species_selector_item_selected(index: int) -> void:
	if(index < 0 || index >= secondarySpecies.size()):
		return
	species.setSecondarySpecies(secondarySpecies[index])
	triggerChange(species.saveData().duplicate(true))
	updateValue()
