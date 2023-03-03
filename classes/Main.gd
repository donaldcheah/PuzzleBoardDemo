extends Node2D

func _ready():
	var game = Game.new()
	game.load_file_name = "res://data/Level4.json"
	add_child(game)
