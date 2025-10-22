extends Node3D
class_name ReflectionProbeHandler

var probes:Array[ReflectionProbe] = []

func _ready() -> void:
	for theChild in get_children():
		if(!(theChild is ReflectionProbe)):
			continue
		probes.append(theChild)
	
	OPTIONS.changedGISetting.connect(updateAllProbes)
	updateAllProbes()

func updateAllProbes():
	var isSDFGI:bool = OPTIONS.graphics.isDynamicGIEnabled()
	
	if(isSDFGI):
		for probe in probes:
			probe.visible = false
	else:
		for probe in probes:
			probe.visible = true

func _process(_delta: float) -> void:
	pass
