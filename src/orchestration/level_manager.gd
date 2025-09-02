extends Node
class_name LevelManager

# this node will have functions to cycle through 

signal delivery_success
signal game_over
signal level_complete

@onready var delivery_base_score : float = 2.0
@onready var pickup_scene : PackedScene = preload("res://src/level/pickup.tscn")

@onready var tile_size : int = 32

#LEVEL MANAGEMENT VARIABLES
@onready var previous_level : Level #used to clean up the level after transitioning to a new one
@onready var current_level : Level
@onready var current_level_packed : PackedScene #need to hold onto the blueprint when they retry the level
@onready var remaining_levels : Array = []
@onready var level_library : LevelLibrary = preload("res://src/orchestration/level_library.tres")


#valid inputs defined as vectors for moving the character around
@onready var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}

# Called when the node ENTERS THE SCENE TREE for the first time.
func _ready():
	game_over.connect(set_game_over) #listen for Game Over signal


func _input(event):
	if GameManager.is_game_over and event.is_action_pressed("confirm"):
		GameManager.score_manager.initialize_scores()
		#get_tree().reload_current_scene()
		
	return


func get_level_list_by_difficulty(difficulty) -> Array : #returns an array of packedScenes
	match difficulty:
		GameManager.DIFFICULTY.NORMAL:
			#do a deep copy in case we want to do funky stuff later
			return level_library.normal_level_list.duplicate(true)
		_:
			print("This error in matching Difficulty during level init should not occur")
			return [] #return an empty array I guess


func initialize_new_level(calling_level : Level):
	current_level = calling_level
	GameManager.score_manager.initialize_scores()
	GameManager.reset_game_over_status()
	print("new level initialized!")


func set_up_first_level(difficulty):
	remaining_levels = get_level_list_by_difficulty(difficulty)
	current_level_packed = remaining_levels.pop_front()
	var new_level : Level = current_level_packed.instantiate()
	current_level = new_level
	new_level.victory_condition_met.connect(_on_level_complete)
	add_child(new_level)


func prepare_next_level(new_level_template : PackedScene):
	var new_level : Level = new_level_template.instantiate()
	previous_level = current_level
	current_level = new_level

func _on_level_complete2():
	print("yay the level is complete")

func _on_level_complete(): #only fired when the level_complete signal is caught
	if remaining_levels.size() > 0 : #are there levels remaining?
		var next_level_template : PackedScene = remaining_levels.pop_front() #get packed scene for next level
		prepare_next_level(next_level_template) #instance new level
		delete_previous_level() #remove the old level
		call_deferred("add_child", current_level)
		 #append new level to tree
	else: #there are no more remaining levels:
		pass #load the win screen here

func set_game_over():
	GameManager.set_game_over()
	print("game is over!")

func delete_active_level(): #need for deleting the current level when the player restarts the game
	current_level.destroy_level()
	print("CURRENT level deleted")

func delete_previous_level(): #need for deleting the previous level when we transition to new level
	previous_level.destroy_level()
	print("PREVIOUS level deleted")

#unify the gridsnapping somewhere, might as well be for the level
#snap to the actual grid, then move to the center of the tile (for scene placements)
func snap_to_grid(input_position : Vector2):
	#snap the player to the grid and centered in that tile (ty kidscancode)
	var return_position = input_position.snapped(Vector2.ONE * tile_size)
	return_position  += Vector2.ONE * tile_size / 2
	return return_position
