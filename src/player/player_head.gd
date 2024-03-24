extends Area2D
class_name PlayerHead

signal hit_wall
signal position_updated
signal player_destroyed

@onready var wall_detector = $WallDetector
@onready var walk_speed_timer = $WalkSpeedTimer

@onready var last_direction : String = ""
@export var walk_speed_value : float #this controls how fast the character moves


@onready var player_body_scene = preload("res://src/player/player_body.tscn")
@onready var pickup_scene = preload("res://src/level/pickup.tscn")

@onready var tail_position : Vector2 = Vector2.ZERO
@onready var tail_node = null


@onready var body_segments : Array = []
@onready var body_segment_positions : Array = []

@onready var in_delivery_zone : bool = false
@onready var delivery_count : int = 0

@export var debug : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	snap_to_grid()



func _unhandled_input(event):
	#iterate through all the diff defined positions the player can move, and grab the keys of the dict they're stored in
	#the keys are named the SAME as the input action so we can take advantage in "is_action_pressed"
	for dir in GameManager.inputs.keys():
		if event.is_action_pressed(dir) && is_valid_direction(GameManager.inputs.get(dir)): #player has pushed a movement key!
			if walk_speed_timer.is_stopped(): #player hasn't started moving yet
				walk_speed_timer.start(walk_speed_value)
				move(dir)
			last_direction = dir


func is_valid_direction(input_direction : Vector2)-> bool:
	#this func will test if the player is trying to input an invalid move
	# example: trying to move down while moving up, trying to move left while moving right, etc
	
	if input_direction == GameManager.inputs.get(last_direction):
		return false #this is a duplicate keypress, FOH with that!
	
	#no inputting left while travelling right
	if (input_direction == Vector2.LEFT) && (GameManager.inputs.get(last_direction) == Vector2.RIGHT):
		return false
	#no inputting right while travelling left
	if (input_direction == Vector2.RIGHT) && (GameManager.inputs.get(last_direction) == Vector2.LEFT):
		return false
	#no inputting up while travelling down
	if (input_direction == Vector2.UP) && (GameManager.inputs.get(last_direction) == Vector2.DOWN):
		return false
	#no inputting up while travelling down
	if (input_direction == Vector2.DOWN) && (GameManager.inputs.get(last_direction) == Vector2.UP):
		return false
	
	#if we made it this far, then we're good
	return true

func move(dir):
	#update the raycast to see if there is a wall that we'd run into
	wall_detector.target_position = GameManager.inputs[dir] * GameManager.tile_size
	wall_detector.force_raycast_update()
	if !wall_detector.is_colliding():
		tail_position = global_position #save our previous position for ezpz adding children
		#print("tail position is now " + str(tail_position))
		position += GameManager.inputs[dir] * GameManager.tile_size
		update_tail_positions()
	else:
		hit_wall.emit()
		if debug: print("oopsie we hit a wall")
		player_hits_wall()
		walk_speed_timer.stop() #stop the player from moving since they ded

func update_tail_positions():
	if body_segments.is_empty():
		return
	
	body_segment_positions.pop_back() #get rid of last position
	body_segment_positions.push_front(tail_position) #add the newly updated/current tail position
	
	var i : int = 0
	while i < body_segments.size():
		body_segments[i].global_position = body_segment_positions[i]
		i += 1


func add_new_body_segment():
	var new_body_segment := player_body_scene.instantiate() as PlayerBody
	if body_segments.is_empty():
		#no body segments to worry about yet woo
		new_body_segment.global_position = tail_position 
		body_segments.push_back(new_body_segment)
		body_segment_positions.push_back(tail_position)
	else:
		new_body_segment.global_position = body_segment_positions.back()
		body_segments.push_back(new_body_segment)
		body_segment_positions.push_back(new_body_segment.global_position)
	
	call_deferred("add_child", new_body_segment) #throws a timing/race error if we dont do it this way


func snap_to_grid():
	#snap the player to the grid (ty kidscancode)
	position = position.snapped(Vector2.ONE * GameManager.tile_size)
	position += Vector2.ONE * GameManager.tile_size/2

func _on_walk_speed_timer_timeout():
	if in_delivery_zone:
		body_delivery_checks()
	move(last_direction)



func _on_area_entered(area):
	if area is Pickup:
		area.collected.emit()
		area.queue_free()
		add_new_body_segment()
		var excluded_positions = body_segment_positions.duplicate(true)
		excluded_positions.push_back(global_position)
		
	
	if area is DeliveryZone:
		on_enter_delivery_zone()
	
	if area is PlayerBody:
		if debug: print("oops we hit our tail")
		player_hits_self()


func _on_area_exited(area):
	on_exit_delivery_zone()


func place_new_pickup(new_pickup_position : Vector2):
	var new_pickup : Pickup = pickup_scene.instantiate()
	call_deferred("add_child", new_pickup) #works, but it adds relative to player and moves around
	new_pickup.global_position = new_pickup_position


func body_delivery_checks():
	if body_segments.size() <= 0:
		return
	#reset our counter
	delivery_count = 0 
	#iterate through the segments
	for i in body_segments: 
		#is the segment in a delivery zone?
		if i.is_deliverable(): 
			delivery_count += 1
	#compare total # in delivery zone to total number of segments
	if delivery_count == body_segments.size(): 
		walk_speed_timer.paused
		await delivery_success(delivery_count)
		walk_speed_timer.start(walk_speed_value)

func delivery_success(count : int):
	var exponent : float = float(count)
	var delivery_points = pow(GameManager.delivery_base_score, exponent)
	GameManager.player_score += int(delivery_points)
	GameManager.delivery_success.emit()
	sever_tail()

func on_enter_delivery_zone():
	in_delivery_zone = true

func on_exit_delivery_zone():
	in_delivery_zone = false


func sever_tail():
	tail_node = null
	tail_position = Vector2.ZERO
	#iterate through tail and KILL
	for i in body_segments:
		i as PlayerBody
		i.queue_free()
	for i in body_segment_positions:
		body_segment_positions.pop_back()
	body_segments.clear()
	body_segment_positions.clear()

func player_hits_self():
	get_tree().paused = true
	player_destroyed.emit()
	GameManager.game_over.emit() #this is what the UI will listen for
	walk_speed_timer.stop()
	sever_tail()
	queue_free()

func player_hits_wall():
	player_hits_self() #making this separarte for future ideas
