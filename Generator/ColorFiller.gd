extends Node

var noise
var noise2

func _init():
	noise = OpenSimplexNoise.new()
	noise2 = OpenSimplexNoise.new()
	noise2.octaves = 3
	noise2.period = 40.0
	noise2.persistence = 0.4
	noise2.lacunarity = 3.0
	
	noise.octaves = 5
	noise.period = 30.0
	noise.persistence = 0.4
	noise.lacunarity = 3.0

func fill_colors(map, colorscheme, eye_colorscheme, n_colors, outline = true):
	noise.seed = randi()
	noise2.seed = randi()
	var groups = []
	var negative_groups = []
	
	groups = _flood_fill(map, groups, colorscheme, eye_colorscheme, n_colors, false, outline)
	negative_groups = _flood_fill_negative(map, negative_groups, colorscheme, eye_colorscheme, n_colors, outline)
	
	return {
		"groups": groups,
		"negative_groups": negative_groups
	}

func _flood_fill_negative(map, groups, colorscheme, eye_colorscheme, n_colors, outline):
	var negative_map = []
	for x in range(0, map.size()):
		var arr = []
		for y in range(0, map[x].size()):
			arr.append(!_get_at_pos(map, Vector2(x,y)))
		negative_map.append(arr)
	
	return _flood_fill(negative_map, groups, colorscheme, eye_colorscheme, n_colors, true, outline)

# myd overcomplicated way of a flood fill algorithm
func _flood_fill(map, groups, colorscheme, eye_colorscheme, n_colors, is_negative = false, outline = true):
	# checked_map holds a 2d map of all the cells and if they have been checked in the flood fill yet
	var checked_map = []
	for x in range(0, map.size()):
		var arr = []
		for _y in range(0, map[x].size()):
			arr.append(false)
		checked_map.append(arr)
	
	# bucket is all the cells that have been found through flood filling and whose neighbours will be checked next
	var bucket = []
	for x in range(0, map.size()):
		for y in range(0, map[x].size()):
			if !checked_map[x][y]: # haven't checked this cell yet
				checked_map[x][y] = true
				
				if map[x][y]: # if this cell is actually filled in the map
					bucket.append(Vector2(x,y))
					
					var group = {
						"arr": [],
						"valid": true
					}
					
					while (bucket.size() > 0): # go through remaining cells in bucket
						var pos = bucket.pop_back()
						
						# get neighbours
						var right = _get_at_pos(map, pos + Vector2(1, 0))
						var left = _get_at_pos(map, pos + Vector2(-1, 0))
						var down = _get_at_pos(map, pos + Vector2(0, 1))
						var up = _get_at_pos(map, pos + Vector2(0, -1))
						
						if is_negative: # dont want negative groups that touch the edge of the sprite
							if left == null || up == null || down == null || right == null:
								group.valid = false
						
						# I also do a coloring step in this flood fill, speeds up processing a bit instead of doing it seperately
						var col = _get_color(map, pos, is_negative, right, left, down, up, colorscheme, eye_colorscheme, n_colors, outline, group)
						
						group.arr.append({
							"position": pos,
							"color": col
						})
						
						# add neighbours to bucket to check
						if right && !checked_map[pos.x + 1][pos.y]:
							bucket.append(pos + Vector2(1, 0))
							checked_map[pos.x + 1][pos.y] = true
						if left && !checked_map[pos.x - 1][pos.y]:
							bucket.append(pos + Vector2(-1, 0))
							checked_map[pos.x - 1][pos.y] = true
						if down && !checked_map[pos.x][pos.y + 1]:
							bucket.append(pos + Vector2(0, 1))
							checked_map[pos.x][pos.y+1] = true
						if up && !checked_map[pos.x][pos.y - 1]:
							bucket.append(pos + Vector2(0, -1))
							checked_map[pos.x][pos.y-1] = true
					groups.append(group)
	return groups

# excuse the gigantic amount of parameters here please
func _get_color(map, pos, is_negative, right, left, down, up, colorscheme, eye_colorscheme, n_colors, outline, group):
	var col_x = ceil(abs(pos.x - (map.size()-1)*0.5))
	var n = pow(abs((noise.get_noise_2d(col_x, pos.y))), 1.5) * 3.0
	var n2 = pow(abs((noise2.get_noise_2d(col_x, pos.y))), 1.5) * 3.0
	
	# highlight colors based on amount of neighbours
	if !down:
		if is_negative:
			n2 -= 0.1
		else:
			n -= 0.45
		n*= 0.8
		if outline:
			group.arr.append({
				"position": pos + Vector2(0, 1),
				"color": Color(0,0,0,1)
			})
	if !right:
		if is_negative:
			n2 += 0.1
		else:
			n += 0.2
		n*=1.1
		if outline:
			group.arr.append({
				"position": pos + Vector2(1, 0),
				"color": Color(0,0,0,1)
			})
	if !up:
		if is_negative:
			n2 +=0.15
		else:
			n += 0.45
		n*=1.2
		if outline:
			group.arr.append({
				"position": pos + Vector2(0, -1),
				"color": Color(0,0,0,1)
			})
	if !left:
		if is_negative:
			n2 += 0.1
		else:
			n += 0.2
		n*=1.1
		if outline:
				group.arr.append({
					"position": pos + Vector2(-1, 0),
					"color": Color(0,0,0,1)
				})

	# highlight colors if the difference in colors between neighbours is big
	var c_0 = colorscheme[floor(noise.get_noise_2d(col_x, pos.y) * (n_colors-1))]
	var c_1 = colorscheme[floor(noise.get_noise_2d(col_x, pos.y - 1) * (n_colors-1))]
	var c_2 = colorscheme[floor(noise.get_noise_2d(col_x, pos.y + 1) * (n_colors-1))]
	var c_3 = colorscheme[floor(noise.get_noise_2d(col_x - 1, pos.y) * (n_colors-1))]
	var c_4 = colorscheme[floor(noise.get_noise_2d(col_x + 1, pos.y) * (n_colors-1))]
	var diff = ((abs(c_0.r - c_1.r) + abs(c_0.g - c_1.g) + abs(c_0.b - c_1.b)) + 
				(abs(c_0.r - c_2.r) + abs(c_0.g - c_2.g) + abs(c_0.b - c_2.b)) + 
				(abs(c_0.r - c_3.r) + abs(c_0.g - c_3.g) + abs(c_0.b - c_3.b)) + 
				(abs(c_0.r - c_4.r) + abs(c_0.g - c_4.g) + abs(c_0.b - c_4.b)))
	if diff > 2.0:
		n+= 0.3
		n*= 1.5
		n2+= 0.3
		n2*= 1.5

	# actually choose a color
	n = clamp(n, 0.0, 1.0)
	n = floor(n * (n_colors-1))
	n2 = clamp(n2, 0.0, 1.0)
	n2 = floor(n2 * (n_colors-1))
	var col = colorscheme[n]
	
	if is_negative:
		col = eye_colorscheme[n2]
	return col

func _get_at_pos(map, pos):
	if pos.x < 0 || pos.x >= map.size() || pos.y < 0 || pos.y >= map[pos.x].size():
		return null
	
	return map[pos.x][pos.y]
