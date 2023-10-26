extends VBoxContainer

var isOpened:bool = false

func _ready():
	updateOpened()

func updateOpened():
	$PanelContainer.visible = isOpened
	if(isOpened):
		$Panel/HBoxContainer/Label.text = "V"
	else:
		$Panel/HBoxContainer/Label.text = ">"

func _on_open_group_button_pressed():
	isOpened = !isOpened
	updateOpened()

func setOpened(theOpened):
	isOpened = theOpened
	updateOpened()

func addNewElement(theElement:Node):
	$PanelContainer/VBoxContainer.add_child(theElement)

func setLabel(newText):
	$Panel/HBoxContainer/Label2.text = newText
