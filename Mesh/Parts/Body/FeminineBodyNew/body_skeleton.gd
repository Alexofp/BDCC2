extends Node3D

@onready var skeleton = $rig/Skeleton3D
@onready var animPlayer = $AnimationPlayer

func getSkeleton() -> Skeleton3D:
	return skeleton

func getAnimPlayer() -> AnimationPlayer:
	return animPlayer

var desiredState = "stand"
var animState = "stand"
var oldAnimState = "stand"
var timeElapsed = 0.0
var isFlip = false
var justSwitchedAnim = false

func setAnimState(newAnimState):
	animState = newAnimState
	timeElapsed = 0.0

func getRootPos() -> Vector3:
	return animPlayer.get_root_motion_position()

func _process(delta):
	timeElapsed += delta
	
	#if(animState != "stand"):
	#	print(animPlayer.get_root_motion_position())
	
	if(animState == "stand"):
		if(desiredState == "walk"):
			setAnimState("startWalk")
			isFlip = !isFlip
	elif(animState == "startWalk"):
		if(desiredState == "stand"):
			setAnimState("stand")
		elif(desiredState == "walk" && timeElapsed > ((0.8333-0.15)/1.7)):
			setAnimState("walk")
	elif(animState == "walk"):
		if(desiredState == "stand"):
			#setAnimState("endWalk")
			setAnimState("stand")
	elif(animState == "endWalk"):
		if(desiredState == "walk"):
			setAnimState("walk")
		elif(desiredState == "stand" && timeElapsed > ((0.8333-0.15)/1.7)):
			setAnimState("stand")
	
	justSwitchedAnim = false
	if(oldAnimState != animState):
		justSwitchedAnim = true
		oldAnimState = animState
	
	if(animState == "stand"):
		animPlayer.play("IdleSimple")
	elif(animState == "startWalk"):
		animPlayer.play("StartToWalkSimple"+("Flip" if isFlip else ""), -1.0, 1.7)
	elif(animState == "walk"):
		animPlayer.play("WalkSimple", -1.0, 1.7)
		if(justSwitchedAnim && isFlip):
			animPlayer.seek(1.6666/2.0)
	elif(animState == "endWalk"):
		animPlayer.play("StartToWalkSimple", -1.0, -1.7, true)

func stand():
	desiredState = "stand"

func walk():
	desiredState = "walk"
