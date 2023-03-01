extends Node

class_name Dk

var deckTexture
var deckPos:Vector2
var tile_groups = []

var revealIndex = -1
var spr

func _ready():
	spr = Sprite.new()
	spr.centered=false
	spr.texture = deckTexture
	spr.position = deckPos
	
	add_child(spr)
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				var rect:Rect2 = spr.get_rect()
				rect.position += deckPos
				if rect.has_point(event.position):
					print('click in deck')
					reveal_next()

func reveal_next():
	if revealIndex == tile_groups.size()-1:
		return
	revealIndex += 1
	var tg:TG = tile_groups[revealIndex]
	tg.ori_pos = spr.position
	print('pos:',tg.position)
	add_child(tg)
	
	if revealIndex == tile_groups.size()-1:
		remove_child(spr)

