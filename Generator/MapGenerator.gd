extends Node

func generate_new(size):
	var map = _get_random_map(size)
	for i in 2:
		_random_walk(size, map)
	return map

func _random_walk(size, map):
	var pos = Vector2(randi() % int(size.x), randi() % int(size.y))
	for i in 100:
		_set_at_pos(map, pos, true)
		
		_set_at_pos(map, Vector2(size.x - pos.x - 1, pos.y), true)
		pos += Vector2(randi()%3-1,randi()%3-1)

func _get_random_map(size):
	var map = []
	for x in size.x:
		map.append([])
	
	for x in range(0, ceil(size.x * 0.5)):
		var arr = []
		for y in range(0, size.y):
			arr.append(rand_bool(0.48))
			
			# When close to center increase the cances to fill the map, so it's more likely to end up with a sprite that's connected in the middle
			var to_center = (abs(y - size.y * 0.5) * 2.0) / size.y
			if x == floor(size.x*0.5) - 1 || x == floor(size.x*0.5) - 2:
				if rand_range(0.0, 0.4) > to_center:
					arr[y] = true

		map[x] = (arr.duplicate(true))
		map[size.x - x - 1] = (arr.duplicate(true))
	
	
#	for x in range(0, map.size()):
#		for y in range(0, map[x].size()):
#			if rand_range(0.0, 1.0) > 0.99:
#				map[x][y] = true
			
	return map

func _set_at_pos(map, pos, val):
	if pos.x < 0 || pos.x >= map.size() || pos.y < 0 || pos.y >= map[pos.x].size():
		return false
	
	map[pos.x][pos.y] = val
	
	return true

func rand_bool(chance):
	return rand_range(0.0, 1.0) > chance
