extends Node2D

@onready var item_list: ItemList = %ItemList

@export var player_scene: PackedScene

func _update_connected_players():
	item_list.clear()
	for player_id in Lobby.players:
		var player_name = Lobby.players[player_id].name
		if player_id == 1:
			player_name = player_name + " (Host)"
		item_list.add_item(player_name, null, false)

func _ready():
	Lobby.player_connected.connect(player_connected)
	Lobby.player_disconnected.connect(player_disconnected)
	add_player(multiplayer.get_unique_id())

	_update_connected_players()

func player_connected(peer_id, player_info):
	add_player(peer_id)
	_update_connected_players()


func player_disconnected(peer_id, player_info):
	_update_connected_players()

func add_player(peer_id):
	print("adding player: ", peer_id, " - ", multiplayer.get_unique_id())
	var new_player = player_scene.instantiate()
	new_player.set_multiplayer_authority(peer_id)
	new_player.name = str(peer_id)
	add_child(new_player, true)
	new_player.position = %SpawnLocation.position
