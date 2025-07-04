extends AbilityBase

@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene

@onready var cooldown_timer: NetworkTimer = %CooldownTimer

var current_direction: SGFixedVector2
var on_cooldown: bool = false

func _ready() -> void:
	cooldown_timer.timeout.connect(_on_timeout)
	super()

func _on_activate_input(direction: SGFixedVector2) -> void:
	current_direction = direction
	if !player.has_active_ability():
		player.activate_ability(self)

func _on_update_input(_direction: SGFixedVector2) -> void:
	current_direction = _direction

func _on_deactivate_input(_direction: SGFixedVector2) -> void:
	if player.is_ability_active(self):
		player.deactivate_ability(self)

func _hook_after_player_movement() -> void:
	if !on_cooldown:
		on_cooldown = true
		var data = {
			fixed_position = player.fixed_position.copy().add(current_direction.mul(FI.ONE)),
			direction = current_direction,
			player_path = player.get_path(),
		}
		SyncManager.spawn("bullet", player.get_parent(), bullet_scene, data)
		cooldown_timer.start()

func _on_timeout() -> void:
	on_cooldown = false
