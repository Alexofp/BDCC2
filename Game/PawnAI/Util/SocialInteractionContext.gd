extends RefCounted
class_name SocialInteractionContext

var main:CharacterPawn
var target:CharacterPawn

func setup(_main:CharacterPawn, _target:CharacterPawn):
	main = _main
	target = _target
