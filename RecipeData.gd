extends Node

var selected_recipe = ""

var recipes = {
	"Kitsune Udon": {
		"ingredients": [
			"4 pieces Aburaage (unseasoned fried tofu)",
			"1 cup Dashi",
			"1 tbsp Soy Sauce",
			"0.5 tbsp Sake",
			"1.5 tbsp Sugar",
			"2 packs Frozen Udon Noodles",
			"2.5 cups Dashi (for soup)",
			"1 tbsp Soy Sauce (for soup)",
			"1 tbsp Mirin",
			"Chopped Green Onions",
			"Shichimi Spice"
		],
		"steps": [
			"Remove excess oil from aburaage by rinsing in boiling water. Drain and set aside.",
			"Bring aburaage seasoning ingredients to a boil and simmer until sauce reduces to half. Set aside.",
			"Combine udon soup ingredients into a pan. Bring to boil, then simmer.",
			"Rinse frost off frozen noodles, then thaw them one pack at a time in the udon soup.",
			"Transfer thawed noodles to serving bowl, then repeat for second pack.",
			"Top noodles with seasoned aburaage and green onions.",
			"Bring soup back to a boil, then pour hot soup over noodles and serve.",
			"Sprinkle shichimi (chili pepper) to taste before eating."
		]
	}
}
