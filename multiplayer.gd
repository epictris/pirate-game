extends Node2D

@onready var join_button: Button = %Control/Join
@onready var host_button: Button = %Control/Host
@onready var name_field: LineEdit = %Control/Name
@onready var ip_field: LineEdit = %Control/IpAddress
@onready var port_field: LineEdit = %Control/Port

func _ready():
	join_button.pressed.connect(_join_game)
	host_button.pressed.connect(_host_game)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	name_field.text_changed.connect(_on_name_changed)

func _join_game():
	if Lobby.get_player_info() == null or Lobby.get_player_info().name == "":
		return
	Lobby.join_game(ip_field.text, port_field.text.to_int())

func _host_game():
	if Lobby.get_player_info().is_empty() or Lobby.get_player_info().name.is_empty():
		return
	var error = Lobby.create_game(port_field.text.to_int())
	if error:
		return
	get_tree().change_scene_to_file("res://lobby_ui.tscn")

func _on_connected_ok():
	get_tree().change_scene_to_file("res://lobby_ui.tscn")

func _on_name_changed(new_text):
	Lobby.set_player_info(new_text)
