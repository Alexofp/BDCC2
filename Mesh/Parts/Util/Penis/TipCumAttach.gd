@tool
extends BoneAttachment3D

@export var cumParticles:Array[GPUParticles3D] = []
var backIndx:int = 0

func cum():
	if(cumParticles.is_empty()):
		return
	cumParticles[backIndx].restart()
	backIndx += 1
	if(backIndx >= cumParticles.size()):
		backIndx = 0

func getFirst() -> GPUParticles3D:
	if(cumParticles.is_empty()):
		return null
	return cumParticles[0]

func _ready() -> void:
	for particles in cumParticles:
		particles.emitting = false
		particles.one_shot = true
