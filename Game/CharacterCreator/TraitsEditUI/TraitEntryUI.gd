extends HBoxContainer

@onready var trait_name: CheckBox = %TraitName
@onready var trait_desc: Label = %TraitDesc

var cachedTrait:TraitBase

signal onTraitToggle(_trait:TraitBase, _enabled:bool)

func setTrait(_trait:TraitBase, _enabled:bool):
	cachedTrait = _trait
	
	trait_name.set_pressed_no_signal(_enabled)
	trait_name.text = _trait.getName()
	trait_desc.text = _trait.getDescription()

func setEnabled(_b:bool):
	trait_name.set_pressed_no_signal(_b)

func setDisabled(_d:bool):
	trait_name.disabled = _d

func _on_trait_name_pressed() -> void:
	onTraitToggle.emit(cachedTrait, trait_name.button_pressed)
