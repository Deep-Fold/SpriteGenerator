extends Node

var map_generator
var cellular_automata
var colorscheme_generator
var color_filler
var group_drawer

func _init():
	map_generator = load("res://Generator/MapGenerator.gd").new()
	cellular_automata = load("res://Generator/CellularAutomata.gd").new()
	colorscheme_generator = load("res://Generator/ColorSchemeGenerator.gd").new()
	color_filler = load("res://Generator/ColorFiller.gd").new()
	group_drawer = load("res://Generator/GroupDrawer.tscn")

func get_sprite(sd, size, n_colors, outline = true):
	seed(sd)
	var map = map_generator.generate_new(size)
	
	map = cellular_automata.do_steps(map)
	var scheme = colorscheme_generator.generate_new_colorscheme(n_colors)
	var eye_scheme = colorscheme_generator.generate_new_colorscheme(n_colors)
	var all_groups = color_filler.fill_colors(map, scheme, eye_scheme, n_colors, outline)
	var g_draw = group_drawer.instance()
	g_draw.groups = all_groups.groups
	g_draw.negative_groups = all_groups.negative_groups
	return g_draw
	
