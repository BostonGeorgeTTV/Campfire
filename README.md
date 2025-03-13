# Campfire
Simple campfire prop with toggle effect

# Preview
https://www.youtube.com/watch?v=HSjUIUKRHGs

# Setup
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
# Dependencies

ox_lib
ox_target
ox_inventory
