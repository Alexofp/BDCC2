extends RefCounted
class_name WorldChunk

var pos:Vector3i

var wanderAreas:Array[AIWanderArea]
var sittingSpots:Array[PropHandlerBase]
var leanLines:Array[AILeanLine]
var activeLeaners:Array[PropHandlerBase]
