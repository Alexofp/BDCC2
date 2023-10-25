extends DollPart

@export var earMat:StandardMaterial3D

func applyBaseSkinData(_data : BaseSkinData):
	if(earMat != null):
		earMat.albedo_color = _data.skinColor
