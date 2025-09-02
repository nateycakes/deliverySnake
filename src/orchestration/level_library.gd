extends Resource
class_name LevelLibrary

# a working list of all the levels in the game. To load one of these levels, you need to duplicate it
# I hope this will help alleviate the headache of where and how to load sets of levels

const normal_level_list : Array = [
	preload("res://src/level/builtLevels/first_level.tscn"),
	preload("res://src/level/builtLevels/level_two.tscn")
]
