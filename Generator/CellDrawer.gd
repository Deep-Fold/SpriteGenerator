extends Node2D

var cells = []
var draw_size = 6
var speed = 5
var lifetime = 0
var is_eye = false
var amplitude = 0
var movement = true

func _ready():
	amplitude = (lifetime % 5 + 2) * 5.0

func set_cells(c):
	cells = c

	update()

func _draw():
	var average = Vector2()
	var size = 0
	var eye_cutoff = 0.0
	if is_eye:
		for c in cells:
			size += 1
			average += c.position
		eye_cutoff = sqrt(float(size)) * 0.3
	
	average = average / cells.size()
	
	for c in cells:
		draw_rect(Rect2(c.position.x*draw_size, c.position.y*draw_size, draw_size, draw_size), c.color)
		
		if is_eye && average.distance_to(c.position) < eye_cutoff:
			draw_rect(Rect2(c.position.x*draw_size, c.position.y*draw_size, draw_size, draw_size), c.color.darkened(0.85))

func set_speed(s):
	speed = s

func _process(delta):
	if movement:
		lifetime += delta * 4.0
		position.y = sin(lifetime) * 20

func set_eye():
	is_eye = true
	update()
