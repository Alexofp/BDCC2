extends RefCounted
class_name BaseSkinData

var skinType: String = "fur"
var skinColor: Color = Color.WHITE
var roughness: float = 1.0
var specular: float = 0.5
var rim: float = 0.0
var rimTint: float = 0.0

func makeCopy() -> BaseSkinData:
	var newData = BaseSkinData.new()
	newData.skinType = skinType
	newData.skinColor = skinColor
	newData.roughness = roughness
	newData.specular = specular
	newData.rim = rim
	newData.rimTint = rimTint
	return newData

func applyToStandardMaterial(material:StandardMaterial3D):
	material.albedo_color = skinColor
	material.roughness = roughness
	material.metallic_specular = specular
	if(rim > 0.0):
		material.rim_enabled = true
		material.rim = rim
		material.rim_tint = rimTint
	else:
		material.rim_enabled = false

func applyToShaderMaterial(material:ShaderMaterial):
	material.set_shader_parameter("albedo", skinColor)
	material.set_shader_parameter("roughness", roughness)
	material.set_shader_parameter("specular", specular)
