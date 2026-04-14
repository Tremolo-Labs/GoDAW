extends Node

signal playback_finished()
signal on_note(progress)

@export var INSTRUMENTS = {}
@onready var timer = $Timer

# Data
var data: SongSequence
var events = []
var total_time = 0.0
var current_time = 0.0
var event_index = 0
var playing: bool = false
var paused: bool = false

# Functions
func sequence(sequence: SongSequence):
	data = sequence
	events.clear()
	for track in data.tracks:
		track = track as Track
		var track_time = 0.0
		for note in track.notes:
			note = note as Note
			track_time += note.note_start_delta
			events.append({"time": track_time, "type": "play", "instrument": track.instrument, "note": note})
			events.append({"time": track_time + note.duration, "type": "stop", "instrument": track.instrument, "note": note})
	events.sort_custom(func(a, b): return a.time < b.time)
	total_time = events.back().time if events else 0.0

func play_note(instrument_name: String, note):
	(INSTRUMENTS[instrument_name] as Instrument).play_note(note)

func stop_note(instrument_name: String, note):
	(INSTRUMENTS[instrument_name] as Instrument).stop_note(note)

func play():
	playing = true
	paused = false
	timer.start(0.01)  # 10ms timer

func stop():
	playing = false
	timer.stop()
	current_time = 0.0
	event_index = 0
	# Stop all notes
	for instrument in INSTRUMENTS.values():
		(instrument as Instrument).stop_all_notes()

func pause():
	paused = true
	timer.stop()

func seek(sec: float):
	current_time = sec
	event_index = 0
	while event_index < events.size() and events[event_index].time < current_time:
		event_index += 1
	# For simplicity, don't replay past notes on seek

func _on_timer_timeout():
	if not playing or paused:
		return
	current_time += 0.01
	while event_index < events.size() and events[event_index].time <= current_time:
		var event = events[event_index]
		if event.type == "play":
			play_note(event.instrument, event.note)
		else:
			stop_note(event.instrument, event.note)
		event_index += 1
	on_note.emit(current_time / total_time * 100 if total_time > 0 else 0)
	if event_index >= events.size():
		playback_finished.emit()
		stop()
