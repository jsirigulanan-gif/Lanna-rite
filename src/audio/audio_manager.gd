class_name AudioManager
extends Node

## Procedural audio manager for Shadow of Lanna: Midnight Rite.
## Synthesizes retro survival horror sound effects, footsteps, heartbeat tension, and jumpscare stings in real time.

var _heartbeat_timer: float = 0.0
var _step_timer: float = 0.0
var _is_heartbeat_active: bool = false

var _player_sfx: AudioStreamPlayer = null
var _player_heartbeat: AudioStreamPlayer = null
var _player_steps: AudioStreamPlayer = null

func _ready() -> void:
	_player_sfx = AudioStreamPlayer.new()
	_player_sfx.name = "SFXPlayer"
	add_child(_player_sfx)

	_player_heartbeat = AudioStreamPlayer.new()
	_player_heartbeat.name = "HeartbeatPlayer"
	add_child(_player_heartbeat)

	_player_steps = AudioStreamPlayer.new()
	_player_steps.name = "StepsPlayer"
	add_child(_player_steps)

	_hook_gameplay_signals()

func _process(delta: float) -> void:
	_process_heartbeat(delta)
	_process_footsteps(delta)

func _process_heartbeat(delta: float) -> void:
	if _is_heartbeat_active:
		_heartbeat_timer += delta
		if _heartbeat_timer >= 0.85: # Heartbeat pulse rate
			_heartbeat_timer = 0.0
			_play_pulse_sound(75.0, 0.12, 0.6) # Thump 1
			get_tree().create_timer(0.2).timeout.connect(func():
				_play_pulse_sound(60.0, 0.16, 0.5) # Thump 2
			)

func _process_footsteps(delta: float) -> void:
	var mgr: SiblingManager = get_tree().root.find_child("SiblingManager", true, false) as SiblingManager
	if mgr == null or mgr.get_active_sibling() == null:
		return

	var sibling: PlayerSibling = mgr.get_active_sibling()
	if sibling.is_hidden or sibling.velocity.length_squared() < 10.0:
		_step_timer = 0.0
		return

	var is_running: bool = sibling.current_state == PlayerSibling.State.RUN
	var step_interval: float = 0.26 if is_running else 0.44

	_step_timer += delta
	if _step_timer >= step_interval:
		_step_timer = 0.0
		_play_footstep_sound(is_running)

func _hook_gameplay_signals() -> void:
	# Hook enemy chase & detection states
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		var spirit: SpiritAI = e as SpiritAI
		if spirit != null:
			spirit.state_changed.connect(_on_spirit_state_changed)
			spirit.target_spotted.connect(_on_spirit_target_spotted)

func _on_spirit_state_changed(new_state: SpiritAI.State, _old_state: SpiritAI.State) -> void:
	if new_state == SpiritAI.State.CHASE:
		_is_heartbeat_active = true
	else:
		_is_heartbeat_active = false

func _on_spirit_target_spotted(_target: Node2D) -> void:
	play_jumpscare_sting()

## Plays a low-frequency synthesized bass pulse (Heartbeat sound).
func _play_pulse_sound(freq: float, duration: float, volume: float) -> void:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var byte_array := PackedByteArray()
	byte_array.resize(num_samples * 2)

	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var envelope: float = 1.0 - (t / duration)
		var wave: float = sin(t * freq * TAU) * envelope * volume
		var sample_val: int = int(clampf(wave, -1.0, 1.0) * 32767.0)
		byte_array.encode_s16(i * 2, sample_val)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = byte_array

	_player_heartbeat.stream = stream
	_player_heartbeat.play()

## Plays creaky wooden footstep sound.
func _play_footstep_sound(is_running: bool) -> void:
	var base_freq: float = randf_range(130.0, 175.0)
	var duration: float = 0.08 if is_running else 0.06
	var volume: float = 0.45 if is_running else 0.22

	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var byte_array := PackedByteArray()
	byte_array.resize(num_samples * 2)

	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var envelope: float = 1.0 - (t / duration)
		var wave: float = (sin(t * base_freq * TAU) + (randf() - 0.5) * 0.4) * envelope * volume
		var sample_val: int = int(clampf(wave, -1.0, 1.0) * 32767.0)
		byte_array.encode_s16(i * 2, sample_val)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = byte_array

	_player_steps.stream = stream
	_player_steps.play()

## Plays dramatic horror string sting / screech when spotted.
func play_jumpscare_sting() -> void:
	var duration: float = 0.45
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var byte_array := PackedByteArray()
	byte_array.resize(num_samples * 2)

	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var envelope: float = (1.0 - (t / duration)) * 0.7
		# Dissonant tritone chord (220Hz + 311Hz + 440Hz)
		var wave: float = (sin(t * 220.0 * TAU) + sin(t * 311.1 * TAU) + sin(t * 440.0 * TAU)) * 0.33 * envelope
		var sample_val: int = int(clampf(wave, -1.0, 1.0) * 32767.0)
		byte_array.encode_s16(i * 2, sample_val)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = byte_array

	_player_sfx.stream = stream
	_player_sfx.play()

## Plays a pleasant pickup chime for inventory items.
func play_pickup_sound() -> void:
	_play_chime_sound(523.25, 659.25, 0.18)

## Plays a chime with 2 pitches.
func _play_chime_sound(freq1: float, freq2: float, duration: float) -> void:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var byte_array := PackedByteArray()
	byte_array.resize(num_samples * 2)

	var half_point: int = num_samples / 2
	for i in range(num_samples):
		var freq: float = freq1 if i < half_point else freq2
		var t: float = float(i) / float(sample_rate)
		var envelope: float = 1.0 - (t / duration)
		var wave: float = sin(t * freq * TAU) * envelope * 0.35
		var sample_val: int = int(clampf(wave, -1.0, 1.0) * 32767.0)
		byte_array.encode_s16(i * 2, sample_val)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = byte_array

	_player_sfx.stream = stream
	_player_sfx.play()

## Plays wooden creak sound for door and locker.
func play_creak_sound() -> void:
	_play_pulse_sound(120.0, 0.35, 0.45)
