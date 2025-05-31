extends DollPart

@onready var digi_legs: MeshInstance3D = %DigiLegs
@onready var planti_legs: MeshInstance3D = %PlantiLegs
@onready var neck_connector: MeshInstance3D = %NeckConnector
@onready var neck_connector_furry: MeshInstance3D = %NeckConnectorFurry

@export var bodyMat:MyMasterBodyMat

@onready var body_layered_texture: MyLayeredTexture = %BodyLayeredTexture

@onready var randomCumScroll:float = RNG.randfRange(0.0, 100.0)
@onready var cum_layer: MyLayeredTexture = %CumLayer
@onready var nipples: MeshInstance3D = %Nipples

func updateThickness():
	updateThicknessBody()

func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)

func applyOption(_optionID:String, _value:Variant):
	updateBreasts(_optionID, _value)
	
	if(_optionID == "legType"):
		digi_legs.visible = (_value == "digi")
		planti_legs.visible = (_value == "planti")
	if(_optionID == "bodyLayers"):
		updateBodyTexture()
	if(_optionID == "breasts"):
		getDoll().setBreastWiggleMod(clamp(_value, 0.0, 1.0))

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(bodyMat == null):
		return
		
	const ignoreUniforms = ["albedo", "texture_cum_mask"]
		
	if(_skinTypeData.skinType == SkinType.HumanSkin):
		bodyMat.copyFrom(load("res://Mesh/Parts/Body/FeminineBody/SkinBodySmartMat.tres"), ignoreUniforms)
		bodyMat.set_shader_parameter("texture_normal", load("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySubstancePainter_Body_Normal.png"))
		bodyMat.set_shader_parameter("texture_orm", load("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySubstancePainter_Body_ORM.png"))
	elif(_skinTypeData.skinType == SkinType.Fur):
		bodyMat.copyFrom(load("res://Mesh/Parts/Body/FeminineBody/FurBodySmartMat.tres"), ignoreUniforms)
		bodyMat.set_shader_parameter("texture_normal", load("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySubstancePainter_Body_Normal.png"))
		bodyMat.set_shader_parameter("texture_orm", load("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySubstancePainter_Body_ORM.png"))
	
	#bodyMat.set_shader_parameter("albedo", _skinTypeData.color)
	bodyMat.set_shader_parameter("albedo", Color.WHITE)
	bodyMat.set_shader_parameter("cumScroll", randomCumScroll)
	updateBodyTexture()
	updateBodyMess()

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
	if(_theFlags.has("HideNipples") && _theFlags["HideNipples"]):
		nipples.visible = false
	else:
		nipples.visible = true
		
	if(_theFlags.has("HumanNeck") && _theFlags["HumanNeck"]):
		neck_connector.visible = true
		neck_connector_furry.visible = false
	else:
		neck_connector.visible = false
		neck_connector_furry.visible = true
	updateBreastsCleavage(getOptionValue("breastsCleavage", 0.0))
	
func _on_body_layered_texture_on_texture_updated(_newTexture: Texture2D) -> void:
	if(bodyMat):
		bodyMat.set_shader_parameter("texture_albedo", _newTexture)

func updateBodyMess():
	var _mess:= getBodyMess()
	if(!_mess):
		return
	_mess.updateLayeredTexture(cum_layer)

func _on_cum_layer_on_texture_updated(newTexture: Variant) -> void:
	if(bodyMat):
		bodyMat.set_shader_parameter("texture_cum_mask", newTexture)

func updateBodyAlphaMask(_finalAlpha:Texture2D):
	if(bodyMat):
		bodyMat.set_shader_parameter("texture_alpha", _finalAlpha)
