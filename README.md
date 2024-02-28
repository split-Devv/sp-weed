# sp-weed
fivem Weed Planting 


SP-WEED

Go to [qb]\qb-core\shared\items

["weed"] 				       = {["name"] = "weed", 			 	  	      ["label"] = "Unpackaged Weed", 	   ["weight"] = 200, 	  ["type"] = "item", 		["image"] = "weedbrick40oz.png", 				      ["unique"] = false, 	  ["useable"] = false, 	["shouldClose"] = true,      ["combinable"] = nil,   ["description"] = ""},
['fertilizer'] 			 	 	 = {['name'] = 'fertilizer', 				['label'] = 'Fertilizer',			['weight'] = 100, 		['type'] = 'item', 		['image'] = 'fertilizer.png', 			['unique'] = false,    ['useable'] = true, 	   ['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A special member of Pearl\'s Seafood Restaurant'},	
['maleseed'] 			 	 	 = {['name'] = 'maleseed', 					['label'] = 'Male Seed', 			['weight'] = 100, 		['type'] = 'item', 		['image'] = 'ffrp_weed_seed.png', 			['unique'] = false,    ['useable'] = true, 	   ['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A special member of Pearl\'s Seafood Restaurant'},	
['femaleseed'] 			 	 	 = {['name'] = 'femaleseed', 				['label'] = 'Female Seed', 			['weight'] = 100, 		['type'] = 'item', 		['image'] = 'weedseed.png', 			['unique'] = false,    ['useable'] = true, 	   ['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A special member of Pearl\'s Seafood Restaurant'},	
['marijuana_water'] 			 	 = {['name'] = 'marijuana_water', 			    	['label'] = 'Plant Water', 				['weight'] = 0, 		['type'] = 'item', 		['image'] = 'marijuana_water.png', 					['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	  		['combinable'] = nil,   ['description'] = 'Plant water'},
['weed_nutrition'] 				 = {['name'] = 'weed_nutrition', 			    ['label'] = 'Plant Fertilizer', 		['weight'] = 2000, 		['type'] = 'item', 		['image'] = 'weed_nutrition.png', 		['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Plant nutrition'},

add your TaskBar


---exports["gate-taskbar"]:taskBar(5000, "Adding Water")---
