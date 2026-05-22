extends Control

# 背包UI
class_name InventoryUI

@onready var inventory_grid = $InventoryGrid
@onready var item_info = $ItemInfo
@onready var use_button = $UseButton

func _ready():
	use_button.pressed.connect(_on_use_item)
	update_inventory_display()

func update_inventory_display():
	# 清除现有显示
	for child in inventory_grid.get_children():
		child.queue_free()
	
	# 显示背包物品
	var items = ItemSystem.get_inventory()
	for item in items:
		var item_button = Button.new()
		item_button.text = item["name"] + " x" + str(item.get("quantity", 1))
		item_button.pressed.connect(_on_item_selected.bind(item))
		inventory_grid.add_child(item_button)

func _on_item_selected(item: Dictionary):
	item_info.text = item["name"] + "\n" + item.get("description", "")

func _on_use_item():
	# 使用选中的物品
	pass
