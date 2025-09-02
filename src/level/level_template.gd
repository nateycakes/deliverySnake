extends Node2D
class_name Level

signal victory_condition_met

enum VICTORY_TYPE {
	DELIVERY_COUNT,
	SCORE,
	TIMED
}

@onready var player_spawn_location: Marker2D = $PlayerSpawnLocation

@onready var player_head_scene : PackedScene = preload("res://src/player/player_head.tscn")
@onready var pickup_scene : PackedScene = preload("res://src/level/pickup.tscn")

@onready var player_reference : PlayerHead = null
@onready var pickup_reference : Pickup = null

@onready var pickup_spawn_zone: Area2D = $PickupSpawnZone


@onready var level_marker_tl : Marker2D = $LevelMarker_TL
@onready var level_marker_tr : Marker2D = $LevelMarker_TR
@onready var level_marker_bl : Marker2D = $LevelMarker_BL
@onready var level_marker_br : Marker2D = $LevelMarker_BR
@onready var ui_layer : CanvasLayer = $UILayer
@onready var level_timer : Timer = $LevelTimer

@export var level_type : VICTORY_TYPE = VICTORY_TYPE.DELIVERY_COUNT
@export var victory_delivery_count : int = 1
@export var victory_score_count : int = 5000
@export var victory_timer_length : int = 300 #300 seconds -> 5 minutes
@export var debug : bool = false

#score variables - this is the most logical spot to test the scores
@onready var player_current_score : int = 0
@onready var player_current_delivery_count : int = 0
@onready var player_delivery_trip_count : int = 0




# Called when the node enters the scene tree for the first time.
func _ready():
	reset_score_label() #
	place_player(player_spawn_location.global_position)
	place_new_pickup() #place the first pickup
	ui_layer.visible = true
	ui_layer.score_label_container.visible = true
	ui_layer.game_over_container.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func place_player(input_position : Vector2) -> void:
	var new_player = player_head_scene.instantiate() as PlayerHead
	player_reference = new_player
	new_player.global_position = input_position
	new_player.delivery_complete.connect(on_delivery_success_received)
	
	call_deferred("add_child", new_player)
	if get_tree().paused: #the game will be paused if the player just died
		get_tree().paused = false

func reset_score_label():
	ui_layer.score_label.text = "Score: 0"
	pass

func reset_game():
	place_player(player_spawn_location.global_position)
	reset_score_label()

func place_new_pickup_old() -> void: #keeping around just in case yknow
	
	#gather list of already occupied locations
	var excluded_positions : Array = player_reference.body_segment_positions.duplicate(true)
	excluded_positions.push_back(player_reference.global_position)
	
	#we gotta account for the tiles, not just the x,y position, so we Mod the positions by tile size
	var min_x_bound = level_marker_tl.global_position.x / GameManager.level_manager.tile_size
	var max_x_bound = level_marker_tr.global_position.x / GameManager.level_manager.tile_size
	var min_y_bound = level_marker_tl.global_position.y / GameManager.level_manager.tile_size
	var max_y_bound = level_marker_bl.global_position.y / GameManager.level_manager.tile_size
	
	#now find a position in that range 
	var new_pickup_x : int = randi_range(min_x_bound, max_x_bound)
	var new_pickup_y : int = randi_range(min_y_bound, max_y_bound)
	#need to scale this up to real resolution for testing
	var new_position : Vector2 = Vector2(new_pickup_x * GameManager.level_manager.tile_size, new_pickup_y * GameManager.level_manager.tile_size)
	
	#loop until we find a position that isn't in the excluded list
	while excluded_positions.find(new_position) != -1:
		if debug: print("checking position " + str(new_position))
		new_pickup_x = randi_range(min_x_bound, max_x_bound)
		new_pickup_y = randi_range(min_y_bound, max_y_bound)
		new_position = Vector2(new_pickup_x * GameManager.level_manager.tile_size, new_pickup_y * GameManager.level_manager.tile_size)
	
	var new_pickup : Pickup = pickup_scene.instantiate() as Pickup
	new_pickup.collected.connect(place_new_pickup_old)
	pickup_reference = new_pickup
	call_deferred("add_child", new_pickup)
	new_pickup.global_position = new_position
	
	if debug:
		print("placing new pickup at " + str(new_position))
		print("Min X: " + str(min_x_bound) + " Max X: " + str(max_x_bound))
		print("Min Y: " + str(min_y_bound) + " Max Y: " + str(max_y_bound))
		print("TL Bound: X:" + str(level_marker_tl.global_position.x) + " Y: " + str(level_marker_tl.global_position.y))
	
	var dummy : Vector2 = return_eligible_pickup_placement_location()
	print("I COULD place a pickup here using the new method: X: " + str(dummy.x) + " , Y:" + str(dummy.y))
	
	return
	##########  END PLACE_NEW_PICKUP() #################


func return_eligible_pickup_placement_location(): #returns a Vector2
	
	var pickup_location_zones = pickup_spawn_zone.get_children()
	var random_collision_zone_number = randi_range(0, pickup_location_zones.size()-1)
	
	var pickup_spawn_zone_collision_shape2d : CollisionShape2D = pickup_location_zones[random_collision_zone_number]
	var pickup_spawn_zone_shape2d : Shape2D = pickup_spawn_zone_collision_shape2d.shape
	
	var rect : Rect2 = pickup_spawn_zone_shape2d.get_rect()
	
	# The position of the Shape is the top-left origin of the shape
	# The end is the position of the bottom-right corner
	# using this info, we can infer which range of positions are encompassed in this rectangle shape
	
	#temp vars for following the formula on my white board bc this shit is confusing lol
	#the position of the CollisionShape refers to the CENTER of the collision shape
	#the position and shape of the Rect are offsets, both from the center of the shape
	#using this info we can infer the size of the shape
	var CS_pos : Vector2 = Vector2.ZERO #collisionshape2d_position
	CS_pos.x = pickup_spawn_zone_collision_shape2d.position.x 
	CS_pos.y = pickup_spawn_zone_collision_shape2d.position.y
	
	var R_pos : Vector2 = Vector2.ZERO #rect_position
	var R_end : Vector2 = Vector2.ZERO #rect_end
	R_pos.x = rect.position.x
	R_pos.y = rect.position.y
	R_end.x = rect.end.x
	R_end.y = rect.end.y
	
	var start : Vector2 = Vector2.ZERO #make these vectors bc its easier
	var end : Vector2 = Vector2.ZERO
	
	start.x = CS_pos.x - R_end.x #CollisionShape2D position X minus half of the Rect2D's shape is the START
	start.y = CS_pos.y - R_end.y
	
	end.x = CS_pos.x + R_end.x
	end.y = CS_pos.y + R_end.y
	
	#now find a position in that range 
	var new_pickup_x : int = randi_range(start.x, end.x)
	var new_pickup_y : int = randi_range(start.y, end.y)
	var new_position : Vector2 = Vector2(new_pickup_x, new_pickup_y)
	new_position = new_position.snapped(Vector2.ONE * GameManager.level_manager.tile_size)
	
	#gather list of already occupied locations
	var excluded_positions : Array = player_reference.body_segment_positions.duplicate(true)
	excluded_positions.push_back(player_reference.global_position)
	
	var excluded_positions_snapped : Array = []
	#snap all the excluded positions to the grid to make checking ezpz
	for i in excluded_positions:
		excluded_positions_snapped.push_back(i.snapped(Vector2.ONE * GameManager.level_manager.tile_size))
	
	#loop until we find a position that isn't in the excluded list
	while excluded_positions_snapped.find(new_position) != -1:
		print("I need to find a new number")
		new_pickup_x = randi_range(start.x, end.x)
		new_pickup_y = randi_range(start.y, end.y)
		new_position = Vector2(new_pickup_x, new_pickup_y)
		new_position = new_position.snapped(Vector2.ONE * GameManager.level_manager.tile_size)
	
	if debug:
		print("placing new pickup at " + str(new_position))
		print("Min X: " + str(start.x) + " Max X: " + str(end.x))
		print("Min Y: " + str(start.y) + " Max Y: " + str(end.y))
	
	return new_position #remember, this is already snapped to the grid

func place_new_pickup():
	var new_position : Vector2 = return_eligible_pickup_placement_location()
	var new_pickup : Pickup = pickup_scene.instantiate() as Pickup
	new_pickup.collected.connect(place_new_pickup)
	pickup_reference = new_pickup
	call_deferred("add_child", new_pickup)
	new_pickup.global_position = new_position

func reset_game_timer() -> void: #this function pauses and resets the timer to the level-defined length
	level_timer.paused = true
	level_timer.wait_time = victory_timer_length
	return

func victory_check_score_amount(score : int):
	if level_type == VICTORY_TYPE.SCORE && GameManager.score_manager.player_current_score >= victory_score_count:
		if debug: print("Scored " + str(score) + " / " + str(victory_score_count) + " points. Victory Achieved")
		victory_condition_met.emit()
	return

func victory_check_delivery_count(count :int):
	if debug: print("checking win condition")
	if level_type == VICTORY_TYPE.DELIVERY_COUNT && count >= victory_delivery_count:
		if debug: print("Delivered " + str(count) + " / " + str(victory_delivery_count) + ". Victory Achieved" )
		player_reference.on_level_complete()
		victory_condition_met.emit()
	return


func on_delivery_success_received(count : int):
	#responsible for handling when to check if the victory conditions would be met
	if debug:
		print("----------------------------------")
		print("    DELIVERY SUCCESS RECEIVED")
		print(" PLAYER DELIVERED: " + str(count))
		print("----------------------------------")
	player_delivery_trip_count += 1
	update_current_delivery_count(true, count)
	victory_check_delivery_count(player_current_delivery_count)

func _on_level_timer_timeout() -> void: #just going to check the score as a default
	victory_check_score_amount(GameManager.score_manager.player_current_score)


func destroy_level():
	print("destroying level")
	call_deferred("queue_free")


### --------------- DELIVERY AND SCORE SECTION --------------- ####

func update_current_delivery_count(increase : bool, count : int):
	if increase:
		player_current_delivery_count += count
		if debug: print("Delivery Count is now: " + str(player_current_delivery_count))
		return
	else: #yay lots of logic to catch weird < 0 cases
		if (player_current_delivery_count <= 0) || (player_current_delivery_count - count <= 0):
			player_current_delivery_count = 0
		else:
			player_current_delivery_count -= count
