extends Node2D

class_name TileGroup

#signal fires when the TG is being dragged and released
signal release_tile_group(tileGroup)

#signal fires when the TG is being dragged
signal drag_tile_group(tileGroup)

var tileSize:int
var dividerSize:int

#var tileTex:Texture
var tileTextureMap:Dictionary

var ori_pos:Vector2
var ori_pos_is_on_board:bool=false
var form

var tiles=[]

var shadow_tiles=[]

var is_dragging = false
var prevPos = Vector2.ZERO

func _ready():
	for y in form.size():
		for x in form[y].size():
			if typeof(form[y][x]) == TYPE_STRING:
				var color = form[y][x]
				var shadow = Sprite.new()
				shadow.centered = false
				shadow.texture = tileTextureMap[color]
				shadow.offset = Vector2(5,5)
				shadow.modulate.a = 0.2
				shadow.modulate.r = 0
				shadow.modulate.g = 0
				shadow.modulate.b = 0
				shadow.z_index = -0.1
				shadow.z_as_relative = true
				shadow.position = Vector2(
					x*(tileSize+dividerSize),
					y*(tileSize+dividerSize)
				)
				shadow_tiles.append(shadow)
				add_child(shadow)
				
				var spr = Sprite.new()
				spr.centered=false
				spr.texture = tileTextureMap[color]
				spr.position = Vector2(
					x*(tileSize+dividerSize),
					y*(tileSize+dividerSize)
				)
				tiles.append(spr)
				add_child(spr)
				
	position = ori_pos


func show_shadow():
	for spr in shadow_tiles:
		spr.visible = true
		
func hide_shadow():
	for spr in shadow_tiles:
		spr.visible = false


func _input(event):
	if is_dragging && event is InputEventMouseMotion:
		var pos = get_viewport().canvas_transform.affine_inverse().xform(event.position)
		var dxy = pos - prevPos
		position += dxy
		prevPos = pos
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				var pos = get_viewport().canvas_transform.affine_inverse().xform(event.position)
				if is_point_in_tiles(pos):
					is_dragging=true
					prevPos = pos
					emit_signal("drag_tile_group",self)
					
					#to add the TG back to the top of the list of displays
					var parent = get_parent()
					if parent!=null:
						parent.remove_child(self)
						parent.add_child(self)
					
					get_tree().set_input_as_handled()
			else:
				if is_dragging:
					is_dragging = false
					emit_signal("release_tile_group",self)

func get_all_tile_centers():
	var center_pos = []
	for tile in tiles:
		center_pos.append(position + tile.position + Vector2(tileSize/2,tileSize/2))
	return center_pos

func get_all_tile_rects():
	var rects = []
	for spr in tiles:
		var r = spr.get_rect()
		r.position += position+spr.position
		rects.append(r)
	return rects

func is_point_in_tiles(p:Vector2):
	for spr in tiles:
		var tileRect:Rect2 = spr.get_rect()
		tileRect.position = tileRect.position + position + spr.position
		if tileRect.has_point(p):
			return true
	return false

func snap_back_to_prev_position():
	position = ori_pos
	if(ori_pos_is_on_board):
		hide_shadow()
		var b = get_tree().get_nodes_in_group("Board")[0]
		#if b.has_method('place_tile_group'):
		b.place_tile_group(self)


func update_prev_position(new_position:Vector2,is_on_board:bool):
	ori_pos = new_position
	ori_pos_is_on_board = is_on_board

func get_calc_size():
	var calc_size=Vector2(
		tileSize * form[0].size(),
		tileSize * form.size()
	)
	return calc_size

