extends Node
class_name DollControllerState

var pawn:CharacterPawn

func _ready() -> void:
	pawn = get_parent()

func canSit() -> bool:
	return true

func getDoll() -> DollController:
	return pawn.getDoll()

func processAnimation(_doll:DollController, _dt:float):
	_doll.getDoll().animStand()

func processMove(_doll:DollController, _delta:float):
	pass

func rotate_toward(from: Quaternion, to: Quaternion, delta: float) -> Quaternion:
	return from.slerp(to, clamp(delta / from.angle_to(to), 0.0, 1.0)).normalized()

func basis_rotate_toward(from: Basis, to: Basis, delta: float) -> Basis:
	return from.slerp(to, delta)
	#return Basis(rotate_toward(from.get_rotation_quaternion(), to.get_rotation_quaternion(), delta)).orthonormalized()
