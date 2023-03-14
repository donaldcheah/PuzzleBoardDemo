extends Node2D

class_name Board

var redTex:Texture
var greenTex:Texture
var tileTex:Texture
var tileSize:int
var dividerSize:int

var form
var boardPos#contains the xIndex, yIndex
var on_screen_pos:Vector2 #the actual board position after multipling with tileSize

var L0:Node2D #for grey tiles
var L1:Node2D #for placed yellow tile groups
var L2:Node2D #for green/red tiles
#L3 could just use parent.add_child

#array of sprites representing the board
var tiles=[]
var board_space = []

var placed_tile_groups = []

#2D array of sprites used to show the red/green tile effects
var color_effect_sprites=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	init_layers()
	
	init_board()
	
	init_board_color_effect_tiles()

func init_layers():
	L0 = Node2D.new()
	L1 = Node2D.new()
	L2 = Node2D.new()
	add_child(L0)
	add_child(L1)
	add_child(L2)

func init_board():
	on_screen_pos = Vector2(
		boardPos.xIndex,
		boardPos.yIndex
	)
	"""
	on_screen_pos = Vector2(
		boardPos.xIndex * tileSize,
		boardPos.yIndex * tileSize
	)
	"""
	for y in form.size():
		var row = []
		for x in form[y].size():
			row.append(0)
			if(form[y][x] == 1):
				var spr = Sprite.new()
				spr.centered=false
				spr.texture = tileTex
				spr.position = Vector2(
					on_screen_pos.x + x *(tileSize+dividerSize),
					on_screen_pos.y + y * (tileSize+dividerSize)
				)
				tiles.append(spr)
				L0.add_child(spr)#grey tiles go in L0
		board_space.append(row)

func init_board_color_effect_tiles():
	var sum_size=tileSize + dividerSize
	for y in form.size():
		var row = []
		for x in form[y].size():
			if form[y][x] == 1:
				var spr = Sprite.new()
				spr.centered=false
				spr.texture = null
				#spr.modulate.a = 0.5
				spr.position = Vector2(x*(sum_size)+on_screen_pos.x,y*(sum_size)+on_screen_pos.y)
				L2.add_child(spr) #effect tiles go in L2
				row.append(spr)
			else:
				row.append(null)
		color_effect_sprites.append(row)


func has_intersect_rects(rects):
	for spr in tiles:
		for rect in rects:
			var sprRect:Rect2 = spr.get_rect()
			sprRect.position += spr.position
			if sprRect.intersects(rect):
				return true
	return false

func num_center_points_on_board(centerPositions):
	var match_count = 0
	for spr in tiles:
		for pos in centerPositions:
			var sprRect = spr.get_rect()
			sprRect.position = sprRect.position + spr.position
			#print('check agains pos on board:',sprRect)
			if sprRect.has_point(pos):
				var sprIndexPos = ((spr.position-on_screen_pos)/Vector2(
					tileSize+dividerSize,
					tileSize+dividerSize
				)).floor()
				#print('sprIndexPos:',sprIndexPos)
				if board_space[sprIndexPos.y][sprIndexPos.x] == 0:
					match_count += 1
					break

	return match_count

func place_tile_group(tg:TileGroup):
	#gets the relative position of TG to the board's screen position
	var dxy = tg.position - on_screen_pos
	#adds half of tile size for pointing to the center of the tile
	dxy += Vector2((tileSize)/2,(tileSize)/2) 
	
	#divides the relative position with tile and divider size to get nearest position
	var dxyIndex = (dxy/Vector2(
		(tileSize+dividerSize),
		(tileSize+dividerSize)
	)).floor()
	tg.position = on_screen_pos+dxyIndex*(tileSize+dividerSize)
	tg.update_prev_position(tg.position,true)
	
	tg.connect("drag_tile_group",self,"on_tile_group_dragged")
	placed_tile_groups.append(tg)
	
	if tg.get_parent()!=null:
		tg.get_parent().remove_child(tg)
	L1.add_child(tg)
	
	# should add the tile group's space to board_space
	var centers = tg.get_all_tile_centers()
	for p in centers:
		var rel_index = ((p-on_screen_pos)/(tileSize+dividerSize)).floor()
		board_space[rel_index.y][rel_index.x]=1
	
	tg.hide_shadow()
	
#used when placed tile group leaves the board
func on_tile_group_dragged(tg:TileGroup):
	placed_tile_groups.erase(tg)
	tg.disconnect("drag_tile_group",self,"on_tile_group_dragged")
	#should also remove the occupied space in board_space
	var centers = tg.get_all_tile_centers()
	for p in centers:
		var rel_index = ((p-on_screen_pos)/(tileSize+dividerSize)).floor()
		board_space[rel_index.y][rel_index.x]=0
	if tg.get_parent()!=null:
		tg.get_parent().remove_child(tg)
	get_parent().add_child(tg)
	tg.show_shadow()

#used in main/test scene, when a tile group is being dragged around
#to show the green/red effect on board for the tg supplied
func show_effect_on_board(tg:TileGroup):
	var centers = tg.get_all_tile_centers()
	var result = {
		"valid":[],
		"invalid":[]
	}
	for p in centers:
		var rel_index = ((p-on_screen_pos)/(tileSize+dividerSize)).floor()
		if rel_index.x<0 || rel_index.y<0 || rel_index.x>=board_space[0].size()||rel_index.y>=board_space.size():
			continue
		if board_space[rel_index.y][rel_index.x] == 1:
			#is occupied, show red
			result.invalid.append(rel_index)
		else:
			#is free, show green
			result.valid.append(rel_index)
	turn_effect_valid_invalid(result)

#result = {valid:[],invalid:[]} array of Vector2, and whatever not in valid/invalid would be transparent
func turn_effect_valid_invalid(result):
	var valids = result.valid
	var invalids = result.invalid
	for y in form.size():
		for x in form[y].size():
			var target = Vector2(x,y)
			var target_sprite = color_effect_sprites[y][x]
			if target_sprite == null:
				continue
			if valids.has(target):
				color_effect_sprites[y][x].texture = greenTex
			elif invalids.has(target):
				color_effect_sprites[y][x].texture = redTex
			else:
				color_effect_sprites[y][x].texture = null

func reset_effects_on_board():
	turn_effect_valid_invalid({
		"valid":[],
		"invalid":[]
	})

func get_calc_size():
	var calc_size=Vector2(
		tileSize * form[0].size(),
		tileSize * form.size()
	)
	return calc_size
