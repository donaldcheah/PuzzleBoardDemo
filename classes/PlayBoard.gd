extends Node2D

class_name PlayBoard

const greenTex:Texture = preload("res://assets/green_64.png")
const greyTex:Texture = preload("res://assets/grey_64.png")
const redTex:Texture = preload("res://assets/red_64.png")
const yellowTex:Texture = preload("res://assets/yellow_64.png")

const TILE_SIZE = 64
const DIVIDER_SIZE = 2


var L0:Node2D = Node2D.new() # bottom, grey tiles
var L1:Node2D = Node2D.new() # placed yellow tiles
var L2:Node2D = Node2D.new() # red/green tiles
var L3:Node2D = Node2D.new() # top, dragging yellow tiles, idle yellow tiles

# X,Y size of board
var board_index_size = Vector2(4,4)
var boardPos=Vector2(350,100)
var board_space = [] #fill space with 1 for occupied and 0 for empty

# list of sprites used to show red or green color
# to be placed in L2 layer
var color_effect_sprites = []

# TileGroups
var tileGroupData=[
	{
		'pos':Vector2(200,400),
		'form':[
			[1,1,1],
			[1,0,0]
		]
	},
	{
		'pos':Vector2(720,100),
		'form':[
			[0,1,0],
			[1,1,1]
		]
	},
	{
		'pos':Vector2(680,400),
		'form':[
			[1,1,1]
		]
	},
	{
		'pos':Vector2(100,100),
		'form':[
			[1]
		]
	},
	{
		'pos':Vector2(60,190),
		'form':[
			[1,1],
			[0,1],
			[0,1]
		]
	}
]

# should be in L3, idle or dragging off the board
var tile_groups_idle = []

var is_dragging = false
var prev_mouse_pos = Vector2.ZERO
var pointing_tile_group:TileGroup = null

var last_valid_num = 0

var label:Label
var labelText = "%d / %d"
var labelTextWin = "You Win!"

func init_board():
	for y in board_index_size.y:
		var row = []
		var space = []
		for x in board_index_size.x:
			var spr = Sprite.new()
			spr.centered=false
			spr.texture = greyTex
			spr.position = Vector2(x*(TILE_SIZE+DIVIDER_SIZE)+boardPos.x,y*(TILE_SIZE+DIVIDER_SIZE)+boardPos.y)
			L0.add_child(spr)
			row.append(spr)
			space.append(0)
		board_space.append(space)

func init_board_color_effect_tiles():
	for y in board_index_size.y:
		var row = []
		for x in board_index_size.x:
			var spr = Sprite.new()
			spr.centered=false
			spr.texture = null
			spr.position = Vector2(x*(TILE_SIZE+DIVIDER_SIZE)+boardPos.x,y*(TILE_SIZE+DIVIDER_SIZE)+boardPos.y)
			L2.add_child(spr)
			row.append(spr)
		color_effect_sprites.append(row)

func init_tile_groups():
	for data in tileGroupData:
		var tg = TileGroup.new()
		tg.tileTex = yellowTex
		tg.form = data.form
		tg.ori_pos = data.pos
		L3.add_child(tg)
		tile_groups_idle.append(tg)

func _ready():
	
	add_child(L0)
	add_child(L1)
	add_child(L2)
	add_child(L3)
	
	init_board()
	init_tile_groups()
	
	init_board_color_effect_tiles()
	
	label = Label.new()
	label.rect_position = boardPos
	label.rect_position.y-=20
	add_child(label)
	update_label_text()

func get_num_board_occupied():
	var num = 0
	for y in board_space.size():
		for x in board_space[y].size():
			if board_space[y][x] == 1:
				num += 1
	return num
	
func update_label_text():
	var num = get_num_board_occupied()
	var totalNum = board_index_size.x*board_index_size.y
	if num == totalNum:
		label.text = labelTextWin
	else:
		label.text = labelText % [num, totalNum]

func _input(event):
	if is_dragging && event is InputEventMouseMotion:
		var dxy = event.position - prev_mouse_pos
		pointing_tile_group.position += dxy
		prev_mouse_pos = event.position
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				if pointing_tile_group != null:
					is_dragging = true
					prev_mouse_pos = event.position
					# if tile group is already on the board, 
					# move back to L3 layer and remove the occupied status on board
					if L1.get_children().has(pointing_tile_group):
						L1.remove_child(pointing_tile_group)
						L3.add_child(pointing_tile_group)
						for p in pointing_tile_group.get_center_pos_of_tiles():
							# turns p from screen space to board-index space
							var rel_index = ((p - boardPos)/(TILE_SIZE+DIVIDER_SIZE)).floor()
							board_space[rel_index.y][rel_index.x] = 0
							update_label_text()
						
			else:
				if is_dragging:
					is_dragging = false
					if last_valid_num == pointing_tile_group.num_tiles():
						place_tile_group_on_board(pointing_tile_group)
						pass
					else:# is not all valid, place back to ori pos
						pointing_tile_group.position = pointing_tile_group.ori_pos
						turn_effect_valid_invalid({"valid":[],"invalid":[]})

# return the number of valid points on board
func check_board_points_valid(arr):
	var boardRect= Rect2(boardPos,board_index_size*Vector2(TILE_SIZE+DIVIDER_SIZE,TILE_SIZE+DIVIDER_SIZE))
	var numValid = 0
	for p in arr:
		if boardRect.has_point(p):
			var rel_point = p - boardPos
			var rel_index = (rel_point/(TILE_SIZE+DIVIDER_SIZE)).floor()
			if board_space[rel_index.y][rel_index.x] == 0:
				numValid += 1			
	return numValid

# takes in a list of points, returns valid and invalid index points on the board
# not return any for points off board
func get_points_valid_invalid(arr):
	var boardRect= Rect2(boardPos,board_index_size*Vector2(TILE_SIZE+DIVIDER_SIZE,TILE_SIZE+DIVIDER_SIZE))
	var result = {
		"valid":[],
		"invalid":[]
	}
	for p in arr:
		if boardRect.has_point(p):
			var rel_point = p - boardPos
			var rel_index = (rel_point/(TILE_SIZE+DIVIDER_SIZE)).floor()
			if board_space[rel_index.y][rel_index.x] == 0:
				result.valid.append(rel_index)
			else:
				result.invalid.append(rel_index)

	return result

func turn_effect_valid_invalid(result):
	var valids = result.valid
	var invalids = result.invalid
	for y in board_index_size.y:
		for x in board_index_size.x:
			var target = Vector2(x,y)
			if valids.has(target):
				color_effect_sprites[y][x].texture = greenTex
			elif invalids.has(target):
				color_effect_sprites[y][x].texture = redTex
			else:
				color_effect_sprites[y][x].texture = null

func place_tile_group_on_board(tg:TileGroup):
	# remove tg from L3 and add to L1
	L3.remove_child(tg)
	L1.add_child(tg)
	# snap tg to nearest square postion on board
	snap_tile_group_to_board(tg)
	
	# mark the occupied tiles as taken

	for p in tg.get_center_pos_of_tiles():
		# turns p from screen space to board-index space
		var rel_index = ((p - boardPos)/(TILE_SIZE+DIVIDER_SIZE)).floor()
		board_space[rel_index.y][rel_index.x] = 1
	
	# reset the effect tiles to empty
	turn_effect_valid_invalid({"valid":[],"invalid":[]})
	update_label_text()


func snap_tile_group_to_board(tg:TileGroup):
	var sum = TILE_SIZE+DIVIDER_SIZE
	var rel_pos = tg.position - boardPos
	rel_pos+= Vector2(sum/2,sum/2)
	rel_pos /= sum
	rel_pos  = rel_pos.floor()
	rel_pos *= sum
	tg.position = rel_pos + boardPos

# takes in points relative to board, use point - boardPos before using here
func points_to_board_indexes(points):
	var arr = []
	for p in points:
		arr.append((p/(TILE_SIZE+DIVIDER_SIZE)).floor())
	return arr


func _process(delta):
	if !is_dragging:
		# free moving mouse on screen, check which TileGroup the mouse is currently over
		var mouseOverTG:TileGroup = null
		for tg in tile_groups_idle:
			if tg.is_mouse_over():
				mouseOverTG = tg
				break
		pointing_tile_group = mouseOverTG
	else:# it is_dragging, 
		var arrPos = pointing_tile_group.get_center_pos_of_tiles()
		# cross check the points with board to see how many points are valid
		var result = get_points_valid_invalid(arrPos)

		turn_effect_valid_invalid(result)
		
		last_valid_num = result.valid.size()

