extends DollPart

@onready var inmate_cuff_l: Node3D = %InmateCuffL
@onready var inmate_cuff_r: Node3D = %InmateCuffR
@onready var chain: Path3D = %Chain

func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["CuffedBehindBackPose"] = true

#func getSyncedBodypartSlots() -> Array:
	#return [BodypartSlot.Body]
#
#func applySyncedBodypartOption(_slot:int, _optionID:String, _value:Variant):
	#if(_optionID == "legType"):
		#inmate_cuff_digi_r.visible = (_value == "digi")
		#inmate_cuff_digi_l.visible = (_value == "digi")
		#inmate_cuff_l.visible = (_value != "digi")
		#inmate_cuff_r.visible = (_value != "digi")
		#
		#if(!inmate_cuff_digi_r.visible):
			#chain.nodeA = $LeftAnkle/InmateCuffL/CuffLoc
			#chain.nodeB = $RightAnkle/InmateCuffR/CuffLoc
		#else:
			#chain.nodeA = $LeftAnkle/InmateCuffDigiL/CuffLoc
			#chain.nodeB = $RightAnkle/InmateCuffDigiR/CuffLoc
