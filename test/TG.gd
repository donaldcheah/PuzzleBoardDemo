extends Node2D

class_name TG

#signal fires when the TG is being dragged and released
signal release_tile_group(tileGroup)

#signal fires when the TG is being dragged
signal drag_tile_group(tileGroup)

var tileSize:int
var dividerSize:int

var tileTex:Texture
var ori_pos:Vector2
var form

var tiles=[]

var is_dragging = false
var prevPos = Vector2.ZERO

func _ready():
	for y in form.size():
		for x in form[y].size():
			if form[y][x] == 1:
				var spr = Sprite.new()
				spr.centered=false
				spr.texture = tileTex
				spr.position = Vector2(
					x*(tileSize+dividerSize),
					y*(tileSize+dividerSize)
				)
				tiles.append(spr)
				add_child(spr)
	position = ori_pos

func _input(event):
	if is_dragging && event is InputEventMouseMotion:
		var dxy = event.position - prevPos
		position += dxy
		prevPos = event.position
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				if is_point_in_tiles(event.position):
					is_dragging=true
					prevPos = event.position
					emit_signal("drag_tile_group",self)
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

func is_point_in_tiles(p):
	for spr in tiles:
		var tileRect:Rect2 = spr.get_rect()
		tileRect.position = tileRect.position + position + spr.position
		if tileRect.has_point(p):
			return true
	return false
