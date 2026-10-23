extends RefCounted
class_name CoupleAnimEntry

var anim:CoupleAnimBase
var main:CharacterPawn
var target:CharacterPawn

const STATE_INTERPOLATE_IN := 0
const STATE_ANIM := 1
const STATE_INTERPOLATE_OUT := 2

var time:float = 0.0
var state:int = STATE_INTERPOLATE_IN
var wasDeleted:bool = false
var infTimer:bool = false # If true, this couple anim will never end
var shouldEnd:bool = false

var pos:Transform3D
var mainPos:Transform3D
var targetPos:Transform3D
var mainInitialPos:Transform3D
var targetInitialPos:Transform3D

func saveData() -> Dictionary:
	return {
		id = anim.id,
		main = main.getID(),
		target = target.getID(),
		t = time,
		s = state,
		it = infTimer,
		se = shouldEnd,
		p = pos,
		mp = mainPos,
		tp = targetPos,
		mip = mainInitialPos,
		tip = targetInitialPos,
	}

func loadData(_data:Dictionary):
	var theAnimID:String = SAVE.loadStr(_data, "id")
	anim = GlobalRegistry.getCoupleAnim(theAnimID)
	var theMainID:String = SAVE.loadStr(_data, "main")
	var theTargetID:String = SAVE.loadStr(_data, "target")
	main = GM.pawnRegistry.getPawn(theMainID)
	target = GM.pawnRegistry.getPawn(theTargetID)
	if(!anim || !main || !target):
		wasDeleted = true
		shouldEnd = true
		return
	time = SAVE.loadFloat(_data, "t")
	state = SAVE.loadInt(_data, "s")
	infTimer = SAVE.loadBool(_data, "it")
	shouldEnd = SAVE.loadBool(_data, "se")
	pos = SAVE.loadTransform(_data, "p")
	mainPos = SAVE.loadTransform(_data, "mp")
	targetPos = SAVE.loadTransform(_data, "tp")
	mainInitialPos = SAVE.loadTransform(_data, "mip")
	targetInitialPos = SAVE.loadTransform(_data, "tip")

	main.doCoupleAnim(anim.animMain)
	target.doCoupleAnim(anim.animTarget)

const SMOOTH_CURVE := preload("res://addons/LayeredAnimPlayer/XFadeCurves/Smooth.tres")

signal onAnimEnded

func onStart():
	mainInitialPos = main.getGlobalTransform()
	targetInitialPos = target.getGlobalTransform()
	pos = mainInitialPos.interpolate_with(targetInitialPos, 0.5)

	var main_pos := mainInitialPos.origin
	var target_pos := targetInitialPos.origin
	var dir := target_pos - main_pos
	dir.y = 0.0
	if(dir.length_squared() < 0.01):
		dir = Vector3.FORWARD
	dir = dir.normalized()
	
	var center_pos := (main_pos + target_pos) * 0.5
	var new_main_pos := center_pos - dir * anim.spacing
	var new_target_pos := center_pos + dir * anim.spacing
	
	mainPos = Transform3D()
	mainPos.origin = new_main_pos
	mainPos = mainPos.looking_at(center_pos - 2.0*dir * anim.spacing, Vector3.UP)#.rotated(Vector3.UP, PI)
	
	targetPos = Transform3D()
	targetPos.origin = new_target_pos
	targetPos = targetPos.looking_at(center_pos + 2.0*dir * anim.spacing, Vector3.UP)#.rotated(Vector3.UP, PI)
	
	main.setState(CharacterPawn.STATE_COUPLE)
	target.setState(CharacterPawn.STATE_COUPLE)
	
	main.doCoupleAnim(anim.animMain)
	target.doCoupleAnim(anim.animTarget)

func onEnd():
	if(main):
		main.setState(CharacterPawn.STATE_NORMAL)
		main.doCoupleAnim("")
	if(target):
		target.setState(CharacterPawn.STATE_NORMAL)
		target.doCoupleAnim("")

func processAnim(_dt:float):
	if(isImpossible() || shouldEndInstantly()):
		stopMe()
		return
	time += _dt
	if(state == STATE_INTERPOLATE_IN):
		var _prog:float = SMOOTH_CURVE.sample(clamp(time/anim.timeInterpolateIn, 0.0, 1.0))
		
		main.setGlobalTransform(mainInitialPos.interpolate_with(mainPos, _prog))
		target.setGlobalTransform(targetInitialPos.interpolate_with(targetPos, _prog))
		
		if(time >= anim.timeInterpolateIn):
			setState(STATE_ANIM)
			#main.doCoupleAnim(anim.animMain)
			#target.doCoupleAnim(anim.animTarget)
			return
	elif(state == STATE_ANIM):
		var _prog:float = SMOOTH_CURVE.sample(clamp(time/anim.time, 0.0, 1.0))
		
		main.setGlobalTransform(mainPos)
		target.setGlobalTransform(targetPos)
		
		if((time >= anim.time && !infTimer) || shouldEnd):
			setState(STATE_INTERPOLATE_OUT)
			main.doCoupleAnim("")
			target.doCoupleAnim("")
			mainInitialPos.basis = mainPos.basis
			targetInitialPos.basis = targetPos.basis
			return
	elif(state == STATE_INTERPOLATE_OUT):
		var _prog:float = SMOOTH_CURVE.sample(clamp(time/anim.timeInterpolateOut, 0.0, 1.0))
		
		main.setGlobalTransform(mainPos.interpolate_with(mainInitialPos, _prog))
		target.setGlobalTransform(targetPos.interpolate_with(targetInitialPos, _prog))
		
		if(time >= anim.timeInterpolateOut):
			stopMe()
			return

func setState(_newState:int):
	state = _newState
	time = 0.0

func isImpossible() -> bool:
	if(!anim || state > STATE_INTERPOLATE_OUT || state < STATE_INTERPOLATE_IN):
		return true
	if(!main || !is_instance_valid(main)):
		return true
	if(!target || !is_instance_valid(target)):
		return true
	return false

func shouldEndInstantly() -> bool:
	if(main.isDefeated() || main.isDoingSex()):
		return true
	if(target.isDefeated() || target.isDoingSex()):
		return true
	return false

func stopMe():
	if(wasDeleted):
		return
	onAnimEnded.emit()
