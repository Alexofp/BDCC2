extends VBoxContainer

var skinTypes:SkinTypeProfile

var skinTypeToLabel:Dictionary[int, Label] = {}
var skinTypeToColorPicker:Dictionary[int, ColorPickerButton] = {}

signal onColorChange(skinType:int, color:Color)

func setProfile(theProfile:SkinTypeProfile):
	if(skinTypes):
		skinTypes.skinTypeChanged.disconnect(onSkinTypeChanged)
	skinTypes = theProfile
	if(skinTypes):
		skinTypes.skinTypeChanged.connect(onSkinTypeChanged)
	updateList()

func onSkinTypeChanged(_skinType, _skinTypeData):
	updateList()

func updateList():
	if(!skinTypes):
		for skinType in skinTypeToLabel.keys():
			skinTypeToLabel[skinType].queue_free()
			skinTypeToLabel.erase(skinType)
		for skinType in skinTypeToColorPicker.keys():
			skinTypeToColorPicker[skinType].queue_free()
			skinTypeToColorPicker.erase(skinType)
		return
	
	for skinType in skinTypeToLabel.keys():
		if(!skinTypes.hasSkinType(skinType)):
			skinTypeToLabel[skinType].queue_free()
			skinTypeToLabel.erase(skinType)
			skinTypeToColorPicker[skinType].queue_free()
			skinTypeToColorPicker.erase(skinType)
	
	for skinType in skinTypes.skinTypes:
		if(!skinTypeToColorPicker.has(skinType)):
			var skinTypeData:SkinTypeData = skinTypes.getSkinType(skinType)
			var skinTypeName:String = SkinType.getName(skinType)
			
			var theLabel:Label = Label.new()
			skinTypeToLabel[skinType] = theLabel
			add_child(theLabel)
			theLabel.text = skinTypeName

			var theColorPicker:ColorPickerButton = ColorPickerButton.new()
			skinTypeToColorPicker[skinType] = theColorPicker
			add_child(theColorPicker)
			theColorPicker.color = skinTypeData.color
			theColorPicker.custom_minimum_size.y = 30.0
			
			theColorPicker.color_changed.connect(changeSkinTypeDataColor.bind(skinType))
		else:
			var skinTypeData:SkinTypeData = skinTypes.getSkinType(skinType)
			var theColorPicker := skinTypeToColorPicker[skinType]
			if(theColorPicker.color != skinTypeData.color):
				theColorPicker.color = skinTypeData.color
		
func changeSkinTypeDataColor(_color:Color, _skinType:int):
	#if(skinTypes):
	#	skinTypes.setColor(_skinType, _color)
	onColorChange.emit(_skinType, _color)
