class_name PowderData
extends Resource

## Debuff modifier triggered on spark
@export var spark_debuff_modifier: Modifier

## Initial and max stamina
@export var max_stamina: float = 10.0

#@export var name: String
#
##probably going to be a string or something other then a number at some point
#@export var type = 1
#
#@export var quality = 1


# Defer verification until after exported vars have been deserialized
# See https://github.com/godotengine/godot-proposals/issues/296

#func _init():
#	call_deferred("_verify")
#
#func _verify():
#	assert(spark_debuff_modifier != null,
#		"[PowderData] spark_debuff_modifier is not set on %s" % resource_path)
