class_name Modifier
extends Resource

@export var icon_texture: Texture2D
@export var description: String
@export var attribute: String
## Which type of math operation to apply to the attribute
@export var operation: Enums.ModifierOperation
##value in terms of attribute change
@export var value: float
## probability of triggering lucky modifier on consume
@export_range(0.0, 1.0) var lucky_modifier_probability: float = 0.5
## the bad possibility on spark
@export var worsen: Modifier
## the good possibility on spark
@export var lucky: Modifier
