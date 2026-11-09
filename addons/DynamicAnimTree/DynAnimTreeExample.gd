extends DynamicAnimTreeDef

func defineLayers():
	var theBlend2D:DATBlend2D = DATBlend2D.new()
	theBlend2D.addPoint(0, Vector2(0.0, 0.0), "Idle")
	theBlend2D.addPoint(1, Vector2(0.0, 0.5), "Jog")
	theBlend2D.addPoint(2, Vector2(0.0, 1.0), "Run")
	theBlend2D.addPoint(3, Vector2(1.0, 0.0), "Idle")
	addLayer(1, theBlend2D)
	
	var theAnim:DATAnim = DATAnim.new()
	#theAnim.instantEnable = true
	addLayer(2, theAnim)
	
	#theAnim.UID = 1
	#addLayer(1, theAnim)
	#theAnim.UID = 1
	var theAnimArms:DATAnim = DATAnim.new()
	theAnimArms.filterBonesReq = ["clavicle.l", "clavicle.r"]
	addLayer(3, theAnimArms)
	var theAnimLArm:DATAnim = DATAnim.new()
	theAnimLArm.filterBonesReq = ["clavicle.l"]
	addLayer(4, theAnimLArm)
	addLayer(5, theAnimArms)
	addLayer(6, theAnim)
	

	#var theTree:DATLayers = DATLayers.new()
	#theTree.UID = 1
	#setRoot(theTree)
	#
	#var theAnim1:DATAnim = DATAnim.new("idle")
	#theAnim1.UID = 2
	#theTree.setLayer(1, theAnim1)
	#
	#var theAnim2:DATAnim = DATAnim.new("walk")
	#theAnim1.UID = 3
	#theTree.setLayer(2, theAnim1)
