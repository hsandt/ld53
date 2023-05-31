class_name AnimatedSprite2DWithOutline
extends AnimatedSprite2D
## This script allows us to set shader parameters "outline_thickness"
## on the animated sprite material, which should use the shader outline_shader.gdshader
## You can set this to true via code of animation


## When true, update material outline_color parameter to match state variable every frame
## When false, reset outline_color parameter
## You can set this to true via code of animation
@export var override_outline_color: bool

## When override_outline_color is true, this is used to update the shader material
## outline_color parameter
## You can set this to true via code of animation
@export var target_outline_color: Color

## When true, update material outline_thickness parameter to match state variable every frame
## When false, reset outline_thickness parameter
## You can set this to true via code of animation
@export var override_outline_thickness: bool

## When override_outline_thickness is true, this is used to update the shader material
## outline_thickness parameter
## You can set this to true via code of animation
@export var target_outline_thickness: float

# Initial state

var initial_outline_color: Color
var initial_outline_thickness: float


# Current state

## Flag that tracks whether override_outline_color was true last frame
## to detect when it becomes false, so we can reset properties to reach a clean state
var was_overriding_outline_color: bool

## Flag that tracks whether override_outline_thickness was true last frame
## to detect when it becomes false, so we can reset properties to reach a clean state
var was_overriding_outline_thickness: bool


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
	if shader_material:
		initial_outline_color = shader_material.get_shader_parameter("outline_color")
		initial_outline_thickness = shader_material.get_shader_parameter("outline_thickness")

func setup():
	override_outline_color = false
	target_outline_color = Color.WHITE
	was_overriding_outline_color = false

	override_outline_thickness = false
	target_outline_thickness = 0.0
	was_overriding_outline_thickness = false

	# On first frame and after restart, was_overriding_[param] is false
	# so _process will not clear [param], so do clear it now
	if shader_material:
		shader_material.set_shader_parameter("outline_color", initial_outline_color)
		shader_material.set_shader_parameter("outline_thickness", initial_outline_thickness)


func _process(_delta):
	if override_outline_color:
		if shader_material:
			shader_material.set_shader_parameter("outline_color", target_outline_color)
	elif was_overriding_outline_color:
		if shader_material:
			# Revert to initial value for consistency with setup
			shader_material.set_shader_parameter("outline_color", initial_outline_color)

	was_overriding_outline_color = override_outline_color

	if override_outline_thickness:
		if shader_material:
			shader_material.set_shader_parameter("outline_thickness", target_outline_thickness)
	elif was_overriding_outline_thickness:
		if shader_material:
			# Revert to initial value for consistency with setup
			shader_material.set_shader_parameter("outline_thickness", initial_outline_thickness)

	was_overriding_outline_thickness = override_outline_thickness


## Enable outline_color override and set target outline_color
func set_outline_color(outline_color: Color):
	override_outline_color = true
	target_outline_color = outline_color


## Disable outline_color override
func reset_outline_color():
	override_outline_color = false
	target_outline_color = Color.WHITE

## Enable outline_thickness override and set target outline_thickness
func set_outline_thickness(outline_thickness: float):
	override_outline_thickness = true
	target_outline_thickness = outline_thickness


## Disable outline_thickness override
func reset_outline_thickness():
	override_outline_thickness = false
	target_outline_thickness = 0.0
