extends SceneTree

## Deterministically synthesizes the game's compact original sound library.
const SAMPLE_RATE := 44100
const EFFECTS := {
	"click": 0.08, "shot": 0.18, "impact": 0.12, "ricochet": 0.22,
	"shield": 0.24, "alert": 0.3, "laser": 0.2, "enemy_down": 0.36,
	"exit": 0.55, "failure": 0.65, "victory": 0.9,
}

## Creates the destination and writes every named waveform.
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://Assets/Audio"))
	for effect in EFFECTS:
		_write_wav(effect, EFFECTS[effect])
	quit()

## Encodes one mono 16-bit WAV resource.
func _write_wav(effect: String, duration: float) -> void:
	var sample_count := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = effect.hash()
	for index in sample_count:
		var t := float(index) / SAMPLE_RATE
		var envelope := pow(1.0 - float(index) / sample_count, 2.0)
		var value := clampf(_sample(effect, t, duration, rng) * envelope, -1.0, 1.0)
		bytes.encode_s16(index * 2, int(value * 28000.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	stream.save_to_wav("res://Assets/Audio/%s.wav" % effect)

## Produces each effect from layered oscillators and seeded noise.
func _sample(effect: String, t: float, duration: float, rng: RandomNumberGenerator) -> float:
	var phase := t / duration
	var noise := rng.randf_range(-1.0, 1.0)
	match effect:
		"click": return sin(TAU * 900.0 * t) * 0.5 + noise * 0.12
		"shot": return sin(TAU * (180.0 - 100.0 * phase) * t) * 0.55 + noise * 0.5
		"impact": return sin(TAU * 90.0 * t) * 0.55 + noise * 0.25
		"ricochet": return sin(TAU * (900.0 + 1200.0 * phase) * t) * 0.65
		"shield": return sin(TAU * 300.0 * t) * sin(TAU * 35.0 * t) * 0.65
		"alert": return sin(TAU * (440.0 + 180.0 * phase) * t) * 0.5
		"laser": return sin(TAU * (1100.0 - 500.0 * phase) * t) * 0.65
		"enemy_down": return sin(TAU * (280.0 - 220.0 * phase) * t) * 0.6 + noise * 0.18
		"exit": return sin(TAU * (440.0 + 440.0 * floor(phase * 3.0)) * t) * 0.45
		"failure": return sin(TAU * (260.0 - 150.0 * phase) * t) * 0.55
		"victory": return sin(TAU * (392.0 + 131.0 * floor(phase * 4.0)) * t) * 0.45
	return 0.0
