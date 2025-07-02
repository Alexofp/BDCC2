@tool
extends ShaderMaterial
class_name MyMasterMaterial

const ShaderPath = "res://addons/MyMasterMaterial/Material/MyMasterMaterial.gdshader"

@export_group("PBR")
enum NormalMapSetup {
	## No normal map support
	None,
	## A standard normal map
	NormalMap,
	## A special normal map that also encodes the ambience occulusion
	BentNormalMap,
}
@export var normalMap:NormalMapSetup = NormalMapSetup.None:
	set(value):
		normalMap = value
		updateShader()
enum PBRSetup {
	## Do not include any kind of ao/roughness/metallic maps
	None,
	## 3 separate textures for AO, roughness and metallic maps
	ThreeTextures,
	## 4 separate textures for AO, roughness, metallic and emission maps
	FourTextures,
	## Use a single texture that combines 3 maps in its rgb channels: red = AO, green = roughness, blue = metallic
	ORM,
	## Use a single texture that combines 4 maps in its rgb channels: red = AO, green = roughness, blue = metallic, alpha = emission (single color emission)
	ORME,
	## Use 2 textures: an ORM texture and an emission map (rgb emission)
	ORM_EmissionTexture,
}
@export var pbrSetup:PBRSetup = PBRSetup.None:
	set(value):
		pbrSetup = value
		updateShader()
enum SubsurfaceScatteringType {
	## Disable the effect
	None,
	## Makes it looks more smooth
	Normal,
	## Same but has slight redness
	Skin,
}
@export var subsurfaceScattering:SubsurfaceScatteringType = SubsurfaceScatteringType.None:
	set(value):
		subsurfaceScattering = value
		updateShader()
@export var clearcoat:bool = false:
	set(value):
		clearcoat = value
		updateShader()
@export var anisotropy:bool = false:
	set(value):
		anisotropy = value
		updateShader()

@export_group("STYLIZATION")
@export var backlight:bool = false:
	set(value):
		backlight = value
		updateShader()
@export var freshnel:bool = false:
	set(value):
		freshnel = value
		updateShader()
@export var rimlight:bool = false:
	set(value):
		rimlight = value
		updateShader()
@export var edgeOutline:bool = false:
	set(value):
		edgeOutline = value
		updateShader()
@export var edgeOutlineExtra:bool = false:
	set(value):
		edgeOutlineExtra = value
		updateShader()
@export var outline:bool = false:
	set(value):
		outline = value
		updateShader()
@export var toonShading:bool = false:
	set(value):
		toonShading = value
		updateShader()
@export var customToonShading:bool = false:
	set(value):
		customToonShading = value
		updateShader()

@export_group("ALPHA")
@export var alphaMask:bool = false:
	set(value):
		alphaMask = value
		updateShader()
@export var alphaTransparency:bool = false:
	set(value):
		alphaTransparency = value
		updateShader()

@export_group("SPECIAL")
@export var doubleSided:bool = false:
	set(value):
		doubleSided = value
		updateShader()
@export var unshaded:bool = false:
	set(value):
		unshaded = value
		updateShader()
@export var colorMask:bool = false:
	set(value):
		colorMask = value
		updateShader()
## Discards pixels if their UV.y coordinate is above 1.0; Could be used to make some of the mesh transparent while keeping the altered normals of the visible parts (highly specialized use-case)
@export var uvBasedDiscard:bool = false:
	set(value):
		uvBasedDiscard = value
		updateShader()
@export var globalDetailMask:bool = false:
	set(value):
		globalDetailMask = value
		updateShader()
@export var globalDetailRoughMask:bool = false:
	set(value):
		globalDetailRoughMask = value
		updateShader()
@export var messLayer:bool = false:
	set(value):
		messLayer = value
		updateShader()
@export var albedoMatcap:bool = false:
	set(value):
		albedoMatcap = value
		updateShader()

@export_group("CACHE")
@export var clearCache:bool = false:
	set(value):
		if(value):
			cachedShaders.clear()
			updateShader()

static var cachedShaders:Dictionary = {}
static var cachedUniformNames:Dictionary = {}
var uniformNames:Array = []

func copyFrom(otherShader:MyMasterMaterial, ignoreUniforms:Array = []):
	normalMap = otherShader.normalMap
	pbrSetup = otherShader.pbrSetup
	clearcoat = otherShader.clearcoat
	anisotropy = otherShader.anisotropy
	backlight = otherShader.backlight
	freshnel = otherShader.freshnel
	rimlight = otherShader.rimlight
	subsurfaceScattering = otherShader.subsurfaceScattering
	alphaMask = otherShader.alphaMask
	uvBasedDiscard = otherShader.uvBasedDiscard
	alphaTransparency = otherShader.alphaTransparency
	globalDetailMask = otherShader.globalDetailMask
	globalDetailRoughMask = otherShader.globalDetailRoughMask
	colorMask = otherShader.colorMask
	doubleSided = otherShader.doubleSided
	unshaded = otherShader.unshaded
	toonShading = otherShader.toonShading
	customToonShading = otherShader.customToonShading
	outline = otherShader.outline
	edgeOutlineExtra = otherShader.edgeOutlineExtra
	edgeOutline = otherShader.edgeOutline
	messLayer = otherShader.messLayer
	albedoMatcap = otherShader.albedoMatcap
	updateShader()
	#var allUniforms:Array = shader.get_shader_uniform_list()
	for theUniformName in uniformNames:
		#var theUniformName:String = theUniform["name"]
		if(ignoreUniforms.has(theUniformName)):
			continue
		set_shader_parameter(theUniformName, otherShader.get_shader_parameter(theUniformName))

func _init():
	updateShader()

func calculateShaderVariantString() -> String:
	var theFlags:Array = []
	if(normalMap == NormalMapSetup.None):
		theFlags.append("non")
	if(normalMap == NormalMapSetup.NormalMap):
		theFlags.append("n")
	if(normalMap == NormalMapSetup.BentNormalMap):
		theFlags.append("bn")
	if(pbrSetup == PBRSetup.None):
		theFlags.append("nopbr")
	elif(pbrSetup == PBRSetup.ThreeTextures):
		theFlags.append("pbr3")
	elif(pbrSetup == PBRSetup.FourTextures):
		theFlags.append("pbr4")
	elif(pbrSetup == PBRSetup.ORM):
		theFlags.append("orm")
	elif(pbrSetup == PBRSetup.ORME):
		theFlags.append("orme")
	elif(pbrSetup == PBRSetup.ORM_EmissionTexture):
		theFlags.append("ormetex")
	if(clearcoat):
		theFlags.append("cc")
	if(anisotropy):
		theFlags.append("at")
	if(backlight):
		theFlags.append("b")
	if(freshnel):
		theFlags.append("f")
	if(rimlight):
		theFlags.append("r")
	if(toonShading):
		theFlags.append("t")
	if(customToonShading):
		theFlags.append("ct")
	if(subsurfaceScattering == SubsurfaceScatteringType.None):
		theFlags.append("sss0")
	elif(subsurfaceScattering == SubsurfaceScatteringType.Normal):
		theFlags.append("sss")
	elif(subsurfaceScattering == SubsurfaceScatteringType.Skin):
		theFlags.append("ssss")
	if(alphaMask):
		theFlags.append("a")
	if(uvBasedDiscard):
		theFlags.append("u")
	if(alphaTransparency):
		theFlags.append("aa")
	if(globalDetailMask):
		theFlags.append("dt")
	if(globalDetailRoughMask):
		theFlags.append("dr")
	if(colorMask):
		theFlags.append("cm")
	if(doubleSided):
		theFlags.append("ds")
	if(unshaded):
		theFlags.append("un")
	if(outline):
		theFlags.append("ou")
	if(edgeOutline):
		theFlags.append("eo")
	if(edgeOutlineExtra):
		theFlags.append("eoe")
	if(messLayer):
		theFlags.append("ml")
	if(albedoMatcap):
		theFlags.append("am")
	return join(theFlags, "|")

func calculateShaderResource() -> Array:
	var masterResource := preload(ShaderPath)
	
	var copyResource := masterResource.duplicate(true)
	
	var defines:Array = []
	if(normalMap == NormalMapSetup.NormalMap):
		defines.append("MY_NORMAL_MAP")
	elif(normalMap == NormalMapSetup.BentNormalMap):
		defines.append("MY_BENT_NORMAL_MAP")
	if(pbrSetup == PBRSetup.ThreeTextures):
		defines.append("MY_PBR_TREE_TEXTURES")
	elif(pbrSetup == PBRSetup.FourTextures):
		defines.append("MY_PBR_TREE_TEXTURES")
		defines.append("MY_PBR_EMISSION")
		defines.append("MY_PBR_EmissionTexture")
	elif(pbrSetup == PBRSetup.ORM):
		defines.append("MY_PBR_ORM")
	elif(pbrSetup == PBRSetup.ORME):
		defines.append("MY_PBR_ORM")
		defines.append("MY_PBR_ORME")
		defines.append("MY_PBR_EMISSION")
	elif(pbrSetup == PBRSetup.ORM_EmissionTexture):
		defines.append("MY_PBR_ORM")
		defines.append("MY_PBR_EmissionTexture")
		defines.append("MY_PBR_EMISSION")
	if(clearcoat):
		defines.append("MY_PBR_CLEARCOAT")
	if(anisotropy):
		defines.append("MY_PBR_ANISOTROPY")
	if(backlight):
		defines.append("MY_BACKLIGHT")
	if(freshnel):
		defines.append("MY_FRESHNEL")
	if(rimlight):
		defines.append("MY_RIMLIGHT")
	if(subsurfaceScattering == SubsurfaceScatteringType.Normal):
		defines.append("MY_SUBSURFACESCATTER")
	if(subsurfaceScattering == SubsurfaceScatteringType.Skin):
		defines.append("MY_SUBSURFACESCATTER")
		defines.append("MY_SUBSURFACESCATTER_SKIN")
	if(toonShading):
		defines.append("MY_TOONSHADING")
	if(alphaMask):
		defines.append("MY_ALPHAMASK")
	if(uvBasedDiscard):
		defines.append("MY_UV_BASED_DISCARD")
	if(alphaTransparency):
		defines.append("MY_ALPHASUPPORT")
	if(globalDetailMask):
		defines.append("MY_GLOBALDETAILMAP")
	if(globalDetailRoughMask):
		defines.append("MY_GLOBALDETAILROUGHMAP")
	if(colorMask):
		defines.append("MY_COLORMASK")
	if(doubleSided):
		defines.append("MY_DOUBLESIDED")
	if(unshaded):
		defines.append("MY_UNSHADED")
	if(outline):
		defines.append("MY_OUTLINE")
	if(edgeOutline || edgeOutlineExtra):
		defines.append("MY_EDGE_OUTLINE")
	if(edgeOutline):
		defines.append("MY_EDGE_OUTLINE_1")
	if(edgeOutlineExtra):
		defines.append("MY_EDGE_OUTLINE_2")
	if(customToonShading):
		defines.append("MY_CUSTOM_SHADING")
	if(messLayer):
		defines.append("MY_MESSLAYER")
	if(albedoMatcap):
		defines.append("MY_ALBEDO_MATCAP")
	var definesText:String = ""
	for define in defines:
		definesText += "#define "+define+"\n"
	
	var shaderCode:String = copyResource.code
	shaderCode = shaderCode.replace("//{{DEFINES_PLACEHOLDER}}", definesText)
	copyResource.code = shaderCode
	
	var theuniformNames:Array = []
	var allUniforms:Array = copyResource.get_shader_uniform_list()
	for theUniform in allUniforms:
		theuniformNames.append(theUniform["name"])
	
	return [copyResource, theuniformNames]

func updateShader():
	var currentVariant:String = calculateShaderVariantString()
	
	if(currentVariant == ""):
		shader = preload(ShaderPath)
		return
	
	if(cachedShaders.has(currentVariant) && cachedUniformNames.has(currentVariant)):
		shader = cachedShaders[currentVariant]
		uniformNames = cachedUniformNames[currentVariant]
	else:
		var theStuff := calculateShaderResource()
		shader =  theStuff[0]
		uniformNames = theStuff[1]
		cachedShaders[currentVariant] = shader
		cachedUniformNames[currentVariant] = uniformNames

func join(arr: Array, separator: String = "") -> String:
	var output = ""
	for s in arr:
		output += str(s) + separator
	output = output.left( output.length() - separator.length() )
	return output
