extends RefCounted
class_name SocialInteractionContext

var main:CharacterPawn
var target:CharacterPawn

func setup(_main:CharacterPawn, _target:CharacterPawn) -> SocialInteractionContext:
	main = _main
	target = _target
	return self
