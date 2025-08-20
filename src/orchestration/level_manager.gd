extends Node
class_name LevelManager

signal delivery_success
signal game_over
signal level_complete

@onready var player_score : int = 0
@onready var delivery_base_score : float = 2.0
@onready var pickup_scene : PackedScene = preload("res://src/level/pickup.tscn")

@onready var current_scene : Level = null
@onready var is_game_over : bool = false



#LEVEL MANAGEMENT VARIABLES
@onready var current_level : Level = null
@onready var level_list : Dictionary


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.game_over.connect(set_game_over) #listen for Game Over signal



func _input(event):
	if is_game_over and event.is_action_pressed("confirm"):
		player_score = 0 #set this to zero because we KNOW the level is restarting
		get_tree().reload_current_scene()
		
	return

func intiate_new_game(calling_level : Level):
	current_scene = calling_level
	player_score = 0 #reset player score
	is_game_over = false
	print("new game initialized!")

func set_game_over():
	is_game_over = true
	print("game is over!")
