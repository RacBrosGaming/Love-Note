extends Control
class_name LoveLetter

signal finished_writing
signal chose_answer(said_yes: bool)

@onready var panel_container: PanelContainer = $PanelContainer
@onready var letter_words: Label = %LetterWords
@onready var letter_back: TextureRect = $LetterBack
@onready var yes_check_box: CheckBox = $YesCheckBox
@onready var no_check_box: CheckBox = $NoCheckBox
@onready var flip_timer: Timer = $FlipTimer
@onready var letter_back_starting_position := letter_back.global_position
@onready var letter_back_starting_scale := letter_back.scale

var note_position: Vector2

func write(target_position: Vector2) -> void:
	note_position = target_position
	no_check_box.visible = false
	yes_check_box.visible = false
	letter_words.visible_ratio = 0
	visible = true
	var word_tween := create_tween()
	word_tween.tween_property(letter_words, "visible_ratio", 1, 6)
	await word_tween.finished
	flip_timer.start()

func present_option(target_position: Vector2) -> void:
	note_position = target_position
	no_check_box.visible = true
	yes_check_box.visible = true
	visible = true

func _on_yes_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		no_check_box.visible = false
		no_check_box.disabled = true
		chose_answer.emit(true)

func _on_no_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		yes_check_box.visible = false
		yes_check_box.disabled = true
		chose_answer.emit(false)

func _on_flip_timer_timeout() -> void:
	panel_container.visible = false
	letter_back.visible = true
	var position_tween := create_tween()
	position_tween.tween_property(self, "global_position", note_position, 2)
	var scale_tween := create_tween()
	scale_tween.tween_property(letter_back, "scale", Vector2(1, 1), 2)
	await scale_tween.finished
	visible = false
	panel_container.visible = true
	letter_back.visible = false
	letter_back.global_position = letter_back_starting_position
	letter_back.scale = letter_back_starting_scale
	finished_writing.emit()
