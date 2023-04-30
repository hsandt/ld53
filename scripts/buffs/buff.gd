class_name Buff
extends Resource

@export var attribute: String
@export var effect: String
@export var value: float
## chance of being triggered
@export_range(0.0, 1.0) var probability: float
## in seconds
@export var duration: float
## index of other buffs this object deals with
@export var chain: Array
