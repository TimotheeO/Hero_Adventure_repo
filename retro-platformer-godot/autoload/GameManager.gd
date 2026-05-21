extends Node

var lives = 3
var coins = 0
var stars = 0

var current_level = 1

func add_coin():
	coins += 1
	
	if coins % 10 == 0:
		lives += 1

func add_star():
	stars += 1
