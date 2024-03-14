extends BodySegment
class_name HeadSegment

signal hit_wall

@onready var wall_detector = $WallDetector
@onready var walk_speed_timer = $WalkSpeedTimer

@onready var last_direction : String = ""
@onready var last_position : Vector2 = Vector2.ZERO
@export var walk_speed_value : float #this controls how fast the character moves



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_input(event):
	#iterate through all the diff defined positions the player can move, and grab the keys of the dict they're stored in
	#the keys are named the SAME as the input action so we can take advantage in "is_action_pressed"
	for dir in GameManager.inputs.keys():
		if event.is_action_pressed(dir): #player has pushed a movement key!
			if walk_speed_timer.is_stopped(): #player hasn't started moving yet
				walk_speed_timer.start(walk_speed_value)
				move(dir)
			last_direction = dir


func move(dir):
	#update the raycast to see if there is a wall that we'd run into
	wall_detector.target_position = GameManager.inputs[dir] * GameManager.tile_size
	wall_detector.force_raycast_update()
	if !wall_detector.is_colliding():
		last_position = position
		update_position(position + GameManager.inputs[dir] * GameManager.tile_size)
		#update_next_segment_position(last_position)
	else:
		hit_wall.emit()
		print("oopsie we hit a wall")
		walk_speed_timer.stop() #stop the player from moving since they ded









func _on_walk_speed_timer_timeout():
	move(last_direction)





func _on_area_entered(area):
	if area is Pickup:
		print("pickup collected!")
		var new_segment = body_segment_scene.instantiate()
		add_next_segment(new_segment)
		area.queue_free()
