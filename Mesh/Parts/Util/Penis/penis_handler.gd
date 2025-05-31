extends Node
class_name PenisHandler

@export var forwardCumParticles:Array[GPUParticles3D] = []
@export var insideCumParticles:Array[GPUParticles3D] = []

var backIndx:int = 0

func _ready() -> void:
	for particles in forwardCumParticles:
		particles.emitting = false
		particles.one_shot = true
	for particles in insideCumParticles:
		particles.emitting = false
		particles.one_shot = true

func cum(_isForward:bool):
	if(!_isForward):
		CumManager.doShoot(insideCumParticles[0], RNG.randfRange(1.0, 3.0))
	else:
		CumManager.doShoot(forwardCumParticles[0], RNG.randfRange(1.0, 3.0))
	
	if(true):
		return
	
	if(_isForward):
		if(forwardCumParticles.is_empty()):
			return
		forwardCumParticles[0].restart()
	else:
		if(forwardCumParticles.is_empty()):
			return
		insideCumParticles[backIndx].restart()
		backIndx += 1
		if(backIndx >= insideCumParticles.size()):
			backIndx = 0
