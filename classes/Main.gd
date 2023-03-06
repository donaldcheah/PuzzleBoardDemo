extends Node2D

func _ready():
	var game = Game.new()
	game.level_file_name = "res://data/Level001.json"
	add_child(game)
