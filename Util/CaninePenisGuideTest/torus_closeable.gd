@tool
extends Node3D

@export var opener:Node3D

@onready var torus_closeable: MeshInstance3D = $TorusCloseable

@export var openValueMult:float = 1.0
var curOpenValue:float = 0.0
var oldOpenValue:float = 0.0

var pushValue:float = 0.0
var savedInValue:float = 0.0

func setOpenVal(theVal:float):
	torus_closeable.set_blend_shape_value(torus_closeable.find_blend_shape_by_name("Close"), 1.0-theVal)

func setPushVal(theVal:float):
	torus_closeable.set_blend_shape_value(torus_closeable.find_blend_shape_by_name("Push"), theVal)

func _process(_delta: float) -> void:
	var targetOpenValue:float = 0.0
	var targetInValue:float = 0.0
	
	if(opener):
		targetOpenValue = opener.getHoleOpenValue() * openValueMult
		targetInValue = opener.getHowDeepTipValue()
	
	if(targetOpenValue > curOpenValue):
		curOpenValue = moveValueTowards(curOpenValue, targetOpenValue, _delta*5.0)
	else:
		curOpenValue = moveValueTowards(curOpenValue, targetOpenValue, (_delta+curOpenValue/10.0)*3.0)
	
	var inDiff:float = targetInValue - savedInValue
	var diff:float = curOpenValue - oldOpenValue
	pushValue = moveValueTowards(pushValue, 0.0, _delta*2.0*max(abs(pushValue), 0.1))
	pushValue += inDiff*10.0#diff * 5.0
	pushValue += diff * 5.0
	
	setOpenVal(curOpenValue)
	setPushVal(pushValue)
	oldOpenValue = curOpenValue
	savedInValue = targetInValue

func moveValueTowards(ourValue:float, targetValue:float, changeSpeed:float) -> float:
	if(changeSpeed == 0.0 || ourValue == targetValue):
		return ourValue
	
	if(ourValue < targetValue):
		ourValue += changeSpeed
		if(ourValue > targetValue):
			ourValue = targetValue
	
	if(ourValue > targetValue):
		ourValue -= changeSpeed
		if(ourValue < targetValue):
			ourValue = targetValue
	
	return ourValue
	
	
