extends AbilityBase

@export var sabre_slice_down_scene: PackedScene
@export var sabre_slice_up_scene: PackedScene

@onready var combo_timer: NetworkTimer = %ComboTimer
var sabre_instance: SGArea2D

var consecutive_slices: int = 0

func _ready() -> void:
	super()
	SyncManager.scene_spawned.connect(_on_scene_spawned)
	combo_timer.timeout.connect(_on_combo_timer_timeout)

func _on_combo_timer_timeout() -> void:
	consecutive_slices = 0

func _preprocess_on_activated(direction: SGFixedVector2) -> void:
	if ability_manager.is_ability_active(self):
		return
	combo_timer.stop()

	ability_manager.activate_ability(self)
	var next_slice_scene: PackedScene
	if consecutive_slices % 2 == 0:
		next_slice_scene = sabre_slice_down_scene
	else:
		next_slice_scene = sabre_slice_up_scene
	SyncManager.spawn(
		"sabre",
		player,
		next_slice_scene,
		{
			"rng_seed": player.rng.randi(),
			"direction": direction,
			"creator": get_path(),
			"start_tick": SyncManager.current_tick,
		}
	)

func _hook_after_player_movement() -> void:
	if !sabre_instance:
		return
	sabre_instance.update()

func _on_scene_spawned(node_name, spawned_node, _scene, data):
	if node_name == "sabre" and data.get("creator") == get_path():
		sabre_instance = spawned_node
		sabre_instance.finished.connect(_on_ability_finished)

func _on_ability_finished() -> void:
	consecutive_slices += 1
	sabre_instance = null
	ability_manager.deactivate_ability(self)
	combo_timer.start()

func _save_state() -> Dictionary:
	return {
		"consecutive_slices": consecutive_slices,
	}

func _load_state(state: Dictionary) -> void:
	consecutive_slices = state.consecutive_slices
