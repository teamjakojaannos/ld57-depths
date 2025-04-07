extends AudioStreamPlayer

enum Song {
	Music_1,
	Music_2,
	Boss_1
}

const music_track_1: AudioStream = preload("res://levels/bgm1.ogg")
const music_track_2: AudioStream = preload("res://levels/bgm2.ogg")
const boss_music_1: AudioStream = preload("res://levels/bgm3.ogg")

func _ready() -> void:
	stream = music_track_1
	play()

func play_song(song: Song):
	if song == Song.Music_1:
		stream = music_track_1
		play()
	elif song == Song.Music_2:
		stream = music_track_2
		play()
	elif song == Song.Boss_1:
		stream = boss_music_1
		play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_track_1"):
		play_song(Song.Music_1)
	if event.is_action_pressed("switch_track_2"):
		play_song(Song.Music_2)
	if event.is_action_pressed("switch_track_3"):
		play_song(Song.Boss_1)
