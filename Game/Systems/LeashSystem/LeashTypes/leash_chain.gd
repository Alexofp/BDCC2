@tool
extends "res://addons/godot-polyliner/Line3D/LinePath3D.gd"

func setPoints(_lp1:LeashPoint, _lp2:LeashPoint):
	var _p1:Vector3 = _lp1.global_position
	var _p2:Vector3 = _lp2.global_position
	var theCurve:Curve3D = curve
	#theCurve.set_point_position(0, to_local(_p1))
	#theCurve.set_point_position(1, to_local(_p2))
	theCurve.set_point_position(0, _p1)
	theCurve.set_point_position(1, _p2)
	
	var g1 := _lp1.global_basis.get_rotation_quaternion()*_lp1.leashVector
	theCurve.set_point_out(0, g1+Vector3(0.0, _lp1.leashSag, 0.0))
	var g2 := _lp2.global_basis.get_rotation_quaternion()*_lp2.leashVector
	theCurve.set_point_in(1, g2+Vector3(0.0, _lp2.leashSag, 0.0))
	
#func getLocalCurveHandlePos(theGlobalTransform:Transform3D, handlePos:float) -> Vector3:
#	return (global_transform.inverse() * theGlobalTransform).basis.get_rotation_quaternion() * Vector3.FORWARD*handlePos
