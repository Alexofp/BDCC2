extends GutTest

func before_each():
	gut.p("ran setup", 2)

func after_each():
	gut.p("ran teardown", 2)

func before_all():
	gut.p("ran run setup", 2)
	GlobalRegistry.doInit()

func after_all():
	gut.p("ran run teardown", 2)

var dollScene = preload("res://Player/Doll/doll.tscn")

func test_basecharacter():
	var newCharacter = BaseCharacter.new()
	add_child_autoqfree(newCharacter)
	
	var newDoll = dollScene.instantiate()
	add_child_autoqfree(newDoll)
	
	newDoll.setCharacter(newCharacter)
	
	assert_true(newDoll.getCharacter() == newCharacter)
	assert_eq(newDoll.bodypartToDollPart.size(), 1)

func test_addingParts():
	var newCharacter = BaseCharacter.new()
	add_child_autoqfree(newCharacter)
	
	var head = newCharacter.getRootBodypart().setBodypart(BodypartSlot.Head, BaseHeadBodypart.new())
	head.setBodypart(BodypartSlot.LeftEar, BaseEarBodypart.new())
	head.setBodypart(BodypartSlot.RightEar, BaseEarBodypart.new())

	var newDoll = dollScene.instantiate()
	add_child_autoqfree(newDoll)
	
	newDoll.setCharacter(newCharacter)
	
	assert_eq(newDoll.bodypartToDollPart.size(), 4)
