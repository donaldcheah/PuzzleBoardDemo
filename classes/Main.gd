extends Node2D

const TILE_SIZE = 24
const DIVIDER_SIZE = 1

"""
func _ready():
	#dynamically create the color textures for required sizes
	var img = Image.new()
	img.create(TILE_SIZE,TILE_SIZE,false,Image.FORMAT_RGBA4444)
	
	img.fill(Color(0,1,0,1))
	var greenTexture = ImageTexture.new()
	greenTexture.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	greenTexture.set_data(img)
	
	img.fill(Color(1,0,0,1))
	var redTexture = ImageTexture.new()
	redTexture.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	redTexture.set_data(img)
	
	img.fill(Color.gray)
	var greyTexture = ImageTexture.new()
	greyTexture.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	greyTexture.set_data(img)
	
	img.fill(Color(1,1,0,1))
	var yellowTexture = ImageTexture.new()
	yellowTexture.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	yellowTexture.set_data(img)
	
	
	#load json file
	var path = 'res://data/level0.json'
	var f = File.new()
	f.open(path,File.READ)
	var s = JSON.parse(f.get_as_text())
	var json = s.result

	#print(json.board)
	
	var pb = PlayBoard2.new()
	pb.TILE_SIZE = TILE_SIZE
	pb.DIVIDER_SIZE = DIVIDER_SIZE
	
	pb.greenTexture = greenTexture
	pb.redTexture = redTexture
	pb.greyTexture = greyTexture
	pb.yellowTexture = yellowTexture
	pb.deckBGTexture = load("res://assets/CardBG.png")
	
	pb.boardData = json.board
	
	pb.tileGroupData = json.tileGroups
	
	add_child(pb)
	
"""
	
func _ready():
	#dynamically create the color textures for required sizes
	var img = Image.new()
	img.create(TILE_SIZE,TILE_SIZE,false,Image.FORMAT_RGBA4444)
	
	img.fill(Color(1,1,0,1))
	var yellowTexture = ImageTexture.new()
	yellowTexture.create(TILE_SIZE, TILE_SIZE, Image.FORMAT_RGBA4444)
	yellowTexture.set_data(img)
	
	var deck = Deck.new()
	deck.TILE_SIZE = TILE_SIZE
	deck.DIVIDER_SIZE = DIVIDER_SIZE
	deck.tileTex = yellowTexture
	deck.deckBGTexture = load('res://assets/CardBG.png')
	deck.tileGroupData=[
		{
			'form':[
				[1,1],
				[0,1]
			]
		}
	]
	
	
	add_child(deck)
	pass
