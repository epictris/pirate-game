extends AbilityBase

@export var shield: PackedScene
var shield_instance: Node

func _ready() -> void:
	super()
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func activate(direction: SGFixedVector2) -> void:
	SyncManager.spawn("shield", owner, shield, {"rotation": SGFixed.vector2(-FI.ONE, 0).angle_to(direction)})
	player.override_max_speed(SGFixed.mul(player.MAX_SPEED, FI.POINT_FIVE))

func update(direction: SGFixedVector2) -> void:
	if shield_instance:
		shield_instance.fixed_rotation = SGFixed.vector2(-FI.ONE, 0).angle_to(direction)
		shield_instance.sync_to_physics_engine()

func deactivate(_direction: SGFixedVector2) -> void:
	if shield_instance:
		SyncManager.despawn(shield_instance)
		player.reset_max_speed()
		shield_instance = null
		player.set_movement_override(false)


# IMPROVE: this component should not be calling these methods on the player directly - we need a better way to partially override player movement so that this type of component doesn't need to completely reimplement the player movement logic for a given state if only minor changes need to be made
func _network_process(_input: Dictionary) -> void:
	if shield_instance:
		if player.movement_state == Player.MovementState.WALL_SLIDING:
			player.set_movement_override(true)
			player.movement_state = Player.MovementState.FALLING
			player.apply_gravity()
			player.move_and_slide()
		else:
			player.set_movement_override(false)

func _on_scene_spawned(node_name, spawned_node, _scene, _data) -> void:
	if node_name == "shield":
		shield_instance = spawned_node


func _save_state() -> Dictionary:
	var state: Dictionary = {}
	if shield_instance:
		state["shield_instance_path"] = shield_instance.get_path()
	return state

func _load_state(state: Dictionary) -> void:
	if state.get("shield_instance_path"):
		shield_instance = get_node(state["shield_instance_path"])
	else:
		shield_instance = null
