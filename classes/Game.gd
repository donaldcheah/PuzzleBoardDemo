extends Node2D

class_name Game


var TILE_SIZE = 24
var DIVIDER_SIZE = 1

#TODO: should be gotten from .json
var tileGroupData=[
	{
		'form':[
			['#ff0000'],
		]
	},
	{
		'form':[
			['#00ff00','#00ff00','#00ff00'],
			[0,'#00ff00',0]
		]
	},
	{
		'form':[
			[0,'#0000ff'],
			[0,'#0000ff'],
			['#0000ff','#0000ff']
		]
	}
]
var boardData = {
	'position':{
		'xIndex':10,
		'yIndex':5
	},
	'form':[
		[1,0,1],
		[1,0,1],
		[1,1,1],
		[1,1,0]
	]
}

var board:Board

var deck:Deck

var boardTex:Texture
var greenTex:Texture
var redTex:Texture
var deckTex:Texture
var colorTextureMap={}

var tile_groups=[]

var dragging_tile_group:TileGroup = null

var L0:Node # for deck
var L1:Node # for board

var level_file_name:String # = "res://data/Level1.json"

var cam:Camera2D

func _ready():
	load_level_file()
	init_textures()
	init_layers()
	init_board()
	init_tile_groups()
	init_deck()
	init_camera()
	

	
func load_level_file():
	var f = File.new()
	f.open(level_file_name,File.READ)
	var json = JSON.parse(f.get_as_text()).result
	
	boardData = json.board
	tileGroupData = json.tileGroups

func init_textures():
	var colors = []
	for tg in tileGroupData:
		for y in tg.form.size():
			for x in tg.form[y].size():
				var val = tg.form[y][x]
				if typeof(val) == TYPE_STRING:
					if !colors.has(val):
						colors.append(val)
		"""
		if !colors.has(tg.color):
			colors.append(tg.color)
		"""
	
	#dynamically create the color textures for required sizes
	var img = Image.new()
	img.create(TILE_SIZE, TILE_SIZE,false,Image.FORMAT_RGBA4444)
	
	for color in colors:
		img.fill(Color(color))
		var tex = ImageTexture.new()
		tex.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
		tex.set_data(img)
		colorTextureMap[color] = tex
	
	img.fill(Color.gray)
	boardTex = ImageTexture.new()
	boardTex.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	boardTex.set_data(img)
	
	img.fill(Color.green)
	var greenTexture = ImageTexture.new()
	greenTexture.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	greenTexture.set_data(img)
	greenTex = greenTexture
	
	img.fill(Color.red)
	var redTexture = ImageTexture.new()
	redTexture.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	redTexture.set_data(img)
	redTex = redTexture
	
	deckTex = load("res://assets/CardBG.png")

func init_layers():
	L0 = Node.new()
	L1 = Node.new()
	
	add_child(L0)
	add_child(L1)

func init_board():
	board = Board.new()
	board.tileSize = TILE_SIZE
	board.dividerSize = DIVIDER_SIZE
	board.tileTex = boardTex
	board.greenTex = greenTex
	board.redTex = redTex
	board.form = boardData.form
	
	print('board vp size : ',get_viewport().size)
	var board_size = board.get_calc_size()
	#board.position = get_viewport().size/2 - board_size/2
	var target_pos = get_viewport().size/2 - board_size/2
	print('board size = ',board.get_calc_size())

	#board.boardPos = boardData.position
	board.boardPos = {
		"xIndex":target_pos.x,
		"yIndex":target_pos.y
	}
	
	
	L1.add_child(board)
	board.add_to_group("Board")


func init_tile_groups():
	for data in tileGroupData:
		var tg = TileGroup.new()
		tg.tileSize = TILE_SIZE
		tg.dividerSize = DIVIDER_SIZE
		#tg.tileTex = colorTextureMap[data.color]
		tg.tileTextureMap = colorTextureMap
		tg.form=data.form
		tg.ori_pos=Vector2.ZERO
		tg.connect('release_tile_group',self,'on_tile_group_released')
		tg.connect('drag_tile_group',self,'on_tile_group_dragged')
		tile_groups.append(tg)

func init_deck():
	deck = Deck.new()
	deck.deckTexture = deckTex
	var padding = 20
	deck.deckPos = Vector2(
		padding, 
		get_viewport().size.y-deckTex.get_size().y-padding
	)
	deck.tile_groups = tile_groups
	L1.add_child(deck)

func init_camera():
	cam = Camera2D.new()
	cam.current=true
	cam.position=(get_viewport().size/2)
	add_child(cam)

func on_tile_group_released(tg:TileGroup):
	var center_points = tg.get_all_tile_centers()
	
	var num_on_board = board.num_center_points_on_board(center_points)
	print('num on board=',num_on_board)
	
	if center_points.size() == num_on_board:
		print('released into board')
		board.place_tile_group(tg)
		deck.on_tile_group_placed(tg)
	elif num_on_board == 0:
		print('released off board')
		#still need to check for intersections...
		var rects = tg.get_all_tile_rects()
		if board.has_intersect_rects(rects):
			print('has intersect, so it is patially on board')
			tg.snap_back_to_prev_position()
		else:
			print('no intersect, totally off the board')
			tg.update_prev_position(tg.position,false)
			deck.on_tile_group_placed(tg)
	else:
		print('released partially on board')
		tg.snap_back_to_prev_position()
	
	dragging_tile_group = null
	board.reset_effects_on_board()
	

func on_tile_group_dragged(tg):
	dragging_tile_group = tg


func _process(delta):
	if dragging_tile_group != null:
		board.show_effect_on_board(dragging_tile_group)

func stopping_zoom():
	if cam.zoom.x > 1.0 :
		tween_reset_zoom()

func stopping_drag():
	if cam.zoom.x == 1.0 && cam.position != get_viewport().size/2:
		tween_reset_zoom()

func tween_reset_zoom():
	print('tween reset zoom')
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(cam,"position",get_viewport().size/2,0.1)
	tween.tween_property(cam,"zoom",Vector2.ONE,0.1)


var is_dragging_camera = false
var ori_mouse_pos:Vector2 = Vector2.ZERO

func handle_mouse_camera(event:InputEventMouse):
	if is_dragging_camera && event is InputEventMouseMotion:
		var dxy = event.position - ori_mouse_pos
		cam.position -= (dxy * cam.zoom)
		ori_mouse_pos = event.position
		pass
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				is_dragging_camera = true
				ori_mouse_pos = event.position
			else:
				if is_dragging_camera:
					is_dragging_camera=false
					pass

var touch_ori_position_map={}
var touch_curr_position_map={}
var touch_indexes=[]
var starting_zoom:float = 1.0

func handle_touch_camera(event):
	
	if dragging_tile_group != null:
		return
	
	if event is InputEventScreenTouch:
		var index = event.index
		if event.is_pressed():
			if !touch_indexes.has(index):
				touch_indexes.append(index)
				touch_ori_position_map[index] = event.position
				touch_curr_position_map[index] = event.position
				if touch_indexes.size()==2:
					starting_zoom = cam.zoom.x
		else:
			touch_indexes.erase(index)
			touch_ori_position_map.erase(index)
			touch_curr_position_map.erase(index)
			if touch_indexes.size()==1:
				starting_zoom = cam.zoom.x
				stopping_zoom()
			elif touch_indexes.size()==0:
				stopping_drag()
			pass

	if event is InputEventScreenDrag:
		touch_curr_position_map[event.index] = event.position
		if touch_indexes.size()>1:
			var ori_pos1:Vector2 = touch_ori_position_map[touch_indexes[0]]
			var ori_pos2:Vector2 = touch_ori_position_map[touch_indexes[1]]
			var ori_distance = ori_pos1.distance_to(ori_pos2)
			var curr_pos1:Vector2 = touch_curr_position_map[touch_indexes[0]]
			var curr_pos2:Vector2 = touch_curr_position_map[touch_indexes[1]]
			var curr_distance = curr_pos1.distance_to(curr_pos2)
			var target_zoom = starting_zoom * ori_distance / curr_distance
			cam.zoom = Vector2(target_zoom,target_zoom)
			pass



func _input(event):

	if event is InputEventScreenTouch || event is InputEventScreenDrag:
		handle_touch_camera(event)
	
	elif event is InputEventMouse:
		handle_mouse_camera(event)







