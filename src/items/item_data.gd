class_name ItemData
extends Resource

## Data definition for inventory items in Shadow of Lanna: Midnight Rite.
## Defines item identity, category, healing/fuel values, and display properties.

enum ItemType {
	CONSUMABLE,
	KEY_ITEM,
	PUZZLE,
}

@export var id: String = ""
@export var item_name: String = ""
@export_multiline var description: String = ""
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var heal_amount: int = 0
@export var fuel_amount: float = 0.0
@export var icon_color: Color = Color.WHITE
@export var max_stack: int = 1
