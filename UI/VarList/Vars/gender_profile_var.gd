extends VarUIBase

var genderProfile:GenderPronounsProfile = GenderPronounsProfile.new()
@onready var gender_selector: OptionButton = %GenderSelector
@onready var pronouns_selector: OptionButton = %PronounsSelector

func _ready() -> void:
	gender_selector.clear()
	for gender in Gender.getAll():
		gender_selector.add_item(Gender.getName(gender))
	pronouns_selector.clear()
	for pronouns in Pronouns.getAll():
		pronouns_selector.add_item(Pronouns.getName(pronouns))

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		genderProfile.loadData(_data["value"].duplicate(true))
		
		var _i := 0
		for gender in Gender.getAll():
			if(gender == genderProfile.gender):
				gender_selector.select(_i)
				break
			_i += 1
		_i = 0
		for pronouns in Pronouns.getAll():
			if(pronouns == genderProfile.pronouns):
				pronouns_selector.select(_i)
				break
			_i += 1

func _on_gender_selector_item_selected(index: int) -> void:
	if(index < 0 || index >= Gender.getAll().size()):
		return
	genderProfile.gender = Gender.getAll()[index]
	triggerChange(genderProfile.saveData().duplicate(true))

func _on_pronouns_selector_item_selected(index: int) -> void:
	if(index < 0 || index >= Pronouns.getAll().size()):
		return
	genderProfile.pronouns = Pronouns.getAll()[index]
	triggerChange(genderProfile.saveData().duplicate(true))
