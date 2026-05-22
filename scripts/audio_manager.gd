extends Node

# 音频管理器
class_name AudioManager

var music_volume = 0.5
var sfx_volume = 0.8

var music_player = AudioStreamPlayer.new()
var sfx_players = []

# 音效池
var sfx_pool_size = 5

func _ready():
	# 设置音乐播放器
	music_player.bus = "Music"
	add_child(music_player)
	
	# 创建音效播放器池
	for i in range(sfx_pool_size):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

func play_music(stream: AudioStream, fade_time: float = 0.0):
	if music_player.stream == stream:
		return
	
	if fade_time > 0:
		music_player.stream = stream
		music_player.play()
	else:
		music_player.stream = stream
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(stream: AudioStream):
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
	
	# 如果所有播放器都在使用，强制使用第一个
	sfx_players[0].stream = stream
	sfx_players[0].play()

func set_music_volume(volume: float):
	music_volume = volume
	music_player.volume_db = linear_to_db(volume)

func set_sfx_volume(volume: float):
	sfx_volume = volume
	# 更新所有音效播放器的音量
