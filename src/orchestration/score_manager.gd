extends Node
class_name ScoreManager

#handles everything related to the playerScore

#scoring points variables
@onready var player_game_score : int = 0
@onready var player_current_score : int = 0
@onready var level_score : int = 0
#player delivery variables
@onready var player_game_deliveries : int = 0
@onready var player_current_deliveries : int = 0


func prepare_final_score():
	player_game_score += player_current_score
	return

func initialize_scores():
	player_current_score = 0
	player_game_score = 0
	return

func reset_current_score():
	player_current_score = 0
	return

func add_current_score_to_total_score():
	player_game_score += player_current_score
	return

func modify_current_score(increase : bool, value: int):
	if increase:
		player_current_score += value
		level_score += value
	else:
		player_current_score -= value
		level_score -= value
	return
