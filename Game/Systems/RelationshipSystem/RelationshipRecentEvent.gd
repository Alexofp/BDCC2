extends RefCounted
class_name RelationshipRecentEvent

const EVENT_GENERIC_BAD := 0
const EVENT_TRIED_TO_LEASH := 1

var causerID:String
var targetID:String

const CAUSED_BY_NOONE := 0
const CAUSED_BY_CHAR1 := 1 # char2 is the target
const CAUSED_BY_CHAR2 := 2 # char1 is the target

var causer:int = CAUSED_BY_NOONE

var eventType:int = EVENT_GENERIC_BAD
var anger:float = 0.0 # How frustrated is the target by this event
var timeLeft:float = 0.0
var timeFull:float = 10.0
