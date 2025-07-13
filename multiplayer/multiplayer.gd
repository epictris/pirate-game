extends Node2D

@export var player_scene: PackedScene

const DummyNetworkAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")

@onready var join_button: Button = %JoinButton
@onready var host_button: Button = %HostButton
@onready var play_offline_button: Button = %PlayOfflineButton
@onready var ip_field: LineEdit = %HostField
@onready var port_field: LineEdit = %PortField
@onready var connection_panel: PanelContainer = %ConnectionPanel
@onready var message_label: Label = %MessageLabel
@onready var reset_button: Button = %ResetButton
@onready var spawn_point: Marker2D = %SpawnPoint

var logging_enabled = true

var host_player: SGCharacterBody2D
var client_player: SGCharacterBody2D

func _ready():
	join_button.pressed.connect(_join_game)
	host_button.pressed.connect(_host_game)
	play_offline_button.pressed.connect(_play_offline)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	SyncManager.sync_started.connect(_on_syncmanager_sync_started)
	SyncManager.sync_stopped.connect(_on_syncmanager_sync_stopped)
	SyncManager.sync_lost.connect(_on_syncmanager_sync_lost)
	SyncManager.sync_regained.connect(_on_syncmanager_sync_regained)
	SyncManager.sync_error.connect(_on_syncmanager_sync_error)

func _join_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_field.text, int(port_field.text))
	multiplayer.multiplayer_peer = peer
	connection_panel.visible = false
	message_label.text = "Connecting..."

func _host_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(int(port_field.text), 1)
	multiplayer.multiplayer_peer = peer
	connection_panel.visible = false
	message_label.text = "Listening..."

func _play_offline():
	SyncManager.set_network_adaptor(DummyNetworkAdaptor.new())
	SyncManager.start()
	connection_panel.visible = false
	_spawn_host()


func _spawn_host():
	host_player = player_scene.instantiate()
	host_player.spawn_position = SGFixed.vector2(SGFixed.ONE * 70, SGFixed.ONE * 130) 
	add_child(host_player)


func _on_peer_connected(peer_id: int):
	message_label.text = "Connected"
	SyncManager.add_peer(peer_id)
	host_player = player_scene.instantiate()
	client_player = player_scene.instantiate()

	host_player.set_multiplayer_authority(1)
	if multiplayer.is_server():
		client_player.set_multiplayer_authority(peer_id)
	else:
		client_player.set_multiplayer_authority(multiplayer.get_unique_id())
	host_player.spawn_position = SGFixed.vector2(SGFixed.ONE * 70, SGFixed.ONE * 130) 
	client_player.spawn_position = SGFixed.vector2(SGFixed.ONE * 300, SGFixed.ONE * 130)
	add_child(host_player)
	add_child(client_player)

	if multiplayer.is_server():
		message_label.text = "Starting..."
		await get_tree().create_timer(1.0).timeout
		SyncManager.start()

func _on_peer_disconnected(peer_id: int):
	message_label.text = "Disconnected"
	SyncManager.remove_peer(peer_id)

func _on_server_disconnected():
	_on_peer_disconnected(1)

func _on_reset_button_pressed():
	SyncManager.stop()
	SyncManager.clear_peers()
	var peer = get_tree().network_peer
	if peer:
		peer.close_connection()
	get_tree().reload_current_scene()

func _on_syncmanager_sync_started():
	message_label.text = "Started"
	if logging_enabled and not SyncReplay.active:
		var log_file_name: String = "replay_" + str(multiplayer.is_server()) + ".log"
		SyncManager.start_logging("/home/tris/projects/pirate-game/replays/" + log_file_name)

func _on_syncmanager_sync_stopped():
	if logging_enabled:
		SyncManager.stop_logging()

func _on_syncmanager_sync_lost():
	pass

func _on_syncmanager_sync_regained():
	pass

func _on_syncmanager_sync_error(msg: String):
	message_label.text = msg
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
	SyncManager.clear_peers()
	pass

func setup_match_for_replay(_my_peer_id: int, _peer_ids: Array, _match_info: Dictionary) -> void:
	connection_panel.visible = false
	reset_button.visible = false
