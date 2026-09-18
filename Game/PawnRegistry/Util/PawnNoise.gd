extends Object
class_name PawnNoise

const GOOD := 0
const BLIP := 1
const ERROR := 2
const GOOD_VERY := 3
const BAD_VERY := 4

const NOISE_TYPE_TO_NOISE:Dictionary[int, AudioStream] = {
	GOOD: preload("res://Sounds/UI/Good.ogg"),
	BLIP: preload("res://Sounds/UI/Blip.ogg"),
	ERROR: preload("res://Sounds/UI/Error.ogg"),
	GOOD_VERY: preload("res://Sounds/UI/Good3.ogg"),
	BAD_VERY: preload("res://Sounds/UI/Bad2.ogg"),
}
