# Campfire
Simple campfire prop with toggle effect

# Preview
https://www.youtube.com/watch?v=HSjUIUKRHGs

# Setup
* If use ox_inventory
* Add items to ox_inventory > data > items.lua
```
['campfire'] = {
		label = 'Campfire',
		weight = 100,
		stack = false,
		close = true,
		client = {
			export = "campfire.StartPropPlacement"
		}
	},
```
* If use qb-inventory
* Add items to qb-core > shared > items.lua
```
campfire = { name = 'campfire', label = 'Campfire', weight = 100, type = 'item', image = 'campfire.png', unique = true, useable = true, shouldClose = true, description = 'campfire' },
```
# Dependencies

ox_lib
ox_target
ox_inventory

or

qb-core
qb-target
qb-inventory
