extends RigidBody3D
@onready var generic_6dof_joint_3d: Generic6DOFJoint3D = $Generic6DOFJoint3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export var sticked:bool = false

func _on_body_entered(body: Node) -> void:
	if(sticked):
		return
	sticked = true
	global_position = localColPos + localColNormal*collision_shape_3d.shape.radius*collision_shape_3d.scale.x
	
	generic_6dof_joint_3d.node_a = generic_6dof_joint_3d.get_path_to(self)
	generic_6dof_joint_3d.node_b = generic_6dof_joint_3d.get_path_to(body)
	#print("STICKED")

var localColPos:Vector3
var localColNormal:Vector3
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if(sticked):
		return
	if(state.get_contact_count() > 0):
		localColPos = state.get_contact_collider_position(0)
		localColNormal = state.get_contact_local_normal(0)
