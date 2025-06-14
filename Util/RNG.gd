extends Object
class_name RNG

# generates an [from,to] int, both are inclusive
static func randiRange(from: int, to: int) -> int:
	if(from > to):
		Log.Printerr("randi_range() from is higher than to. From = "+str(from)+" To = "+str(to))
		to = from
	#assert(to >= from)
	
	var randValue = int(floor(randf_range(from, to+1)))
	if(randValue < from):
		randValue = from
	if(randValue > to):
		randValue = to
	
	return randValue
	# This way is bugged apparently?
	#return from + (randi() % (to - from + 1))

static func randfRange(from: float, to: float) -> float:
	return randf_range(from, to)

static func randfRangeX2(from: float, to: float) -> float:
	return (randf_range(from, to) + randf_range(from, to)) / 2.0

# chance(100) will always be true
# chance(3) will be true 3% of the time
static func chance(ch: float) -> bool:
	var randValue = randf() * 100
	if(ch >= randValue):
		return true
	return false
	
# picks a random element from an array or a random key from a dictionary
static func pick(ar):
	if(ar is Dictionary):
		ar = ar.keys()
		
	if(ar.is_empty()):
		return null
	
	return ar[randi() % ar.size()]

static func grab(ar):	
	if(ar is Dictionary):
		ar = ar.keys()
		
	if(ar.is_empty()):
		return null
	
	var elementI = randi() % ar.size()
	var value = ar[randi() % ar.size()]
	ar.remove_at(elementI)
	return value

# RNG.pickWeighted(["a", "b", "c"], [10, 100, 10]) # 'b' will show up 10 times more
static func pickWeighted(ar, weights: Array):
	if(ar is Dictionary):
		ar = ar.keys()
		
	assert(ar.size() == weights.size(), "Weights array doesn't have the same amount of elements as array")
	
	if(ar.is_empty()):
		return null
	
	var sum = 0.0
	for w in weights:
		sum += max(w, 0.0)
	
	var r:float = randf_range(0.0, sum)
	for i in range(weights.size()):
		r -= max(weights[i], 0.0)
		if r <= 0.0:
			return ar[i]
			
	return ar[0]


# RNG.pickWeightedPairs([["a", 10.0], ["b", 100.0], ["c", 10.0]]) # 'b' will show up 10 times more
static func pickWeightedPairs(ar: Array):
	if(ar.is_empty()):
		return null
		
	var sum = 0.0
	for pair in ar:
		sum += max(pair[1], 0.0)
		
	var r:float = randf_range(0.0, sum)
	for i in range(ar.size()):
		r -= max(ar[i][1], 0.0)
		if r <= 0.0:
			return ar[i][0]
			
	return ar[0][0]

# Same as RNG.pickWeighted() but it also removes the picked entry from both arrays
static func grabWeighted(ar, weights: Array):
	if(ar is Dictionary):
		ar = ar.keys()
		
	assert(ar.size() == weights.size(), "Weights array doesn't have the same amount of elements as array")
	
	if(ar.is_empty()):
		return null
	
	var sum = 0.0
	for w in weights:
		sum += max(w, 0.0)
	
	var r:float = randf_range(0.0, sum)
	for i in range(weights.size()):
		r -= max(weights[i], 0.0)
		if r <= 0.0:
			var result2 = ar[i]
			ar.remove_at(i)
			weights.remove_at(i)
			return result2
			
	var result = ar[0]
	ar.remove_at(0)
	weights.remove_at(0)
	return result

# Same as RNG.pickWeightedPairs() but it also removes the picked entry from the array
static func grabWeightedPairs(ar: Array):
	if(ar.is_empty()):
		return null
		
	var sum = 0.0
	for pair in ar:
		sum += max(pair[1], 0.0)
		
	var r:float = randf_range(0.0, sum)
	for i in range(ar.size()):
		r -= max(ar[i][1], 0.0)
		if r <= 0.0:
			var result2 = ar[i][0]
			ar.remove_at(i)
			return result2
			
	var result = ar[0][0]
	ar.remove_at(0)
	return result
	
#static func randomMaleName():
#	return pick(RNGData.maleNames)

#static func randomFemaleName():
#	return pick(RNGData.femaleNames)

static func pickHashed(ar, thehash:int):
	thehash = thehash % ar.size()
	return ar[thehash]

static func pickWeightedDict(ar:Dictionary):
	if(ar.is_empty()):
		return null
	
	var sum = 0.0
	for w in ar:
		sum += max(ar[w], 0.0)
	
	var r:float = randf_range(0.0, sum)
	for i in ar:
		r -= max(ar[i], 0.0)
		if r <= 0.0:
			return i
			
	return ar.keys()[0]
