extends Object
class_name CharCreatorZone

enum {
	NOTHING = -2,
	ALL = -1,
	Head = 0,
	Ears,
	Eyes,
	Face,
	Mouth,
	Breasts,
	Hands,
	Body,
	Penis,
	Crotch,
	Tail,
	Legs,
}
const ORDER = [
	ALL,
	Head,
	Ears,
	Eyes,
	Face,
	Mouth,
	Breasts,
	Hands,
	Body,
	Penis,
	Crotch,
	Tail,
	Legs,
]
const NAMES = [
	"Head",
	"Ears",
	"Eyes",
	"Face",
	"Mouth",
	"Breasts",
	"Hands",
	"Body",
	"Penis",
	"Crotch",
	"Tail",
	"Legs",
]
const ZONE_TO_BONE = {
	Head: "head",
	Ears: "head",
	Eyes: "head",
	Face: "head",
	Mouth: "head",
	Breasts: "upper_chest",
	Crotch: "hips",
	Legs: "foot.L",
	Penis: "hips",
	Tail: "hips",
	Body: "waist",
	Hands: "hand.R",
}
const ZONE_TO_OFFSET = {
	ALL: Vector3(0.0, 1.336, 0.0),
	Eyes: Vector3(0.0, 0.07, 0.0),
	Head: Vector3(0.0, 0.15, 0.0),
	Ears: Vector3(0.0, 0.15, 0.0),
	Mouth: Vector3(0.0, 0.0, 0.03),
	Face: Vector3(0.0, 0.05, 0.05),
	Breasts: Vector3(0.0, -0.05, 0.1),
	Crotch: Vector3(0.0, -0.03, 0.02),
	Legs: Vector3(0.0, 0.0, 0.05),
	Penis: Vector3(0.0, -0.0, 0.2),
	Tail: Vector3(0.0, -0.1, -0.3),
	Body: Vector3(0.0, 0.0, 0.0),
	Hands: Vector3(0.0, 0.1, -0.02),
}
const ZONE_TO_CAMERA_DIST = {
	ALL: 2.0,
	#Body: 1.1,
	Ears: 0.7,
	Crotch: 0.5,
	Penis: 0.9,
	Tail: 1.5,
	Legs: 0.5,
}
const ZONE_TO_FOV = {
	ALL: 60.0,
	Eyes: 20.0,
	Body: 60.0,
	Mouth: 20.0,
	Face: 30.0,
	Tail: 60.0,
	Legs: 60.0,
}

static func getName(_zone:int) -> String:
	if(_zone == -2):
		return "Nothing"
	if(_zone == -1):
		return "All"
	if(_zone < 0 || _zone >= NAMES.size()):
		return "ERROR:BADZONE"+str(_zone)
	return NAMES[_zone]

static func isPivotAround(_zone:int) -> bool:
	if(_zone == ALL):
		return false
	#if(_zone == Tail):
	#	return false
	return true

static func getPivotPos(_zone:int) -> Vector3:
	if(ZONE_TO_OFFSET.has(_zone)):
		return ZONE_TO_OFFSET[_zone]
	return Vector3(0.0, 1.0, 0.0)

static func getFollowBone(_zone:int) -> String:
	if(ZONE_TO_BONE.has(_zone)):
		return ZONE_TO_BONE[_zone]
	return ""

static func getCameraFOV(_zone:int) -> float:
	if(ZONE_TO_FOV.has(_zone)):
		return ZONE_TO_FOV[_zone]
	return 40.0

static func getCameraDist(_zone:int) -> float:
	if(ZONE_TO_CAMERA_DIST.has(_zone)):
		return ZONE_TO_CAMERA_DIST[_zone]
	return 1.1
