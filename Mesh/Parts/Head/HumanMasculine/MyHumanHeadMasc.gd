extends "res://Mesh/Parts/Head/HumanFeminine/my_human_head.gd"

func _init() -> void:
	headColorMaskBase = "res://Mesh/Parts/Head/HumanMasculine/Textures/HumanSkin/HeadMale_low_Material_BaseColor.png"

func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["HumanNeck"] = true
	_theFlags["HumanNeckMale"] = true
	_theFlags["ThinHead"] = 1.0
	
func updateHeadTexture():
	updatingHeadTexture = false
	var theSkinData:SkinTypeData = getSkinData()
	if(theSkinData == null):
		return
	
	head_layered_texture.clearLayers()
	
	if(true):
		head_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/skinwhite.png", theSkinData.color)
		var colorR:Color = theSkinData.color
		colorR = colorR.lerp(Color("D3635D"), theSkinData.color.v)
		#colorR.h = 0.008
		#colorR.s = 0.559
		#colorR.v = 0.827
		var colorG:Color = theSkinData.color
		colorG = colorG.lerp(Color("9A3B67"), theSkinData.color.v)
		#colorG.h = 0.922
		#colorG.s = 0.616
		#colorG.v = 0.603
		var colorB:Color = theSkinData.color
		colorB = colorB.lerp(Color("CEA8A3"), theSkinData.color.v)
		#colorB.h = 0.019
		#colorB.s = 0.209
		#colorB.v = 0.808

		head_layered_texture.addColorMaskLayer(headColorMaskBase, colorR, colorG, colorB)
	
	addLayersToTexture(head_layered_texture, getOptionValue("headLayers", []))
	
	var theBeardArray:Array = getOptionValue("beard", [])
	var theBeard:String = theBeardArray[0] if theBeardArray.size() > 0 else ""
	if(theBeard == "b1"):
		var theCol:Color = theBeardArray[1] if theBeardArray.size() > 1 else Color.BLACK
		theCol.a *= 0.8
		head_layered_texture.addColorMaskLayer("res://Mesh/Parts/Head/HumanMasculine/Beards/Beard1.png", theCol, theCol, theCol)
	if(theBeard == "b2"):
		var theCol:Color = theBeardArray[1] if theBeardArray.size() > 1 else Color.BLACK
		theCol.a *= 0.8
		head_layered_texture.addColorMaskLayer("res://Mesh/Parts/Head/HumanMasculine/Beards/Beard2.png", theCol, theCol, theCol)
	if(theBeard == "b3"):
		var theCol:Color = theBeardArray[1] if theBeardArray.size() > 1 else Color.BLACK
		theCol.a *= 0.7
		head_layered_texture.addColorMaskLayer("res://Mesh/Parts/Head/HumanMasculine/Beards/Beard3.png", theCol, theCol, theCol)
	if(theBeard == "b4"):
		var theCol:Color = theBeardArray[1] if theBeardArray.size() > 1 else Color.BLACK
		#theCol.a *= 0.85
		head_layered_texture.addColorMaskLayer("res://Mesh/Parts/Head/HumanMasculine/Beards/Beard4.png", theCol, theCol, theCol)
	
	#head_layered_texture.addSimpleLayer("res://Mesh/Parts/Head/FelineHead/Textures/Layers/FelineSnout.png", getOptionValue("snout", Color.WHITE))
	#head_layered_texture.addSimpleLayer("res://Mesh/Parts/Head/FelineHead/Textures/Layers/Lines.png", getOptionValue("lines", Color.WHITE))

	headMat.set_shader_parameter("texture_albedo", head_layered_texture.getTexture())
	updateBodyMess()

func applyOption(_optionID:String, _value:Variant):
	super.applyOption(_optionID, _value)

	if(_optionID == "beard"):
		var theVal:String = _value[0] if _value.size() > 0 else ""
		if(theVal == "b1"):
			setExtra(0, "res://Mesh/Parts/Head/HumanMasculine/Beards/Beard1.tscn")
			#setExtra(0, "")
		elif(theVal == "b2"):
			setExtra(0, "res://Mesh/Parts/Head/HumanMasculine/Beards/Beard2.tscn")
		elif(theVal == "b3"):
			setExtra(0, "res://Mesh/Parts/Head/HumanMasculine/Beards/Beard3.tscn")
		else:
			setExtra(0, "")
		triggerHeadTextureUpdate()
