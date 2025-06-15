extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const IP_ADDRESS = "127.0.0.1"
const MAX_CONNECTIONS = 20

var players = {}

var player_info: Dictionary

var players_loaded = 0

func set_player_info(player_name: String) -> void:
	player_info["name"] = player_name

func get_player_info() -> Dictionary:
	return player_info

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(address = "", port: int = 7000):
	if address.is_empty():
		address = IP_ADDRESS
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		return error
	peer.get_peer(1).set_timeout(0, 0, 3000)  # 3 seconds max timeout
	multiplayer.multiplayer_peer = peer

func create_game(port: int = 7000):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_CONNECTIONS)
	if error:
		print("error creating server: ", error)
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()

@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0

func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	print("registered player: ", new_player_info)

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)
	print("player disconnected")


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	print("connected")


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	print("connection failed")


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
	print("server disconnected")
