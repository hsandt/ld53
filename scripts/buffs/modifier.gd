class_name Modifier
extends Resource

@export var icon_path: String
@export var description: String
@export var attribute: String
## Which type of math operation to apply to the attribute
@export var operation: Enums.ModifierOperation
##value in terms af attribute change
@export var value: float
## chance of being triggered
@export_range(0.0, 1.0) var probability: float
## in seconds
@export var duration: float
## the bad possibility on spark
@export var worsen: Modifier
## the good possibility on spark
@export var lucky: Modifier
