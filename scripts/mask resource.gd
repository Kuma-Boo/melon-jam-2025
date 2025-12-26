extends Resource
class_name MaskResource

enum MASK_TYPES {
	FOX,
	BEAR,
	RABBIT,
	CURSED,
	COUNT
}

@export var mask_type : MASK_TYPES
@export var texture : Texture2D
