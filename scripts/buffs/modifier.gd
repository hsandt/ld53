class_name Modifier
extends Resource

@export var description: String
@export var attribute: String
#effect in terms of math on number
@export var effect: String
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
