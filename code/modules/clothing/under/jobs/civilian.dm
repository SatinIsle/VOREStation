//Alphabetical order of civilian jobs.

/obj/item/clothing/under/rank/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "ba_suit"
	rolled_sleeves = 0

/obj/item/clothing/under/rank/bartender/skirt
	desc = "Short and cute."
	name = "bartender's skirt"
	icon_state = "ba_suit_skirt"
	item_state_slots = list(slot_r_hand_str = "ba_suit", slot_l_hand_str = "ba_suit")

/obj/item/clothing/under/rank/captain //Alright, technically not a 'civilian' but its better then giving a .dm file for a single define.
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Site Manager\"."
	name = "site manager's jumpsuit"
	icon_state = "captain"
	rolled_sleeves = 0

/obj/item/clothing/under/rank/cargo
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state_slots = list(slot_r_hand_str = "cargo", slot_l_hand_str = "cargo")
	rolled_sleeves = 0

/obj/item/clothing/under/rank/cargo/jeans
	name = "quartermaster's jumpjeans"
	desc = "Jeeeaaans! They're comfy!"
	icon_state = "qmj"

/obj/item/clothing/under/rank/cargo/jeans/female
	name = "quartermaster's jumpjeans"
	desc = "Jeeeaaans! They're comfy!"
	icon_state = "qmjf"
	rolled_sleeves = -1

/obj/item/clothing/under/rank/cargotech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargo"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	rolled_sleeves = 0

/obj/item/clothing/under/rank/cargotech/jeans
	name = "cargo technician's jumpjeans"
	desc = "Jeeeaaans! They're comfy!"
	icon_state = "cargoj"
	item_state_slots = list(slot_r_hand_str = "cargo", slot_l_hand_str = "cargo")
	rolled_sleeves = -1

/obj/item/clothing/under/rank/cargotech/jeans/female
	name = "cargo technician's jumpjeans"
	desc = "Jeeeaaans! They're comfy!"
	icon_state = "cargojf"

/obj/item/clothing/under/rank/chaplain
	desc = "It's a black jumpsuit, often worn by guidance staff."
	name = "chaplain's jumpsuit"
	icon_state = "chaplain"
	item_state_slots = list(slot_r_hand_str = "black", slot_l_hand_str = "black")
	rolled_sleeves = 0

/obj/item/clothing/under/rank/chaplain/alt
	name = "chaplain's striped jumpsuit"
	icon_state = "chaplain_alt"
	rolled_sleeves = -1
	index = 1

/obj/item/clothing/under/rank/chef
	desc = "It's an apron which is given only to the most <b>hardcore</b> chefs in space."
	name = "chef's uniform"
	icon_state = "chef"
	rolled_sleeves = 0

/obj/item/clothing/under/rank/chef/alt
	desc = "It's an apron which is given only to the chefs that swear the most."
	name = "souschef's uniform"
	icon_state = "souschef"

/obj/item/clothing/under/rank/clown
	name = "clown suit"
	desc = "<i><font face='comic sans ms'>Honk!</i></font>"
	icon_state = "clown"
	rolled_sleeves = -1

/obj/item/clothing/under/rank/head_of_personnel
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	rolled_sleeves = 0

/obj/item/clothing/under/rank/head_of_personnel_whimsy
	desc = "A blue jacket and red tie, with matching red cuffs! Snazzy. Wearing this makes you feel more important than your job title does."
	name = "head of personnel's suit"
	icon_state = "hopwhimsy"
	item_state_slots = list(slot_r_hand_str = "hop", slot_l_hand_str = "hop")
	rolled_sleeves = -1

/obj/item/clothing/under/rank/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state_slots = list(slot_r_hand_str = "green", slot_l_hand_str = "green")
	permeability_coefficient = 0.50
	rolled_sleeves = 0

/obj/item/clothing/under/rank/hydroponics/alt
	icon_state = "hydro"

/obj/item/clothing/under/rank/internalaffairs
	desc = "The plain, professional attire of an Internal Affairs Agent. The collar is <i>immaculately</i> starched."
	name = "Internal Affairs uniform"
	icon_state = "internalaffairs"
	item_state_slots = list(slot_r_hand_str = "ba_suit", slot_l_hand_str = "ba_suit")
	rolled_sleeves = 0
	starting_accessories = list(/obj/item/clothing/accessory/tie/black)

/obj/item/clothing/under/rank/internalaffairs/skirt
	desc = "The plain, professional attire of an Internal Affairs Agent. The top button is sewn shut."
	name = "Internal Affairs skirt"
	icon_state = "internalaffairs_skirt"

/obj/item/clothing/under/rank/janitor
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	rolled_sleeves = 0

/obj/item/clothing/under/rank/janitor/alt
	name = "janitor's overalls"
	icon_state = "janitor_alt"

/obj/item/clothing/under/lawyer
	name = "baby blue suit"
	desc = "Slick threads."
	icon_state = "ress_suit"
	item_state_slots = list(slot_r_hand_str = "lightblue", slot_l_hand_str = "lightblue")

/obj/item/clothing/under/lawyer/black
	name = "tacky black lawyer suit"
	icon_state = "lawyer_black"
	item_state_slots = list(slot_r_hand_str = "lawyer_black", slot_l_hand_str = "lawyer_black")

/obj/item/clothing/under/lawyer/black/skirt
	name = "tacky black lawyer skirt"
	icon_state = "lawyer_black_skirt"
	item_state_slots = list(slot_r_hand_str = "lawyer_black", slot_l_hand_str = "lawyer_black")

/obj/item/clothing/under/lawyer/female
	name = "black lawyer suit"
	icon_state = "black_suit_fem"
	item_state_slots = list(slot_r_hand_str = "lawyer_black", slot_l_hand_str = "lawyer_black")

/obj/item/clothing/under/lawyer/modern
	name = "black modern suit"
	icon_state = "modern_suit_m"
	index = 1
	item_state_slots = list(slot_r_hand_str = "black", slot_l_hand_str = "black")

/obj/item/clothing/under/lawyer/modern/skirt
	name = "black modern skirt"
	icon_state = "modern_suit_f"
	index = 1
	item_state_slots = list(slot_r_hand_str = "black", slot_l_hand_str = "black")

/obj/item/clothing/under/lawyer/trimskirt
	name = "blue-trim skirt"
	icon_state = "trim_skirtsuit"
	index = 1
	item_state_slots = list(slot_r_hand_str = "black", slot_l_hand_str = "black")

/obj/item/clothing/under/lawyer/red
	name = "tacky red suit"
	icon_state = "lawyer_red"
	item_state_slots = list(slot_r_hand_str = "lawyer_red", slot_l_hand_str = "lawyer_red")

/obj/item/clothing/under/lawyer/red/skirt
	name = "tacky red skirt"
	icon_state = "lawyer_red_skirt"
	item_state_slots = list(slot_r_hand_str = "lawyer_red", slot_l_hand_str = "lawyer_red")

/obj/item/clothing/under/lawyer/blue
	name = "tacky blue suit"
	icon_state = "lawyer_blue"
	item_state_slots = list(slot_r_hand_str = "lawyer_blue", slot_l_hand_str = "lawyer_blue")

/obj/item/clothing/under/lawyer/blue/skirt
	name = "tacky blue skirt"
	icon_state = "lawyer_blue_skirt"
	item_state_slots = list(slot_r_hand_str = "lawyer_blue", slot_l_hand_str = "lawyer_blue")

/obj/item/clothing/under/lawyer/bluesuit
	name = "blue suit"
	desc = "A classy suit."
	icon_state = "bluesuit"
	item_state_slots = list(slot_r_hand_str = "blue", slot_l_hand_str = "blue")
	starting_accessories = list(/obj/item/clothing/accessory/tie/red)

/obj/item/clothing/under/lawyer/bluesuit/skirt
	name = "blue skirt suit"
	icon_state = "bluesuit_skirt"
	item_state_slots = list(slot_r_hand_str = "blue", slot_l_hand_str = "blue")

/obj/item/clothing/under/lawyer/purpsuit
	name = "purple suit"
	icon_state = "lawyer_purp"
	item_state_slots = list(slot_r_hand_str = "purple", slot_l_hand_str = "purple")

/obj/item/clothing/under/lawyer/purpsuit/skirt
	name = "purple skirt suit"
	icon_state = "lawyer_purp_skirt"
	item_state_slots = list(slot_r_hand_str = "purple", slot_l_hand_str = "purple")

/obj/item/clothing/under/lawyer/oldman
	name = "Old Man's Suit"
	desc = "A classic suit for the older gentleman, with built in back support."
	icon_state = "oldman"
	item_state_slots = list(slot_r_hand_str = "johnny", slot_l_hand_str = "johnny")

/obj/item/clothing/under/lawyer/librarian
	name = "sensible suit"
	desc = "It's very... sensible."
	icon_state = "red_suit"
	item_state_slots = list(slot_r_hand_str = "red", slot_l_hand_str = "red")

/obj/item/clothing/under/lawyer/retro_tan
	name = "retro tan suit"
	desc = "Just one more thing."
	icon_state = "liaison_regular"
	item_state_slots = list(slot_r_hand_str = "lightbrown", slot_l_hand_str = "lightbrown")
	index = 1

/obj/item/clothing/under/lawyer/retro_white
	name = "retro white suit"
	desc = "Snappy!"
	icon_state = "liaison_formal"
	item_state_slots = list(slot_r_hand_str = "white", slot_l_hand_str = "white")
	index = 1

/obj/item/clothing/under/lawyer/retro_waistcoat
	name = "retro waistcoat"
	desc = "The spectre of CEOs past."
	icon_state = "manager_uniform"
	index = 1

/obj/item/clothing/under/lawyer/retro_suspenders
	name = "retro suspenders"
	desc = "The spectre of CEOs past."
	icon_state = "liaison_suspenders"
	index = 1

/obj/item/clothing/under/lawyer/retro_clerk
	name = "retro clerk's suit"
	desc = "The spectre of toadies past."
	icon_state = "trainee_uniform"
	index = 1

/obj/item/clothing/under/lawyer/powersuit_black
	name = "black and gold powersuit"
	desc = "Resonates corporate energy."
	icon_state = "director_uniform"
	item_state_slots = list(slot_r_hand_str = "lawyer_black", slot_l_hand_str = "lawyer_black")
	index = 1

/obj/item/clothing/under/lawyer/powersuit_grey
	name = "grey powersuit"
	desc = "Resonates corporate energy."
	icon_state = "stowaway_uniform"
	item_state_slots = list(slot_r_hand_str = "white", slot_l_hand_str = "white")
	index = 1

/obj/item/clothing/under/oldwoman
	name = "Old Woman's Attire"
	desc = "A typical outfit for the older woman, a lovely cardigan and comfortable skirt."
	icon_state = "oldwoman"
	item_state_slots = list(slot_r_hand_str = "johnny", slot_l_hand_str = "johnny")

/obj/item/clothing/under/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"

/obj/item/clothing/under/rank/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	rolled_sleeves = 0
