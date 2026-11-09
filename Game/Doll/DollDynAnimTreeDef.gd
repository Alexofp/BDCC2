extends DynamicAnimTreeDef
class_name DollDynAnimTreeDef

const LAYER_LOCOMOTION:int = 0
const LAYER_COMBAT:int = 1
const LAYER_GESTURE_FULLBODY:int = 2
const LAYER_COUPLE:int = 3
const LAYER_GESTURE:int = 4
const LAYER_RIGHT_ARM:int = 5
const LAYER_ARMS:int = 6

const LOC_IDLE:int = 0
const LOC_FORWARD:int = 1
const LOC_BACK:int = 2
const LOC_RIGHT:int = 3
const LOC_LEFT:int = 4
const LOC_RUN:int = 5

func defineLayers():
	var theLocBlend:DATBlend2D = DATBlend2D.new()
	theLocBlend.addPoint(LOC_IDLE, Vector2(0.0, 0.0), "")
	theLocBlend.addPoint(LOC_FORWARD, Vector2(0.0, 1.0), "")
	theLocBlend.addPoint(LOC_BACK, Vector2(0.0, -1.0), "", 1.0, true)
	theLocBlend.addPoint(LOC_RIGHT, Vector2(1.0, 0.0), "")
	theLocBlend.addPoint(LOC_LEFT, Vector2(-1.0, 0.0), "", 1.0, true)
	theLocBlend.addPoint(LOC_RUN, Vector2(0.0, 2.0), "")
	addLayer(LAYER_LOCOMOTION, theLocBlend)
	
	var theBasicAnim:DATAnim = DATAnim.new()
	addLayer(LAYER_COMBAT, theBasicAnim)
	addLayer(LAYER_GESTURE_FULLBODY, theBasicAnim)
	addLayer(LAYER_COUPLE, theBasicAnim)
	
	var theGestureAnim:DATAnim = DATAnim.new()
	theGestureAnim.filterBonesReq = ["upper_chest"]
	addLayer(LAYER_GESTURE, theGestureAnim)
	
	var theRightArmAnim:DATAnim = DATAnim.new()
	theRightArmAnim.filterBonesReq = ["shoulder.R"]
	addLayer(LAYER_RIGHT_ARM, theRightArmAnim)

	var theArmsAnim:DATAnim = DATAnim.new()
	theArmsAnim.filterBonesReq = ["shoulder.L", "shoulder.R"]
	addLayer(LAYER_ARMS, theArmsAnim)
