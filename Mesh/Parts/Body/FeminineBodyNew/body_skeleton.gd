extends Node3D

@onready var skeleton = $rig/Skeleton3D
@onready var animPlayer = $AnimationPlayer

func _ready():
	animPlayer.root_motion_track = NodePath("rig/Skeleton3D:DEF-char_root")

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

var rollOnLand = false

func setAnimState(newAnimState):
	animState = newAnimState
	timeElapsed = 0.0

func getRootPos() -> Vector3:
	return animPlayer.get_root_motion_position()

func _process(delta):
	timeElapsed += delta
	
	#if(true):
	#	return
	#if(animState != "stand"):
	#	print(animPlayer.get_root_motion_position())
	
	if(animState == "stand"):
		if(desiredState == "walk"):
			setAnimState("standToWalk")
			isFlip = !isFlip
		if(desiredState == "run"):
			setAnimState("standToRun")
		if(desiredState == "jump"):
			setAnimState("runToJump")
		if(desiredState == "roll"):
			setAnimState("roll")
			
	elif(animState == "standToWalk"):
		if(desiredState == "walk"):
			if(timeElapsed > 0.2):
				setAnimState("walk")
		elif(desiredState == "run"):
			setAnimState("standToRun")
		else:
			setAnimState("stand")
	elif(animState == "walk"):
		if(desiredState == "stand"):
			setAnimState("walkToStand")
			#setAnimState("stand")
		if(desiredState == "run"):
			setAnimState("run")
		if(desiredState == "jump"):
			setAnimState("runToJump")
		if(desiredState == "roll"):
			setAnimState("roll")
	elif(animState == "walkToStand"):
		if(desiredState == "stand"):
			if(timeElapsed > 0.4):
				setAnimState("stand")
		else:
			setAnimState("walk")
	elif(animState == "run"):
		if(desiredState == "walk"):
			setAnimState("walk")
		elif(desiredState == "stand"):
			setAnimState("runToStand")
		if(desiredState == "jump"):
			setAnimState("runToJump")
		if(desiredState == "roll"):
			setAnimState("roll")
	elif(animState == "runToStand"):
		if(desiredState == "stand"):
			if(timeElapsed > 0.8):
				setAnimState("stand")
		else:
			setAnimState("run")
	elif(animState == "standToRun"):
		if(desiredState == "run"):
			if(timeElapsed > 0.6):
				setAnimState("run")
		else:
			setAnimState("stand")
	elif(animState == "fall"):
		if(desiredState == "jump"):
			pass
		elif(desiredState == "run"):
			if(rollOnLand):
				setAnimState("roll")
			else:
				setAnimState("land")
		else:
			setAnimState("land")
	elif(animState == "land"):
		if(timeElapsed > 0.3 && desiredState == "run"):
			setAnimState("run")
		if(timeElapsed > 0.4):
			setAnimState("stand")
	elif(animState == "roll"):
		if(timeElapsed > 0.8 && desiredState == "run"):
			setAnimState("run")
		if(timeElapsed > 1.3):
			setAnimState("stand")
	elif(animState == "runToJump"):
		if(desiredState == "jump"):
			if(timeElapsed > 0.3):
				setAnimState("fall")
		else:
			setAnimState("fall")

	
	justSwitchedAnim = false
	if(oldAnimState != animState):
		justSwitchedAnim = true
		oldAnimState = animState
	
	if(animState == "stand"):
		animPlayer.play("StandSimple")
	elif(animState == "standToWalk"):
		animPlayer.play("StandToWalkNew")
		#animPlayer.play("StartToWalkSimple"+("Flip" if isFlip else ""), -1.0, 1.7)
	elif(animState == "walk"):
		animPlayer.play("Walk2Simple", -1.0, 1.0)
		#animPlayer.play("WalkSimple", -1.0, 1.7)
		#if(justSwitchedAnim && isFlip):
		#	animPlayer.seek(1.6666/2.0)
	elif(animState == "walkToStand"):
		animPlayer.play("WalkEnd")
	elif(animState == "run"):
		animPlayer.play("RunSimple")
	elif(animState == "standToRun"):
		animPlayer.play("RunStart")
	elif(animState == "runToStand"):
		animPlayer.play("RunStop")
		#animPlayer.play("StartToWalkSimple", -1.0, -1.7, true)
	elif(animState == "fall"):
		animPlayer.play("Falling")
	elif(animState == "roll"):
		animPlayer.play("Roll")
	elif(animState == "land"):
		animPlayer.play("Land")
	elif(animState == "landRun"):
		animPlayer.play("LandRun")
	elif(animState == "runToJump"):
		animPlayer.play("JumpRun")

func stand():
	desiredState = "stand"
	#animPlayer.play("StandSimple")

func walk():
	desiredState = "walk"
	#animPlayer.play("WalkSimple", -1.0, 1.3)
	#animPlayer.play("Walk2Simple", -1.0, 1.0)

func run():
	desiredState = "run"
	#animPlayer.play("WalkSimple", -1.0, 1.3)
	#animPlayer.play("RunSimple", -1.0, 1.0)

func jump():
	desiredState = "jump"

func roll():
	desiredState = "roll"
