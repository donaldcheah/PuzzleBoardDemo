extends Node2D
class_name TileGroup

var tileTex:Texture
var form=[]
var ori_pos:Vector2

var TILE_SIZE = 64
var DIVIDER_SIZE = 4

var mouse_over_idx = []

var tiles = []

# Called when the node enters the scene tree for the first time.
func _ready():
	position = ori_pos
	for y in form.size():
		for x in form[y].size():
			if form[y][x] == 1:
				var spr = Sprite.new()
				spr.centered=false
				spr.texture = tileTex
				spr.position = Vector2(x * (TILE_SIZE+DIVIDER_SIZE),y* (TILE_SIZE+DIVIDER_SIZE))
				add_child(spr)
				tiles.append(spr)
				
				var area = Area2D.new()
				spr.add_child(area)
				
				var coll = CollisionShape2D.new()
				coll.position = Vector2(TILE_SIZE/2,TILE_SIZE/2)
				area.add_child(coll)
				coll.shape = RectangleShape2D.new()
				coll.shape.extents = Vector2(TILE_SIZE/2,TILE_SIZE/2)
				
				var idx = '%d,%d'%[x,y]
				area.connect("mouse_entered",self,"_mouse_enter",[idx])
				area.connect('mouse_exited',self,'_mouse_exit',[idx])

func num_tiles():
	return tiles.size()
	
func is_mouse_over():
	return mouse_over_idx.size()>0

# returns list of center pos of tiles, relative to the screen
func get_center_pos_of_tiles():
	var arr = []
	for spr in tiles:
		var pos = spr.position+Vector2(TILE_SIZE/2,TILE_SIZE/2) + position
		arr.append(pos)
	return arr

func _mouse_enter(idx):
	mouse_over_idx.append(idx)
	pass
func _mouse_exit(idx):
	mouse_over_idx.erase(idx)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
