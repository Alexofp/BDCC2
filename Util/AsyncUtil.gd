extends Node

#https://github.com/godotengine/godot-proposals/issues/5510

class TimeoutPromise:
	signal fired()
	
	var has_fired : bool = false
	var was_timeout:bool = false
	
	var timer:SceneTreeTimer
	
	var arg1
	var arg2
	
	func _init(theSignal:Signal, timeout:float):
		theSignal.connect(_fire)
		timer = AsyncUtil.get_tree().create_timer(timeout)
		timer.timeout.connect(_timeout)
	
	func _fire(_a1=null, _a2=null,_a3=null,_a4=null,_a5=null,_a6=null,_a7=null,_a8=null,_a9=null) -> void:
		if(has_fired):
			return
		timer.timeout.disconnect(_timeout)
		timer = null
		arg1 = _a1
		arg2 = _a2
		has_fired = true
		fired.emit()
	
	func _timeout():
		if(has_fired):
			return
		timer.timeout.disconnect(_timeout)
		timer = null
		has_fired = true
		was_timeout = true
		fired.emit()
	
	func didTimeout() -> bool:
		return was_timeout
	
	func didHappen() -> bool:
		return !was_timeout
	
	func getArg1():
		return arg1
	
	func getArg2():
		return arg2
	
func timeout(theSignal:Signal, _timeout:float = 10.0) -> TimeoutPromise:
	var thePromise := TimeoutPromise.new(theSignal, _timeout)
	await thePromise.fired
	return thePromise



class AllAwaiter:
	signal all_completed()

	var _mask: int
	var _completed := false

	func _init(funcs: Array[Callable]) -> void:
		var size := funcs.size()
		assert(size < 64)
		_mask = (1 << size) - 1
		for i in size:
			_call_func(i, funcs[i])
			
	func _call_func(i: int, f: Callable) -> void:
		#@warning_ignore(redundant_await)
		await f.call()
		_mask &= ~(1 << i)
		if not _mask and not _completed:
			_completed = true
			all_completed.emit()

static func await_all(funcs: Array[Callable]) -> void:
	await AllAwaiter.new(funcs).all_completed
