extends Object
class_name Log

static func error(text: String):
	printerr(text)
	#Console.printLine("[color=red]"+text+"[/color]")

static func Printerr(text: String):
	error(text)

static func warning(text: String):
	print(text)
	#Console.printLine("[color=yellow]"+text+"[/color]")

static func Print(text: String):
	print(text)
	#Console.printLine(text)
