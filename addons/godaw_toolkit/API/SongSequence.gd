class_name SongSequence extends Resource

#Tempo in bpm
@export var tracks: Array = []
@export var tempo: int = 0: set = set_tempo
@export var master_pitch: int = 1: set = set_pitch
@export var master_volume: int = linear_to_db(0.5): set = set_volume

# setter functions
func set_tempo(val: int):
	tempo = val

func set_pitch(val: int):
	master_pitch = val

func set_volume(val: int):
	master_volume = linear_to_db(val)

func add_track(val: Track):
	tracks.append(val)
