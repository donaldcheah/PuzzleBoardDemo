extends Node

class_name Deck

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
	reveal_next()

func on_tile_group_placed(tg:TileGroup):
	print('in deck on_tile_group_placed')
	if tg == tile_groups[revealIndex]:
		var has_intersect = false
		
		var deckRect = spr.get_rect()
		deckRect.position += spr.position
		
		var tg_tiles = tg.tiles
		for t in tg_tiles:
			var tileRect = t.get_rect()
			tileRect.position = tileRect.position + tg.position + t.position
			if tileRect.intersects(deckRect):
				has_intersect=true
				break
			
		if !has_intersect:
			reveal_next()

func reveal_next():
	if revealIndex == tile_groups.size()-1:
		return
	revealIndex += 1
	var tg:TileGroup = tile_groups[revealIndex]

	var calc_size = tg.get_calc_size()
	
	var place_pos = Vector2(
		spr.position.x+spr.texture.get_size().x/2-calc_size.x/2,
		spr.position.y+spr.texture.get_size().y/2-calc_size.y/2
	)
	
	tg.update_prev_position(place_pos,false)
	add_child(tg)
	
	if revealIndex == tile_groups.size()-1:
		remove_child(spr)

