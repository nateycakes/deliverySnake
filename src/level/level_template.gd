extends Node2D
class_name Level

@onready var player_spawn_location = $PlayerSpawnLocation

@onready var player_head_scene : PackedScene = preload("res://src/player/player_head.tscn")
@onready var pickup_scene : PackedScene = preload("res://src/level/pickup.tscn")

@onready var player_reference : PlayerHead = null
@onready var pickup_reference : Pickup = null

@onready var level_marker_tl = $LevelMarker_TL
@onready var level_marker_tr = $LevelMarker_TR
@onready var level_marker_bl = $LevelMarker_BL
@onready var level_marker_br = $LevelMarker_BR

@export var debug : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	place_player(player_spawn_location.global_position)
	place_new_pickup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func place_player(input_position : Vector2) -> void:
	var new_player = player_head_scene.instantiate() as PlayerHead
	player_reference = new_player
	new_player.global_position = input_position
	call_deferred("add_child", new_player)


func place_new_pickup() -> void:
	
	#gather list of already occupied locations
	var excluded_positions : Array = player_reference.body_segment_positions.duplicate(true)
	excluded_positions.push_back(player_reference.global_position)
	
	#we gotta account for the tiles, not just the x,y position, so we Mod the positions by tile size
	var min_x_bound = level_marker_tl.global_position.x / GameManager.tile_size
	var max_x_bound = level_marker_tr.global_position.x / GameManager.tile_size
	var min_y_bound = level_marker_tl.global_position.y / GameManager.tile_size
	var max_y_bound = level_marker_bl.global_position.y / GameManager.tile_size
	
	#now find a position in that range 
	var new_pickup_x : int = randi_range(min_x_bound, max_x_bound)
	var new_pickup_y : int = randi_range(min_y_bound, max_y_bound)
	#need to scale this up to real resolution for testing
	var new_position : Vector2 = Vector2(new_pickup_x * GameManager.tile_size, new_pickup_y * GameManager.tile_size)
	
	#loop until we find a position that isn't in the excluded list
	while excluded_positions.find(new_position) != -1:
		if debug: print("checking position " + str(new_position))
		new_pickup_x = randi_range(min_x_bound, max_x_bound)
		new_pickup_y = randi_range(min_y_bound, max_y_bound)
		new_position = Vector2(new_pickup_x * GameManager.tile_size, new_pickup_y * GameManager.tile_size)
	
	var new_pickup : Pickup = pickup_scene.instantiate() as Pickup
	new_pickup.collected.connect(place_new_pickup)
	pickup_reference = new_pickup
	call_deferred("add_child", new_pickup)
	new_pickup.global_position = new_position
	
	if debug:
		print("placing new pickup at " + str(new_position))
		print("Min X: " + str(min_x_bound) + " Max X: " + str(max_x_bound))
		print("Min Y: " + str(min_y_bound) + " Max Y: " + str(max_y_bound))
		print("TL Bound: X:" + str(level_marker_tl.global_position.x) + " Y: " + str(level_marker_tl.global_position.y))
	
