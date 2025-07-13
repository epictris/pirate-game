class_name AnimationManager extends Node2D

var player: Player
@onready var animation_player: NetworkAnimationPlayer = %NetworkAnimationPlayer

var state_transition: StateTransition
var movement_state: PlayerState.State

func _ready() -> void:
	player = owner
	await player.ready
	player.state_machine.state_transitioned.connect(_on_state_changed)
	animation_player.animation_finished.connect(_on_animation_finished)

func play_animation(animation_name: String) -> void:
	animation_player.play(animation_name)

func _on_state_changed(transition: StateTransition) -> void:
	state_transition = transition

func update_animation(_input: Dictionary) -> void:
	if state_transition:
		movement_state = state_transition.to
		match state_transition.to:
			PlayerState.State.WALL_SLIDING:
				animation_player.play(Animations.WALL_SLIDE_RIGHT if state_transition.data["wall_normal"] <= 0 else Animations.WALL_SLIDE_LEFT)
			PlayerState.State.SLIDING:
				animation_player.play(Animations.START_SLIDE_RIGHT if player.velocity.x >= 0 else Animations.START_SLIDE_LEFT)
		state_transition = null

	match movement_state:
		PlayerState.State.IDLE:
			animation_player.play(Animations.IDLE)
		PlayerState.State.RUNNING:
			animation_player.play(Animations.RUN_RIGHT if player.velocity.x >= 0 else Animations.RUN_LEFT)
		PlayerState.State.JUMPING:
			animation_player.play(Animations.JUMP_RIGHT if player.velocity.x >= 0 else Animations.JUMP_LEFT)
		PlayerState.State.FALLING:
			animation_player.play(Animations.FALL_RIGHT if player.velocity.x >= 0 else Animations.FALL_LEFT)
		PlayerState.State.WALL_JUMPING:
			animation_player.play(Animations.WALL_JUMP_RIGHT if player.velocity.x >= 0 else Animations.WALL_JUMP_LEFT)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == Animations.START_SLIDE_RIGHT:
		animation_player.play(Animations.SLIDE_RIGHT)
	if anim_name == Animations.START_SLIDE_LEFT:
		animation_player.play(Animations.SLIDE_LEFT)

func _save_state() -> Dictionary:
	return {
		movement_state = movement_state,
	}

func _load_state(state: Dictionary) -> void:
	movement_state = state["movement_state"]
