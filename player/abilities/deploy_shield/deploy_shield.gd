extends AbilityBase

@export var shield: PackedScene
var shield_instance: Node

func _ready() -> void:
	super()
	SyncManager.scene_spawned.connect(_on_scene_spawned)

var current_direction: SGFixedVector2
var should_override_movement: bool = false


func _preprocess_on_activated(direction: SGFixedVector2) -> void:
	current_direction = direction
	player.override_max_speed(SGFixed.mul(player.MAX_SPEED, FI.POINT_FIVE))

func _preprocess_on_updated(direction: SGFixedVector2) -> void:
	current_direction = direction

func _preprocess_on_deactivated(direction: SGFixedVector2) -> void:
	current_direction = direction
	player.reset_max_speed()

# IMPROVE: this component should not be calling these methods on the player directly - we need a better way to partially override player movement so that this type of component doesn't need to completely reimplement the player movement logic for a given state if only minor changes need to be made

# func _hook_before_player_movement() -> void:
# 	if player.movement_state == Player.MovementState.WALL_SLIDING:
# 		should_override_movement = true
# 		player.movement_state = Player.MovementState.FALLING
# 		player.apply_gravity()
# 		player.move_and_slide()
# 	else:
# 		should_override_movement = false

func _should_override_movement() -> bool:
	return should_override_movement

func _hook_after_player_movement() -> void:
	shield_instance.fixed_rotation = SGFixed.vector2(-FI.ONE, 0).angle_to(current_direction)
	shield_instance.sync_to_physics_engine()

func _postprocess_on_activated(_direction: SGFixedVector2) -> void:
	player.activate_ability(self)
	SyncManager.spawn(
		"shield",
		owner,
		shield,
		{
			"rotation": SGFixed.vector2(-FI.ONE, 0).angle_to(current_direction)
		}
	)

func _postprocess_on_deactivated(_direction: SGFixedVector2) -> void:
	SyncManager.despawn(shield_instance)
	shield_instance = null
	player.deactivate_ability(self)


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
