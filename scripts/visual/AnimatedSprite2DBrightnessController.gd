class_name AnimatedSprite2DBrightnessController
extends AnimatedSprite2D
## This script allows us to set shader parameters "brightness" and native modulate
## on the animated sprite material, which should use the shader custom_sprite_shader.gdshader.


## Timer used to change brightness for a given duration
@export var brighten_timer: Timer

## When true, update material brightness to match state variable every frame
## When false, reset brightness
## You can set this to true via code of animation
@export var override_brightness: bool

## When override_brightness is true, this is used to update the shader material
## brightness parameter
## You can set this to true via code of animation
@export var target_brightness: float

## When true, update modulate to match state variable every frame
## When false, reset modulate
## You can set this to true via code of animation
@export var override_modulate: bool

## When override_modulate is true, this is used to update the shader material
## modulate
## You can set this to true via code of animation
@export var target_modulate: Color

# Initial state

var initial_brightness: float
var initial_modulate: Color


# Current state

## Flag that tracks whether override_brightness was true last frame
## to detect when it becomes false, so we can reset properties to reach a clean state
var was_overriding_brightness: bool

## Flag that tracks whether override_modulate was true last frame
## to detect when it becomes false, so we can reset properties to reach a clean state
var was_overriding_modulate: bool


## Shader Material
## Each entity should have its own material instance
## If you share the same material via scene inheritance or resource reference,
## make sure to check Material > Resource > Local to Scene so it auto-generates
## unique instances (even at edit time)
@onready var shader_material = material as ShaderMaterial


func _ready():
	initialize()
	setup()


func initialize():
	assert(brighten_timer, "brighten_timer is not set on %s" % get_path())

	var _err = brighten_timer.timeout.connect(_on_brighten_timer_timeout)

	if shader_material:
		initial_brightness = shader_material.get_shader_parameter("brightness")
		initial_modulate = modulate

func setup():
	override_brightness = false
	target_brightness = 0.0
	was_overriding_brightness = false

	override_modulate = false
	target_modulate = Color.WHITE
	was_overriding_modulate = false

	# On first frame and after restart, was_overriding_brightness/modulate is false
	# so _process will not clear brightness/modulate, so do clear it now
	if shader_material:
		shader_material.set_shader_parameter("brightness", initial_brightness)
		modulate = initial_modulate


func _process(_delta):
	if override_brightness:
		if shader_material:
			shader_material.set_shader_parameter("brightness", target_brightness)
	elif was_overriding_brightness:
		if shader_material:
			# Revert to initial value for consistency with setup
			shader_material.set_shader_parameter("brightness", initial_brightness)

	was_overriding_brightness = override_brightness

	if override_modulate:
		if shader_material:
			modulate = target_modulate
	elif was_overriding_modulate:
		if shader_material:
			# Revert to initial value for consistency with setup
			modulate = initial_modulate

	was_overriding_modulate = override_modulate


## Enable brightness override and set target brightness for passed duration
## If no duration is passed, use brighten timer default duration
func set_brightness_for_duration(brightness: float, duration: float = -1):
	brighten_timer.start(duration)
	override_brightness = true
	target_brightness = brightness


## Callback for brighten timer timeout: clear override brightness
func _on_brighten_timer_timeout():
	override_brightness = false
	target_brightness = 0.0
