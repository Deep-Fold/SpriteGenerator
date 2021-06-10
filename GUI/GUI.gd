extends Control

onready var sprite_generator = preload("res://Generator/SpriteGenerator.gd").new()
onready var name_generator = preload("res://Generator/NameGenerator.gd").new()
onready var group_drawer = preload("res://Generator/GroupDrawer.tscn")


var seed_list = []
var seed_index = 0
var outline = true
var lifetime = 0
var size = Vector2(45,45)

func _process(delta):
	lifetime += delta * 0.025
	$ColorRect.color = Color.from_hsv(fmod(lifetime, 1.0), 0.2, 0.8)

func _ready():
	seed_list.append(_get_next_seed())
	_redraw()

func _input(event):
	if event.is_action_pressed("ui_right"):
		_shift_seeds(1)
	if event.is_action_pressed("ui_left"):
		_shift_seeds(-1)

func _shift_seeds(shift):
	seed_index += shift
	seed_index = max(seed_index, 0)
	if seed_index == 0:
		$Left.visible = false
	else:
		$Left.visible = true
		

	if seed_index >= seed_list.size():
		seed_list.append(_get_next_seed())
	_redraw()

var draw_rect = Vector2(400, 400)

func _redraw():
	for c in $CenterContainer/Control.get_children():
		c.queue_free()
	
	var gd = _get_group_drawer(false)
	
	$CenterContainer/Control.add_child(gd)
	$Label.text = name_generator.get_name()
	

func _get_group_drawer(var pixel_perfect = false):
	var sprite_groups = sprite_generator.get_sprite(seed_list[seed_index], size, 12,  outline)
	var gd = group_drawer.instance()
	gd.groups = sprite_groups.groups
	gd.negative_groups = sprite_groups.negative_groups
	
	var draw_size = min((draw_rect.x / size.x), (draw_rect.y / size.y))
	if pixel_perfect:
		gd.draw_size = 1
	else:
		gd.draw_size = draw_size
		gd.position = Vector2(-draw_size *size.x*0.5, -draw_size *size.y*0.5)
	
	return gd

func _get_next_seed():
	randomize()
	return randi()


func _on_Left_pressed():
	_shift_seeds(-1)


func _on_Right_pressed():
	_shift_seeds(1)



func _on_CloseSettings_pressed():
	$Settings.visible = false
	$OpenSettings.visible = true
	$ExportPanel.visible = true


func _on_ToggleOutline_pressed():
	outline = !outline
	if outline:
		$Settings/VBoxContainer/HBoxContainer3/ToggleOutline.text = "On"
	else:
		$Settings/VBoxContainer/HBoxContainer3/ToggleOutline.text = "Off"


func _on_OpenSettings_pressed():
	$OpenSettings.visible = false
	$ExportPanel.visible = false
	$Settings.visible = true


func _on_ExportButton_pressed():
	for c in $Viewport.get_children():
		c.queue_free()
	var gd = _get_group_drawer(true)
	gd.disable_movement()
	gd.position = Vector2(1,1)
	$Viewport.add_child(gd)
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	export_image()
	

func export_image():
	var img = Image.new()
	img.create(size.x + 2, size.y + 2, false, Image.FORMAT_RGBA8)
	var viewport_img = $Viewport.get_texture().get_data()

	img.blit_rect(viewport_img, Rect2(0,0,size.x+2,size.y+2), Vector2(0,0))

	save_image(img)

func save_image(img):
	if OS.get_name() == "HTML5" and OS.has_feature('JavaScript'):
		var filesaver = get_tree().root.get_node("/root/HTML5File")
		filesaver.save_image(img, $Label.text)
	else:
		if OS.get_name() == "OSX":
			img.save_png("user://" + $Label.text + ".png")
		else:
			img.save_png("res://" + $Label.text + ".png")
		

func _on_Height_value_changed(value):
	size.y = clamp(round(value), 10, 128)


func _on_Width_value_changed(value):
	size.x = clamp(round(value), 10, 128)
