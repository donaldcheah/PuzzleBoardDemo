extends Node2D

func _ready():
	var game = Game.new()
	game.level_file_name = "res://data/LevelT1.json"
	
	var scale = 1
	
	game.TILE_SIZE = 24*scale
	game.DIVIDER_SIZE = 1*scale
	
	add_child(game)
	
