extends VarUIBase

@onready var color_picker_button: ColorPickerButton = $HBoxContainer/VBoxContainer/ColorPickerButton
@onready var palette_box: HFlowContainer = $HBoxContainer/VBoxContainer/PaletteBox

var addBDCC:bool = false
const BDCCColor := [
	Color("868686"), # Grays
	Color("6e6e6e"),
	Color("353535"),
	
	Color("e8e8e8"), # White and black
	Color("202020"),
	
	Color("b57017"), # General/High/Lilac
	Color("cd1a12"),
	Color("9857c1"),
	
	Color("2944be"), # BDCC blue
	Color("7bd12c"), # Yellowgreen
]

var addBasic:bool = false
const BasicColor := [
	Color.BLACK, Color.WHITE, Color.DARK_GRAY, Color.RED, Color.BLUE, Color.GREEN, Color.ORANGE, Color.PURPLE,
]

var addLight:bool = false
const LightColor := [
	Color("FFFC00"),
	Color("fffea4"),
	Color("00E0FF"),
	Color("0079FF"),
	Color("FF0000"),
	Color("FF5B00"),
	Color("00FF15"),
	Color("70FF00"),
	Color("FFFFFF"),
	Color("E700FF"),
	Color("8585FF"),
	Color("FF7FBB"),
	Color("AF00FF"),
	Color("FFAE00"),
]

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("alpha")):
		color_picker_button.edit_alpha = _data["alpha"]
	if(_data.has("value")):
		color_picker_button.color = _data["value"]
	if(_data.has("BDCC")):
		addBDCC = _data["BDCC"]
	if(_data.has("basic")):
		addBasic = _data["basic"]
	if(_data.has("light")):
		addLight = _data["light"]
		
	if(_data.has("palette")):
		setPalette(_data["palette"].duplicate(true))
	else:
		setPalette([])

func _on_color_picker_button_color_changed(color: Color) -> void:
	triggerChange(color)

func setPalette(newColors:Array):
	if(addBDCC):
		newColors.append_array(BDCCColor)
	if(addLight):
		newColors.append_array(LightColor)
	if(addBasic):
		newColors.append_array(BasicColor)
	
	for children in palette_box.get_children():
		children.queue_free()
	
	for theColor in newColors:
		var newButton:Button = Button.new()
		newButton.flat = true
		newButton.icon = preload("res://UI/VarList/Images/white20.png")
		newButton.modulate = theColor
		newButton.pressed.connect(onPaletteButtonPressed.bind(theColor))
		palette_box.add_child(newButton)

func onPaletteButtonPressed(theColor:Color):
	color_picker_button.color = theColor
	_on_color_picker_button_color_changed(theColor)
