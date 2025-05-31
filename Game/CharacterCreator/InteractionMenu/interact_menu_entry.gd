extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var interact_var_list: VarList = %InteractVarList

func setName(_name:String):
	name_label.text = _name

func getVarList() -> VarList:
	return interact_var_list
