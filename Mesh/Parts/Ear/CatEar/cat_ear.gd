extends DollPart

@export var earMat:StandardMaterial3D

func applyBaseSkinData(_data : BaseSkinData):
	if(earMat != null):
		applyBaseSkinDataToStandardMaterial(_data, earMat)
