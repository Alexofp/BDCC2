extends "res://Mesh/Parts/Body/FeminineBody/feminine_body.gd"

func getShouldersWidth() -> float:
	return 1.0

func calcBreastPhysics(_breasts:float):
	if(_breasts < 1.1):
		breastWigglePhysics = clamp( remap(_breasts, 0.0, 1.1, 0.0, 0.1) , 0.1, 1.0)
	else:
		breastWigglePhysics = clamp( remap(_breasts, 1.1, 2.0, 0.1, 1.0) , 0.1, 1.0)

func applyNormalORMTextures():
	var _skinType := getSkinType()
	if(_skinType == SkinType.HumanSkin):
		bodyMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Body/MasculineBody/Textures/Skin/MyMascBodySculpt_low_Body_Normal.png"))
		bodyMat.set_shader_parameter("texture_orm", preload("res://Mesh/Parts/Body/MasculineBody/Textures/Skin/MyMascBodySculpt_low_Body_ORM.png"))
	elif(_skinType == SkinType.Fur):
		bodyMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Body/MasculineBody/Textures/Fur/MyMascBodySculpt_low_Body_Normal.png"))
		bodyMat.set_shader_parameter("texture_orm", preload("res://Mesh/Parts/Body/MasculineBody/Textures/Fur/MyMascBodySculpt_low_Body_ORM.png"))

func addBodyTextureLayers():
	var theSkinData:SkinTypeData = getSkinData()
	if(theSkinData == null):
		return
	var theSkinType := getSkinType()
	
	body_layered_texture.clearLayers()
	
	if(theSkinType == SkinType.Fur):
		body_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/MasculineBody/Textures/Fur/MyMascBodySculpt_low_Body_BaseColor.png", theSkinData.color)
	if(theSkinType == SkinType.HumanSkin):
		#body_layered_texture.addSimpleLayer(HUMAN_SKIN_COLOR, theSkinData.color)
		#body_layered_texture.addSimpleLayer(HUMAN_SKIN_COLOR, Color.WHITE)
		body_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/skinwhite.png", theSkinData.color)
		var colorDark:Color = theSkinData.color
		colorDark.v *= 0.5678
		colorDark.s = minf(1.0, colorDark.s*4.0)
		colorDark.h += 0.01
		var colorLight:Color = theSkinData.color
		colorLight.v = minf(1.0, colorLight.v*1.3)
		colorLight.s *= 0.5985
		colorLight.h += 0.03
		var colorHighlight:Color = theSkinData.color
		colorHighlight.v = minf(1.0, colorHighlight.v*3.0)
		colorHighlight.s *= 0.1
		colorHighlight.h += 0.0
		body_layered_texture.addColorMaskLayer("res://Mesh/Parts/Body/MasculineBody/Textures/Skin/MyMascBodySculpt_low_Body_BaseColor.png", colorHighlight, colorLight, colorDark)

func updateBreastsStuff(_part:DollBasePart):
	var theSagVal:float = clampf(getBodypartOptionValue(BodypartSlot.Body, "breastsSag", 0.0), 0.0, 1.0)
	var _value:float = getBodypartOptionValue(BodypartSlot.Body, "breasts", 0.0)
	var theHugeVal:float = maxf(0.0, (_value-1.0)/2.0)
	var _valueCleavage:float = getBodypartOptionValue(BodypartSlot.Body, "breastsCleavage", 0.0)
	if(getCachedPartFlag("ForceBreastCleavage", false)):
		_valueCleavage = 1.0
	if(_value < 0.1):
		_valueCleavage = 0.0
	if(_value < 3.0):
		_valueCleavage *= _value*0.33

	if(_value <= 0.1):
		_part.setBlendshape("BreastsFlat", clampf( remap(_value, 0.0, 0.1, 0.0, 1.0) , 0.0, 1.0))
		_part.setBlendshape("BreastsFemale", 0.0)
		_part.setBlendshape("BreastsHuge", 0.0)
		_part.setBlendshape("BreastsSag", 0.0)
	elif(_value <= 1.0):
		_part.setBlendshape("BreastsFlat", clampf( remap(_value, 0.1, 1.0, 1.0, 0.0) , 0.0, 1.0))
		_part.setBlendshape("BreastsFemale", clampf( remap(_value, 0.1, 1.0, 0.0, 1.0) , 0.0, 1.0))
		_part.setBlendshape("BreastsHuge", 0.0)
		_part.setBlendshape("BreastsSag", 0.0)
	else:
		_part.setBlendshape("BreastsFlat", 0.0)
		_part.setBlendshape("BreastsFemale", clampf( remap(_value, 1.0, 3.0, 1.0, 0.0) , 0.0, 1.0))
		_part.setBlendshape("BreastsHuge", theHugeVal*(1.0-theSagVal))
		_part.setBlendshape("BreastsSag", theHugeVal*theSagVal)
	
	#var theHugeVal:float = maxf(0.0, (_value-1.0)/2.0)
	#_part.setBlendshape("BreastsHuge", theHugeVal*(1.0-theSagVal))
	#_part.setBlendshape("BreastsSag", theHugeVal*theSagVal)
	
	#if(_value >= 0.1):
		#_part.setBlendshape("BreastsFlat", clampf( remap(_value, 1.0, 0.1, 0.0, 1.0) , 0.0, 1.0))
		#_part.setBlendshape("BreastsPecs", clampf( remap(_value, 0.1, 0.0, 0.0, 1.0) , 0.0, 1.0))
	#else:
		#_part.setBlendshape("BreastsFlat", clampf( remap(_value, 0.1, 0.0, 1.0, 0.0) , 0.0, 1.0))
		#_part.setBlendshape("BreastsPecs", clampf( remap(_value, 0.1, 0.0, 0.0, 1.0) , 0.0, 1.0))

	var _nippleShape:float = getBodypartOptionValue(BodypartSlot.Body, "nippleShape", 0.0)
	var _nippleDown:float = 1.0
	if(_value <= 0.1):
		_nippleDown = clampf( remap(_value, 0.0, 0.1, 1.0, 0.0) , 0.0, 1.0)
	elif(_value <= 1.0):
		_nippleDown = 0.0
	else:
		_nippleDown = theSagVal*minf((_value-1.0)/2.0, 1.0)
	
	var normalNips:float = maxf(1.0-_nippleShape, 0.0)*maxf(1.0, theHugeVal*2.0)
	var animeNips:float = maxf(_nippleShape, 0.0)*maxf(1.0, theHugeVal*2.0)
	_part.setBlendshape("NipplesNormal", normalNips*(1.0-_nippleDown))
	_part.setBlendshape("NipplesAnime", animeNips*(1.0-_nippleDown))
	_part.setBlendshape("NipplesNormalDown", normalNips*_nippleDown)
	_part.setBlendshape("NipplesAnimeDown", animeNips*_nippleDown)
	#_part.setBlendshape("BreastsCleavage", _value if !getCachedPartFlag("ForceBreastCleavage", false) else 1.0)
	_part.setBlendshape("BreastsCleavage", _valueCleavage)
