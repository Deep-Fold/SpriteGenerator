extends Node2D

var groups = []
var negative_groups = []
var draw_size = 10
var movement = true
onready var cell_drawer = preload("res://Generator/CellDrawer.tscn")

func _ready():
	var largest = 0
	for g in groups:
		largest = max(largest, g.arr.size())
	
	for i in range(groups.size() - 1, -1, -1):
		var g = groups[i].arr
		groups[i]["start_time"] = g.size() + groups.size()
		if g.size() >= largest * 0.25:
			var cell = cell_drawer.instance()
			cell.set_cells(g)
			cell.lifetime = groups[i].start_time
			cell.movement = movement
			
			add_child(cell)
		else:
			groups.erase(g)

	for g in negative_groups:
		if g.valid:
			var touching = false
			for g2 in groups:
				if group_is_touching_group(g.arr,g2.arr):
					touching = true
					if g.has("start_time"):
						g2["start_time"] = g["start_time"]
					else:
						g["start_time"] = g2["start_time"]
						
			if touching:
				var cell = cell_drawer.instance()
				cell.set_cells(g.arr)

				cell.lifetime = g.start_time
				cell.movement = movement
				add_child(cell)

				if (g.arr.size() + negative_groups.size()) % 5 >= 3:
					cell.set_eye()
	
	for c in get_children():
		c.draw_size = draw_size

func disable_movement():
	movement = false

func group_is_touching_group(g1, g2):
	for c in g1:
		for c2 in g2:
			if c.position.x == c2.position.x:
				if c.position.y == c2.position.y + 1 || c.position.y == c2.position.y - 1:
					return true
			elif c.position.y == c2.position.y:
				if c.position.x == c2.position.x + 1 || c.position.x == c2.position.x - 1:
					return true
			
	
	return false
