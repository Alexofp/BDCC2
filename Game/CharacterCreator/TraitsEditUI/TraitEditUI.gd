extends VBoxContainer

@onready var search_line_edit: LineEdit = %SearchLineEdit
@onready var trait_list: VBoxContainer = %TraitList
@onready var randomize_button: Button = %RandomizeButton

const TRAIT_ENTRY_UI = preload("res://Game/CharacterCreator/TraitsEditUI/TraitEntryUI.tscn")
var traitEntries:Array
var holder:TraitHolder = TraitHolder.new()
var search:FuzzySearch = FuzzySearch.new()

signal onRandomizePressed

@export var showRandomize:bool = true

func _ready() -> void:
	randomize_button.visible = showRandomize

func setTraits(_holder:TraitHolder):
	holder.loadData(_holder.saveData().duplicate(true))
	holder.charRef = _holder.charRef
	updateList()

func filterTraitIDs() -> Array:
	var _searchText:String = search_line_edit.text
	if(_searchText.is_empty()):
		return GlobalRegistry.traits.keys()
	var _ar:Array[String]
	var _traitKeys:Array = GlobalRegistry.traits.keys()
	for _traitID:String in _traitKeys:
		var theTrait:TraitBase = GlobalRegistry.traits[_traitID]
		_ar.append(theTrait.getName())
	var _result:Array[FuzzySearchMatch] = search.search_all(_searchText, _ar)
	var _res:Array = []
	for _entry:FuzzySearchMatch in _result:
		_res.append(_traitKeys[_entry.original_index])
	return _res

func updateList():
	Util.delete_children(trait_list)
	traitEntries.clear()
	
	for _traitID:String in filterTraitIDs():
		var theTrait:TraitBase = GlobalRegistry.traits[_traitID]
		var _hasTrait:bool = holder.hasTrait(theTrait.id)
		
		var newEntry = TRAIT_ENTRY_UI.instantiate()
		trait_list.add_child(newEntry)
		traitEntries.append(newEntry)
		newEntry.setTrait(theTrait, _hasTrait)
		newEntry.onTraitToggle.connect(onTraitToggle.bind(newEntry))
	updateDisabled()

func onTraitToggle(_trait:TraitBase, _enabled:bool, _traitEntry):
	if(_enabled):
		holder.addTrait(_trait.id)
	else:
		holder.removeTrait(_trait.id)
	_traitEntry.setEnabled(holder.hasTrait(_trait.id))
	updateDisabled()

func updateDisabled():
	for _traitEntry in traitEntries:
		var theTrait:TraitBase = _traitEntry.cachedTrait
		if(holder.hasTrait(theTrait.id) || holder.canTraitRefBeAdded(theTrait)):
			_traitEntry.setDisabled(false)
		else:
			_traitEntry.setDisabled(true)

func _on_randomize_button_pressed() -> void:
	onRandomizePressed.emit()

func _on_search_line_edit_text_changed(_new_text: String) -> void:
	updateList()
