extends AudioStreamPlayer
class_name Jukebox

enum Song {
	Music_1,
	Music_2,
	Boss_1,
	Shop,
}

const music_track_1: AudioStream = preload("res://levels/bgm1.ogg")
const music_track_2: AudioStream = preload("res://levels/bgm2.ogg")
const boss_music_1: AudioStream = preload("res://levels/bgm3.ogg")
const shop_music: AudioStream = preload("res://shop/shopbgm.ogg")

var music_fade_tween: Tween
var music_fade_mult = 1.0
var counter = 0
var current_song: Song

func _ready() -> void:
	Globals.music = self
	Globals.volume_changed.connect(update_volume)
	
	current_song = Song.Music_1
	stream = music_track_1
	update_volume()
	play()

func update_volume():
	self.volume_linear = Globals.music_volume_percent * music_fade_mult

func play_song(song: Song):
	current_song = song
	var song_to_play
	match song:
		Song.Music_1:
			song_to_play = music_track_1
		Song.Music_2:
			song_to_play = music_track_2
		Song.Boss_1:
			song_to_play = boss_music_1
		Song.Shop:
			song_to_play = shop_music
		_ :
			print("Trying to play song that doesn't exist: ", song)
			return
	
	
	if music_fade_tween != null:
		music_fade_tween.kill()
	
	counter += 1
	var current_id = counter
	
	music_fade_tween = create_tween()
	var fade_time = 1.0
	await fade_out(fade_time)
	
	# if we switched to another song while fading out, cancel the song-switch
	if current_id != counter:
		return
	
	stream = song_to_play
	play()
	
	await fade_in(1.0)

func do_music_fade(fade_mult: float):
	music_fade_mult = fade_mult
	update_volume()

func fade_out(fade_time: float) -> void:
	if music_fade_tween != null:
		music_fade_tween.kill()

	music_fade_tween = create_tween()
	await music_fade_tween.tween_method(do_music_fade, music_fade_mult, 0.0, fade_time).finished

func fade_in(un_fade_time: float) -> void:
	if music_fade_tween != null:
		music_fade_tween.kill()

	music_fade_tween = create_tween()
	await music_fade_tween.tween_method(do_music_fade, music_fade_mult, 1.0, un_fade_time).finished

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_track_1"):
		play_song(Song.Music_1)
	if event.is_action_pressed("switch_track_2"):
		play_song(Song.Music_2)
	if event.is_action_pressed("switch_track_3"):
		play_song(Song.Boss_1)
