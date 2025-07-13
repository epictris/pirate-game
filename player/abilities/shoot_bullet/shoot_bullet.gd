extends AbilityBase

@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene

@onready var cooldown_timer: NetworkTimer = %CooldownTimer

var current_direction: SGFixedVector2
var on_cooldown: bool = false

func _ready() -> void:
	super()
	cooldown_timer.timeout.connect(_on_timeout)

func _preprocess_on_activated(direction: SGFixedVector2) -> void:
	ability_manager.activate_ability(self)
	current_direction = direction

func _preprocess_on_updated(_direction: SGFixedVector2) -> void:
	current_direction = _direction

func _preprocess_on_deactivated(_direction: SGFixedVector2) -> void:
	ability_manager.deactivate_ability(self)

func _hook_after_player_movement() -> void:
	on_cooldown = false
	if !on_cooldown:
		on_cooldown = true
		var data = {
			fixed_position = player.fixed_position.copy(),
			direction = current_direction,
			player_path = player.get_path(),
		}
		SyncManager.spawn("bullet", player.get_parent(), bullet_scene, data)
		cooldown_timer.start()

func _on_timeout() -> void:
	on_cooldown = false

func _save_state() -> Dictionary:
	return {
		on_cooldown = on_cooldown,
	}

func _load_state(state: Dictionary) -> void:
	on_cooldown = state["on_cooldown"]
