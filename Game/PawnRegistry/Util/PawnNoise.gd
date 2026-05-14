extends Object
class_name PawnNoise

const GOOD := 0
const BLIP := 1
const ERROR := 2

const GOOD_NOISE := preload("res://Sounds/UI/Good.ogg")
const BLIP_NOISE := preload("res://Sounds/UI/Blip.ogg")
const ERROR_NOISE := preload("res://Sounds/UI/Error.ogg")

const NOISE_TYPE_TO_NOISE:Dictionary[int, AudioStream] = {
	GOOD: GOOD_NOISE,
	BLIP: BLIP_NOISE,
	ERROR: ERROR_NOISE,
}
