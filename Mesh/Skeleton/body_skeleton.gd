extends Node3D
class_name BodySkeleton

@onready var arm_move_l: MoveBoneModifier = %ArmMoveL
@onready var arm_move_r: MoveBoneModifier = %ArmMoveR

@onready var vagina_hole: DollOpenableHole = %VaginaHole
@onready var vagina_inside: Marker3D = %VaginaInside

@onready var anus_hole: DollOpenableHole = %AnusHole
@onready var anus_inside: Marker3D = %AnusInside
@onready var skeleton_3d: Skeleton3D = %Skeleton3D
@onready var chest_bone_attachment: BoneAttachment3D = %ChestBoneAttachment

@onready var squirt_particles_1: GPUParticles3D = %SquirtParticles1
@onready var squirt_particles_2: GPUParticles3D = %SquirtParticles2
@onready var squirt_particles_3: GPUParticles3D = %SquirtParticles3
@onready var squirtParticles:Array[GPUParticles3D] = [
	squirt_particles_1,
	squirt_particles_2,
	squirt_particles_3,
	]
var currentSquirtParticlesIndx:int = 0

@onready var penis_guide_1_attach: BoneAttachment3D = %PenisGuide1Attach
@onready var penis_guide_2_attach: BoneAttachment3D = %PenisGuide2Attach
@onready var pp_guide_1: Marker3D = %PPGuide1
@onready var pp_guide_2: Marker3D = %PPGuide2

func getVaginaHoleNode() -> DollOpenableHole:
	return vagina_hole

func getVaginaInsideNode() -> Node3D:
	return vagina_inside

func getAnusHoleNode() -> DollOpenableHole:
	return anus_hole

func getAnusInsideNode() -> Node3D:
	return anus_inside

func resetBones():
	skeleton_3d.reset_bone_poses()

func getChestBoneAttachment() -> BoneAttachment3D:
	return chest_bone_attachment

func _ready() -> void:
	#for particleGPU in squirtParticles:
		#particleGPU.process_material = particleGPU.process_material.duplicate(true)
	arm_move_l.translation = Vector3(0.0, 0.0294, 0.0)
	arm_move_r.translation = Vector3(0.0, 0.0294, 0.0)
	arm_move_l.influence = 0.0
	arm_move_r.influence = 0.0

func doSquirtVagina(amountMult:float = 1.0, speedMult:float = 1.0, timeMult:float = 1.0, spreadMult:float = 1.0):
	var currentParticles:GPUParticles3D = squirtParticles[currentSquirtParticlesIndx]
	
	var particleProcessMat:ParticleProcessMaterial = currentParticles.process_material
	particleProcessMat.initial_velocity_min = 1.0 * speedMult
	particleProcessMat.initial_velocity_max = 2.0 * speedMult
	particleProcessMat.spread = spreadMult
	
	
	currentParticles.lifetime = timeMult
	currentParticles.amount = int(max(round(amountMult * 32), 1.0))
	currentParticles.restart()
	
	currentSquirtParticlesIndx += 1
	if(currentSquirtParticlesIndx >= squirtParticles.size()):
		currentSquirtParticlesIndx = 0

func setShoulderWidthInfluence(_f:float):
	arm_move_l.influence = _f
	arm_move_r.influence = _f

func getShoulderWidthInfluence() -> float:
	return arm_move_l.influence

func getPenisGuide1() -> Node3D:
	return pp_guide_1

func getPenisGuide2() -> Node3D:
	return pp_guide_2
