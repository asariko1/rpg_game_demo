extends Node

var player_current_attack = false

var current_scene = "world"
var transition_scene = false
var game_first_loading =true

var player_start_posx = 150
var player_start_posy = 100

var player_exit_posx = 535
var player_exit_posy = 380


func finish_changescene():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "world":
			current_scene = "camp"
		else:
			current_scene = "world"
				
		
	
