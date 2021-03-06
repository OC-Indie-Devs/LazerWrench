local wordList = {}


local baseWordList = {
"Adult",
"Aeroplane",
"Air",
"Aircraft",
"Airforce",
"Airport",
"Album",
"Alphabet",
"Apple",
"Arm",
"Army",
"Baby",
"Baby",
"Backpack",
"Balloon",
"Banana",
"Bank",
"Barbecue",
"Bathroom",
"Bathtub",
"Bed",
"Bed",
"Bee",
"Bible",
"Bible",
"Bird",
"Bomb",
"Book",
"Boss",
"Bottle",
"Bowl",
"Box",
"Boy",
"Brain",
"Bridge",
"Butterfly",
"Button",
"Cappuccino",
"Car",
"Car-race",
"Carpet",
"Carrot",
"Cave",
"Chair",
"Chess Board",
"Chief",
"Child",
"Chisel",
"Chocolates",
"Church",
"Circle",
"Circus",
"Clock",
"Clown",
"Coffee",
"Coffee-shop",
"Comet",
"Compact Disc",
"Compass",
"Computer",
"Crystal",
"Cup",
"Cycle",
"Data Base",
"Desk",
"Diamond",
"Dress",
"Drill",
"Drink",
"Drum",
"Dung",
"Ears",
"Earth",
"Egg",
"Electricity",
"Elephant",
"Eraser",
"Explosive",
"Eyes",
"Family",
"Fan",
"Feather",
"Festival",
"Film",
"Finger",
"Fire",
"Floodlight",
"Flower",
"Foot",
"Fork",
"Freeway",
"Fruit",
"Fungus",
"example",
"Garden",
"Gas",
"Gate",
"Gemstone",
"Girl",
"Gloves",
"God",
"Grapes",
"Guitar",
"Hammer",
"Hat",
"Hieroglyph",
"Highway",
"Horoscope",
"Horse",
"Hose",
"Ice",
"Ice-cream",
"Insect",
"Jet fighter",
"Junk",
"Kaleidoscope",
"Kitchen",
"Knife",
"Leather jacket",
"Leg",
"Library",
"Liquid",
"Magnet",
"Man",
"Map",
"Maze",
"Meat",
"Meteor",
"Microscope",
"Milk",
"Milkshake",
"Mist",
"Money",
"Monster",
"Mosquito",
"Mouth",
"Nail",
"Navy",
"Necklace",
"Needle",
"Onion",
"PaintBrush",
"Pants",
"Parachute",
"Passport",
"Pebble",
"Pendulum",
"Pepper",
"Perfume",
"Pillow",
"Plane",
"Planet",
"Pocket",
"Post-office",
"Potato",
"Printer",
"Prison",
"Pyramid",
"Radar",
"Rainbow",
"Record",
"Restaurant",
"Rifle",
"Ring",
"Robot",
"Rock",
"Rocket",
"Roof",
"Room",
"Rope",
"Saddle",
"Salt",
"Sandpaper",
"Sandwich",
"Satellite",
"School",
"Sex",
"Ship",
"Shoes",
"Shop",
"Shower",
"Signature",
"Skeleton",
"Slave",
"Snail",
"Software",
"Solid",
"Space Shuttle",
"Spectrum",
"Sphere",
"Spice",
"Spiral",
"Spoon",
"Sports-car",
"Spot Light",
"Square",
"Staircase",
"Star",
"Stomach",
"Sun",
"Sunglasses",
"Surveyor",
"Swimming Pool",
"Sword",
"Table",
"Tapestry",
"Teeth",
"Telescope",
"Television",
"Tennis racquet",
"Thermometer",
"Tiger",
"Toilet",
"Tongue",
"Torch",
"Torpedo",
"Train",
"Treadmill",
"Triangle",
"Tunnel",
"Typewriter",
"Umbrella",
"Vacuum",
"Vampire",
"Videotape",
"Vulture",
"Water",
"Weapon",
"Web",
"Wheelchair",
"Window",
"Woman",
"Worm",
"X-ray"	
}

function wordList.getBase()
	return table.shallowCopy( baseWordList )
end

function wordList.generate( wordCount, shuffles )
	local tmp = {}
	wordCount = wordCount or #baseWordList
	shuffles = tonumber(shuffles) or 0

	while( true ) do
		for j = 1, #baseWordList do
			tmp[#tmp+1] = baseWordList[j]
			if( #tmp == wordCount ) then
				if( shuffles > 0 ) then table.shuffle( tmp, shuffles ) end
				return tmp
			end
		end
	end	
end

return wordList