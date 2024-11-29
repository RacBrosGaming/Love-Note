extends Control
class_name LoveLetter

signal finished_writing
signal chose_answer(said_yes: bool)

@onready var word_container: Control = $WordContainer
@onready var letter_words: Label = %LetterWords
@onready var letter_back: TextureRect = $LetterBack
@onready var yes_check_box: CheckBox = %YesCheckBox
@onready var no_check_box: CheckBox = %NoCheckBox
@onready var flip_timer: Timer = $FlipTimer
@onready var send_to_desk_timer: Timer = $SendToDeskTimer

@onready var starting_position := global_position
@onready var letter_back_starting_scale := letter_back.scale

var note_position: Vector2
var time_to_show := 1.0 
var time_to_write := 3.0

func write(target_position: Vector2) -> void:
	note_position = target_position
	no_check_box.visible = false
	yes_check_box.visible = false
	letter_words.visible_ratio = 0
	await show_letter(note_position)
	var word_tween := create_tween()
	word_tween.tween_property(letter_words, "visible_ratio", 1, time_to_write)
	await word_tween.finished
	flip_timer.start()

func present_option(target_position: Vector2) -> void:
	note_position = target_position
	await show_letter(note_position)
	no_check_box.show()
	yes_check_box.show()
	yes_check_box.grab_focus()

func _on_yes_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		no_check_box.hide()
		no_check_box.disabled = true
		yes_check_box.disabled = true
		yes_check_box.release_focus()
		yes_check_box.hide()
		yes_check_box.show()
		await send_letter_to_desk()
		chose_answer.emit(true)

func _on_no_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		yes_check_box.hide()
		yes_check_box.disabled = true
		no_check_box.disabled = true
		no_check_box.release_focus()
		no_check_box.hide()
		no_check_box.show()
		await send_letter_to_desk()
		chose_answer.emit(false)

func _on_flip_timer_timeout() -> void:
	await send_letter_to_desk()
	finished_writing.emit()

func show_letter(from_position: Vector2) -> void:
	hide()
	word_container.hide()
	letter_back.show()
	global_position = from_position
	letter_back.scale = Vector2(1, 1)
	show()
	var position_tween := create_tween()
	position_tween.tween_property(self, "global_position", starting_position, time_to_show)
	var scale_tween := create_tween()
	scale_tween.tween_property(letter_back, "scale", letter_back_starting_scale, time_to_show)
	await scale_tween.finished
	word_container.show()
	letter_back.hide()

func send_letter_to_desk() -> void:
	send_to_desk_timer.start()
	await send_to_desk_timer.timeout
	word_container.hide()
	letter_back.show()
	var position_tween := create_tween()
	position_tween.tween_property(self, "global_position", note_position, time_to_show)
	var scale_tween := create_tween()
	scale_tween.tween_property(letter_back, "scale", Vector2(1, 1), time_to_show)
	await scale_tween.finished
	hide()
	word_container.show()
	letter_back.hide()
	global_position = starting_position
	letter_back.scale = letter_back_starting_scale
