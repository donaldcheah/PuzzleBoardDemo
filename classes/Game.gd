extends Node2D

class_name Game


var TILE_SIZE = 24
var DIVIDER_SIZE = 1

#TODO: should be gotten from .json
var tileGroupData=[
	{
		'color':'#ff0000',
		'form':[
			[1],
		]
	},
	{
		'color':'#00ff00',
		'form':[
			[1,1,1],
			[0,1,0]
		]
	},
	{
		'color':'#0000ff',
		'form':[
			[0,1],
			[0,1],
			[1,1]
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

var level_file_name:String = "res://data/Level1.json"

func _ready():
	load_level_file()
	init_textures()
	init_layers()
	init_board()
	init_tile_groups()
	init_deck()
	
func load_level_file():
	var f = File.new()
	f.open(level_file_name,File.READ)
	var json = JSON.parse(f.get_as_text()).result
	
	boardData = json.board
	tileGroupData = json.tileGroups

func init_textures():
	var colors = []
	for tg in tileGroupData:
		if !colors.has(tg.color):
			colors.append(tg.color)
	
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
	board.boardPos = boardData.position
	L1.add_child(board)
	board.add_to_group("Board")

func init_tile_groups():
	for data in tileGroupData:
		var tg = TileGroup.new()
		tg.tileSize = TILE_SIZE
		tg.dividerSize = DIVIDER_SIZE
		tg.tileTex = colorTextureMap[data.color]
		tg.form=data.form
		tg.ori_pos=Vector2.ZERO
		tg.connect('release_tile_group',self,'on_tile_group_released')
		tg.connect('drag_tile_group',self,'on_tile_group_dragged')
		tile_groups.append(tg)

func init_deck():
	deck = Deck.new()
	deck.deckTexture = deckTex
	var padding = 10
	deck.deckPos = Vector2(padding, get_viewport().size.y-deckTex.get_size().y-padding)
	deck.tile_groups = tile_groups
	L1.add_child(deck)


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







