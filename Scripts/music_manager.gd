# ==== Pepper & Carrot Game ====
#
## @package music_manager 
# Manages music and it's layers.
#
# ==============================


extends Node

var is_loading = false

var _current_song
var _current_resources
var _game_manager

var is_playing = false

var _pre_pause_layer_state = {}

func _ready():
	_game_manager = get_node("/root/game_manager")
	set_process(true)
	
func _process(delta):
	if is_loading:
		_load_files()
		
func fire_event(event):
	for layer in _current_song.layers:
		if event in layer.unmute_events:
				layer.set_mute(true)
		if event in layer.mute_events:
				layer.set_mute(false)

## Internal, loads the files that are waiting in the async resource queue
func _load_files():
	is_loading = false
	for layer in _current_song.layers:
		print(is_loading)
		if _game_manager.resource_queue.is_ready(layer.resource_path):
				layer.resource = _game_manager.resource_queue.get_resource(layer.resource_path)
		if _game_manager.resource_queue.is_ready(layer.intro_resource_path):
				layer.intro_resource = _game_manager.resource_queue.get_resource(layer.intro_resource_path)
		if not layer.resource or not layer.intro_resource:
			is_loading = true
	# is_loading should be false if we have just finished loading
	if not is_loading:
		for layer in _current_song.layers:
			layer.stream_player.set_stream(layer.intro_resource)
			add_child(layer)
			layer.set_process(true)
			layer.stream_player.play()
			
## Loads a song from path
# @param path File path.
func load_song(path):
	
	if _current_song:
		for layer in _current_song.layers:
			layer.queue_free()
		_current_song.queue_free()
	_current_song = Music.from_file(path)
	add_child(_current_song)
	for layer in _current_song.layers:
		_game_manager.resource_queue.queue_resource(layer.resource_path)
		_game_manager.resource_queue.queue_resource(layer.intro_resource_path)
		
		var file = File.new()
		# Sanity check
		var unexistent_files = []
		if not file.file_exists(layer.intro_resource_path):
			unexistent_files.append(layer.intro_resource_path)
		if not file.file_exists(layer.resource_path):
			unexistent_files.append(layer.resource_path)
		
		if unexistent_files.size() > 0:
			for file in unexistent_files:
				print("ERROR: FILE %s does not exist, aborting song load, please fix your JSONs." % file)
				return
		layer.stream_player = StreamPlayer.new()
		layer.add_child(layer.stream_player)
		if layer.starts_muted:
			layer.stream_player.set_volume(1)
		is_loading = true
		
		add_child(layer)

class Music:
	extends Node
	
	var name
	var beats_per_bar
	var beats_per_minute
	var bars
	var layers = []

	static func from_file(path):
		var file_contents = ""
		var final_dict = {}
		var file = File.new()
		if !file.file_exists(path):
			return
		file.open(path, File.READ)
		

		
		while(!file.eof_reached()):
			file_contents = file_contents + file.get_line()
		final_dict.parse_json(file_contents)

		return from_dict(final_dict)
		
	static func from_dict(dict):
		var music = new()

		music.name = dict["name"]
		music.beats_per_bar = dict["beats_per_bar"]
		music.beats_per_minute = dict["beats_per_minute"]
		music.bars = dict["bars"]
		# Parse MusicLayers
		for dict_layer in dict["layers"]:
			var layer = MusicLayer.new()
			layer.name = dict_layer["name"]
			layer.resource_path = dict_layer["resource"]
			layer.intro_resource_path = dict_layer["intro_resource"]
			layer.starts_muted = dict_layer["starts_muted"]
			if dict_layer.has("mute_events"):
				layer.mute_events = dict_layer["mute_events"]
			if dict_layer.has("unmute_events"):
				layer.unmute_events = dict_layer["unmute_events"]
			layer.bars = music.bars
			music.layers.append(layer)
		return music
	class MusicLayer:
		
		extends Node
		
		var name
		var resource
		var bars
		var resource_path
		var intro_resource
		var intro_resource_path
		var stream_player
		var starts_muted = true
		var mute_events = []
		var unmute_events = []
		var is_playing_intro = true
		
		
		var _change_vol_on_bar
		
		var _mute = false
		
		func set_mute(mute):
			_change_vol_on_bar = get_current_bar()+1 % int(bars) # This will also unmute on the next bar if we are on the last one of the previous loop
															# pretty tasty huh?
			_mute = mute
				
		func _process(delta):
			if _change_vol_on_bar:
				if get_current_bar() == _change_vol_on_bar:
					if _mute:
						stream_player.set_volume(0)
					else:
						stream_player.set_volume(1)
					_change_vol_on_bar = null
			if is_playing_intro and stream_player.get_pos() == stream_player.get_length():
				is_playing_intro == false
				stream_player.set_stream(resource)
				stream_player.set_loop(true)
				stream_player.play()
		func get_current_bar():
			return floor((stream_player.get_pos()/stream_player.get_length())*bars)