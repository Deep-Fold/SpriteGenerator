extends Node

var birth_limit = 5
var death_limit = 4
var n_steps = 4

func do_steps(map):
	for i in n_steps:
		map = _step(map)
	return map

func _step(map):
	var dup = map.duplicate(true)
	for x in range(0, map.size()):
		for y in range(0, map[x].size()):
			var cell = dup[x][y]
			var n = _get_neighbours(map, Vector2(x,y))
			if cell && n < death_limit:
				dup[x][y] = false
			elif !cell && n > birth_limit:
				dup[x][y] = true
	return dup

func _get_neighbours(map, pos):
	var count = 0
	
	for i in range(-1,2):
		for j in range(-1,2):
			if !(i == 0 && j ==0):
				if _get_at_pos(map, pos + Vector2(i,j)):
					count += 1

	return count

func _get_at_pos(map, pos):
	if pos.x < 0 || pos.x >= map.size() || pos.y < 0 || pos.y >= map[pos.x].size():
		return null
	
	return map[pos.x][pos.y]
