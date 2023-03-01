extends Node

class_name Deck

var TILE_SIZE 
var DIVIDER_SIZE
var tileTex:Texture
var deckBGTexture:Texture

# an array of object containing forms:2D array of 0's and 1's
var tileGroupData

var deckPos:Vector2

#the ones hidden
var tileGroups = []

#the ones currently shown on board
var shown_tile_groups=[]

var deckSprite:Sprite

func _ready():
	
	deckSprite = Sprite.new()
	deckSprite.centered=false
	deckSprite.texture = deckBGTexture
	deckSprite.position = deckPos
	deckSprite.scale = Vector2(0.20,0.20)
	add_child(deckSprite)
	
	init_tile_groups()
	
	#show_next_tile_group()
	
	print(deckSprite.texture.get_size()*deckSprite.scale,' pos:',deckSprite.position, ' scale:',deckSprite.scale)

func init_tile_groups():
	for data in tileGroupData:
		var tg = TileGroup.new()
		tg.form = data.form
		tg.TILE_SIZE = TILE_SIZE
		tg.DIVIDER_SIZE = DIVIDER_SIZE
		tg.tileTex = tileTex

		tg.ori_pos = (deckPos+Vector2(30,30))
		
		tileGroups.append(tg)
	
func show_next_tile_group():
	var tg = tileGroups.pop_front()
	add_child(tg)
	pass


var is_mouse_in = false
func _input(event):
	if event is InputEventMouseMotion:
		var pos = deckSprite.position
		var size = deckSprite.texture.get_size() * deckSprite.scale
		var deckSpriteRect = Rect2(pos,size)
		if deckSpriteRect.has_point(event.position):
			if !is_mouse_in:
				is_mouse_in = true
				print('is mouse in deck pic')
		else:
			if is_mouse_in:
				is_mouse_in = false
				print('mouse is out')
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed() && is_mouse_in:
				print('you clicked in deck')
				show_next_tile_group()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
