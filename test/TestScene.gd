extends Node2D

var TILE_SIZE = 24
var DIVIDER_SIZE = 1

#TODO: should be gotten from .json
var tileGroupData=[
	{
		'form':[
			[1],
		]
	},
	{
		'form':[
			[1,1,1],
			[0,1,0]
		]
	},
	{
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

var deckTex:Texture
var redTex:Texture
var greenTex:Texture
var greyTex:Texture
var yellowTex:Texture

var tile_groups=[]

var dragging_tile_group:TG = null

var L0:Node # for deck
var L1:Node # for board

func _ready():
	var f = File.new()
	f.open("res://data/Level1.json",File.READ)
	var json = JSON.parse(f.get_as_text()).result
	
	boardData = json.board
	tileGroupData = json.tileGroups
	
	init_textures()
	
	init_layers()
	
	init_board()
	
	init_tile_groups()

	init_deck()
	
func init_textures():
		#dynamically create the color textures for required sizes
	var img = Image.new()
	img.create(TILE_SIZE,TILE_SIZE,false,Image.FORMAT_RGBA4444)
	
	img.fill(Color(1,1,0,1))
	var yellowTexture = ImageTexture.new()
	yellowTexture.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	yellowTexture.set_data(img)
	yellowTex = yellowTexture
	
	img.fill(Color.gray)
	var greyTexture = ImageTexture.new()
	greyTexture.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	greyTexture.set_data(img)
	greyTex = greyTexture
	
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
	board.tileTex = greyTex
	board.greenTex = greenTex
	board.redTex = redTex
	board.form = boardData.form
	board.boardPos = boardData.position
	L1.add_child(board)

func init_tile_groups():
	for data in tileGroupData:
		var tg = TG.new()
		tg.tileSize = TILE_SIZE
		tg.dividerSize = DIVIDER_SIZE
		tg.tileTex = yellowTex
		tg.form=data.form
		tg.ori_pos=Vector2.ZERO
		tg.connect('release_tile_group',self,'on_tile_group_released')
		tg.connect('drag_tile_group',self,'on_tile_group_dragged')
		tile_groups.append(tg)

func on_tile_group_released(tg):
	var center_points = tg.get_all_tile_centers()
	
	var num_on_board = board.num_center_points_on_board(center_points)
	print('num on board=',num_on_board)
	
	if center_points.size() == num_on_board:
		print('released into board')
		board.place_tile_group(tg)
	elif num_on_board == 0:
		print('released off board')
		#still need to check for intersections...
		var rects = tg.get_all_tile_rects()
		#print('rects:',rects)
		if board.has_intersect_rects(rects):
			print('has intersect')
			tg.position = tg.ori_pos
		else:
			print('no intersect')
			tg.ori_pos = tg.position
	else:
		print('released partially on board')
		tg.position = tg.ori_pos
	dragging_tile_group = null
	board.reset_effects_on_board()

func on_tile_group_dragged(tg):
	dragging_tile_group = tg


func init_deck():
	var deck:Dk = Dk.new()
	deck.deckTexture = deckTex
	var padding = 10
	deck.deckPos = Vector2(padding, get_viewport_rect().size.y-deckTex.get_size().y-padding)
	deck.tile_groups = tile_groups
	L1.add_child(deck)
	
	
func _process(delta):
	if dragging_tile_group != null:
		board.show_effect_on_board(dragging_tile_group)


