extends DollPart

@onready var digi_legs: MeshInstance3D = %DigiLegs
@onready var planti_legs: MeshInstance3D = %PlantiLegs
@onready var neck_connector: MeshInstance3D = %NeckConnector
@onready var neck_connector_furry: MeshInstance3D = %NeckConnectorFurry

@export var bodyMat:MyMasterBodyMat

@onready var body_layered_texture: MyLayeredTexture = %BodyLayeredTexture

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "thickness"):
		var thinValue:float = 0.0
		var thickValue:float = 0.0
		if(_value > 0.5):
			thickValue = (_value - 0.5)*2.0
		if(_value < 0.5):
			thinValue = (0.5 - _value)*2.0
		setBlendshape("ThinVery", thinValue)
		setBlendshape("Thick", thickValue)
	if(_optionID == "legType"):
		digi_legs.visible = (_value == "digi")
		planti_legs.visible = (_value == "planti")
	if(_optionID == "bodyLayers"):
		updateBodyTexture()

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(bodyMat == null):
		return
		
	const ignoreUniforms = ["albedo"]
		
	if(_skinTypeData.skinType == SkinType.HumanSkin):
		bodyMat.copyFrom(load("res://Mesh/Parts/Body/FeminineBody/BodySmartMatTest.tres"), ignoreUniforms)
		bodyMat.set_shader_parameter("texture_normal", load("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySubstancePainter_Body_Normal.png"))
		bodyMat.set_shader_parameter("texture_orm", load("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySubstancePainter_Body_ORM.png"))
	elif(_skinTypeData.skinType == SkinType.Fur):
		bodyMat.copyFrom(load("res://Mesh/Parts/Body/FeminineBody/FurBodySmartMat.tres"), ignoreUniforms)
		bodyMat.set_shader_parameter("texture_normal", load("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySubstancePainter_Body_Normal.png"))
		bodyMat.set_shader_parameter("texture_orm", load("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySubstancePainter_Body_ORM.png"))
	
	#bodyMat.set_shader_parameter("albedo", _skinTypeData.color)
	bodyMat.set_shader_parameter("albedo", Color.WHITE)
	updateBodyTexture()

func updateBodyTexture():
	var theSkinData:SkinTypeData = getSkinData()
	if(theSkinData == null):
		return
	
	body_layered_texture.clearLayers()
	
	if(theSkinData.skinType == SkinType.Fur):
		body_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySubstancePainter_Body_BaseColor.png", theSkinData.color)
	if(theSkinData.skinType == SkinType.HumanSkin):
		body_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySubstancePainter_Body_BaseColor.png", theSkinData.color)
	
	addLayersToTexture(body_layered_texture, getOptionValue("bodyLayers", []))

	bodyMat.set_shader_parameter("texture_albedo", body_layered_texture.getTexture())
	bodyMat.set_shader_parameter("freshnel_mod", 0.15)
	
func gatherPartFlags(_theFlags:Dictionary):
	pass

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HumanNeck") && _theFlags["HumanNeck"]):
		neck_connector.visible = true
		neck_connector_furry.visible = false
	else:
		neck_connector.visible = false
		neck_connector_furry.visible = true
