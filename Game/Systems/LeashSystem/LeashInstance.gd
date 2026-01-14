extends Node3D
class_name LeashInstance

@onready var leash_simple_mesh: MeshInstance3D = %LeashSimpleMesh

var networkID:int = 0

var p1con:LeashPointConnection
var p2con:LeashPointConnection
var leashSettings:LeashSettings = LeashSettings.new()

var visibleLeash:Node3D
const LEASH_CHAIN = preload("res://Game/Systems/LeashSystem/LeashTypes/LeashChain.tscn")

# Cached leash points
var p1:LeashPoint
var p2:LeashPoint

func _ready() -> void:
	updateShouldProcess()

func _exit_tree() -> void:
	if(GM.leashSystem):
		GM.leashSystem.clearupLeashInstance(self)
	p1 = null
	p2 = null
	p1con = null
	p2con = null

func setLeashSettings(_settings:LeashSettings):
	leashSettings = _settings
	
	if(visibleLeash):
		visibleLeash.queue_free()
		visibleLeash = null
	
	if(_settings.type == LeashSettings.TYPE_CHAIN):
		visibleLeash = LEASH_CHAIN.instantiate()
		add_child(visibleLeash)
	
	updateDebugLeashVisibility()

func updateDebugLeashVisibility():
	leash_simple_mesh.visible = !visibleLeash

func setPoints(_p1:LeashPointConnection, _p2:LeashPointConnection):
	if(p1con):
		p1con.onLeashPointChange.disconnect(onP1LeashPointChange)
	p1con = _p1
	if(p1con):
		p1con.onLeashPointChange.connect(onP1LeashPointChange)
	
	if(p2con):
		p2con.onLeashPointChange.disconnect(onP2LeashPointChange)
	p2con = _p2
	if(p2con):
		p2con.onLeashPointChange.connect(onP2LeashPointChange)
	
	updateCachedLeashPoints()
	updateShouldProcess()

func onP1LeashPointChange(_newLeashPoint:LeashPoint):
	p1 = _newLeashPoint
	updateShouldProcess()

func onP2LeashPointChange(_newLeashPoint:LeashPoint):
	p2 = _newLeashPoint
	updateShouldProcess()

func updateCachedLeashPoints():
	if(p1con):
		p1con.checkPoint()
	if(p2con):
		p2con.checkPoint()
	p1 = p1con.getLeashPoint()
	p2 = p2con.getLeashPoint()

func updateShouldProcess():
	if(p1 && p2):
		set_process(true)
		#set_physics_process(!Network.isClient())
		set_physics_process(true)
	else:
		set_process(false)
		set_physics_process(false)

func _process(_delta: float) -> void:
	#if(p1con):
		#p1con.checkPoint()
	#if(p2con):
		#p2con.checkPoint()
	updateCachedLeashPoints()
	if(!p1 || !p2):
		return
	
	var pos1 := p1.global_position
	var pos2 := p2.global_position
	
	# Visual leash
	if(leash_simple_mesh.visible):
		var midPoint:Vector3 = pos1.lerp(pos2, 0.5)
		leash_simple_mesh.global_position = midPoint

		#var dirTo := pos1.direction_to(pos2)
		leash_simple_mesh.look_at(pos2)
		
		leash_simple_mesh.scale.z = pos1.distance_to(pos2)
	
	#if(visibleLeash):
	#	visibleLeash.setPoints(pos1, pos2)
	#updateLeashPoints.call_deferred()

func updateLeashPoints():
	if(visibleLeash && p1 && p2):
		#var pos1 := p1.global_position
		#var pos2 := p2.global_position
		visibleLeash.setPoints(p1, p2)

func _physics_process(_delta: float) -> void:
	if(!p1 || !p2 || !is_instance_valid(p1) || !is_instance_valid(p2)):
		if(Network.isServer()):
			queue_free()
		return
	#if(!p1.physicsNode || !p2.physicsNode):
	#	return
	
	if(Network.isClient()):
		if(visibleLeash):
			#var apos1 := p1.global_position
			#var apos2 := p2.global_position
			visibleLeash.setPoints(p1, p2)
		return
	#Log.Print("asd")
	
	var pos1 := p1.getLeashPointCenter()
	var pos2 := p2.getLeashPointCenter()
	var theDistance := pos1.distance_to(pos2)
	
	#if(visibleLeash):
	#	visibleLeash.setPoints(pos1, pos2)
	#updateLeashPoints.call_deferred()
	
	if(theDistance > leashSettings.breakDistance):
		queue_free()
		return
	
	if(theDistance > leashSettings.distance):
		var physicsNode1:PhysicsBody3D = p1.physicsNode
		var physicsNode2:PhysicsBody3D = p2.physicsNode
		if(physicsNode1):
			pullTowards(physicsNode1, pos1, pos2, leashSettings.targetPull)
		if(physicsNode2):
			pullTowards(physicsNode2, pos2, pos1, leashSettings.sourcePull)

	if(visibleLeash):
		visibleLeash.setPoints(p1, p2)

func pullTowards(_node:PhysicsBody3D, _sourcePos:Vector3, _targetPos:Vector3, _mult:float = 1.0):
	if(_node is RigidBody3D):
		_node.apply_central_impulse((_targetPos - _sourcePos)*_node.mass*_mult)
	elif(_node is CharacterBody3D):
		var theVelAdd:Vector3 = (_targetPos - _sourcePos)*_mult
		if(abs(theVelAdd.y) < 5.5):
			theVelAdd.y = 0.0
		_node.velocity += theVelAdd
		_node.move_and_slide()
		
		if(_node is DollController):
			_node.setYankDir(theVelAdd*0.2)

func isTargetAPawn() -> bool:
	return p2con.getCacheNode() is CharacterPawn

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.U32, networkID,
		Bins.BINS, leashSettings.saveNetworkData(),
		Bins.BINS, p1con.saveNetworkData(),
		Bins.BINS, p2con.saveNetworkData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	networkID = _data.readU32()
	var newLeashSettings: = LeashSettings.new()
	newLeashSettings.loadNetworkData(_data.readBins())
	setLeashSettings(newLeashSettings)
	
	var newp1con := LeashPointConnection.new()
	newp1con.loadNetworkData(_data.readBins())
	var newp2con := LeashPointConnection.new()
	newp2con.loadNetworkData(_data.readBins())
	
	setPoints(newp1con, newp2con)
	
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		networkID = networkID,
		leashSettings = leashSettings.saveData(),
		p1con = p1con.saveData(),
		p2con = p2con.saveData(),
	}

func loadData(_data:Dictionary):
	networkID = SAVE.loadVar(_data, "networkID", 0)
	var newLeashSettings: = LeashSettings.new()
	newLeashSettings.loadData(SAVE.loadVar(_data, "leashSettings", {}))
	setLeashSettings(newLeashSettings)
	
	var newp1con := LeashPointConnection.new()
	newp1con.loadData(SAVE.loadVar(_data, "p1con", {}))
	var newp2con := LeashPointConnection.new()
	newp2con.loadData(SAVE.loadVar(_data, "p2con", {}))
	
	setPoints(newp1con, newp2con)
	pass
