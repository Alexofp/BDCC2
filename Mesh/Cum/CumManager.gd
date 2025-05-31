extends Node

var cumStrandScene := preload("res://Mesh/Cum/NurbsCum/cum_strand_nurbs.tscn")

var cums:Array[Node3D] = []

func doShoot(theNode:Node3D, theSpeed:float):
	var newCumStrand:Node3D= cumStrandScene.instantiate()
	add_child(newCumStrand)
	#var theTransform:Transform3D = theNode.global_transform
	newCumStrand.global_transform = theNode.global_transform
	newCumStrand.scale = Vector3(1.0, 1.0, 1.0)
	
	newCumStrand.startShoot(theNode, theSpeed)
	#newCumStrand.startShoot(self, randf_range(0.1, 1.0))
	newCumStrand.tree_exiting.connect(onCumFreed.bind(newCumStrand))
	
	while(cums.size() > 10):
		var cumToRemove:Node3D = cums.front()
		cums.pop_front()
		if(is_instance_valid(cumToRemove)):
			cumToRemove.queue_free()
	cums.append(newCumStrand)

func onCumFreed(_cum:Node3D):
	cums.erase(_cum)
