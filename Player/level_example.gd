extends Node3D

@onready var baseCharacter: BaseCharacter = $BaseCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	$Doll.setCharacter(baseCharacter)

	var silly:BaseBodypart = baseCharacter.getRootBodypart().getBodypart(BodypartSlot.Head).setBodypart(BodypartSlot.RightEar, BaseHeadBodypart.new())
	silly.setBodypart(BodypartSlot.LeftEar, BaseEarBodypart.new())
	silly.setBodypart(BodypartSlot.RightEar, BaseEarBodypart.new())
	
	baseCharacter.getRootBodypart().getBodypart(BodypartSlot.Head).removeBodypart(BodypartSlot.RightEar)
	baseCharacter.getRootBodypart().getBodypart(BodypartSlot.Head).setBodypart(BodypartSlot.RightEar, BaseEarBodypart.new())

	$Doll2.setCharacter(baseCharacter)
	
	baseCharacter.getRootBodypart().setOptionValue("thickbutt", 3.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
