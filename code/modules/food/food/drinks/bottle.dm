///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	force = 6
	var/smash_duration = 5 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

	var/obj/item/reagent_containers/glass/rag/rag = null
	var/rag_underlay = "rag"
	var/violent_throw = FALSE

/obj/item/reagent_containers/food/drinks/bottle/on_reagent_change() return // To suppress price updating. Bottles have their own price tags.

/obj/item/reagent_containers/food/drinks/bottle/Initialize(mapload)
	. = ..()
	if(isGlass)
		unacidable = TRUE
		drop_sound = 'sound/items/drop/bottle.ogg'
		pickup_sound = 'sound/items/pickup/bottle.ogg'

/obj/item/reagent_containers/food/drinks/bottle/Destroy()
	if(rag)
		rag.forceMove(src.loc)
	rag = null
	return ..()

//when thrown on impact, bottles smash and spill their contents
/obj/item/reagent_containers/food/drinks/bottle/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, datum/callback/callback)
	. = ..()
	if(istype(thrower) && thrower.a_intent == I_HURT)
		violent_throw = TRUE
		throw_source = get_turf(thrower)

/obj/item/reagent_containers/food/drinks/bottle/throw_impact(atom/hit_atom, var/speed)
	..()

	if(isGlass && violent_throw)
		var/throw_dist = get_dist(throw_source, loc)
		if(smash_check(throw_dist)) //not as reliable as smashing directly
			if(reagents)
				hit_atom.visible_message(span_notice("The contents of \the [src] splash all over [hit_atom]!"))
				reagents.splash(hit_atom, reagents.total_volume)
			src.smash(loc, hit_atom)

	violent_throw = FALSE
	throw_source = null

/obj/item/reagent_containers/food/drinks/bottle/proc/smash_check(var/distance)
	if(!isGlass || !smash_duration)
		return 0

	var/list/chance_table = list(100, 95, 90, 85, 75, 55, 35) //starting from distance 0
	var/idx = max(distance + 1, 1) //since list indices start at 1
	if(idx > chance_table.len)
		return 0
	return prob(chance_table[idx])

/obj/item/reagent_containers/food/drinks/bottle/proc/smash(var/newloc, atom/against = null)
	if(ismob(loc))
		var/mob/M = loc
		M.drop_from_inventory(src)

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	var/obj/item/broken_bottle/B = new /obj/item/broken_bottle(newloc)
	if(prob(33))
		new/obj/item/material/shard(newloc) // Create a glass shard at the target's location!
	B.icon_state = src.icon_state

	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	if(rag && rag.on_fire && isliving(against))
		rag.forceMove(loc)
		var/mob/living/L = against
		L.IgniteMob()

	playsound(src, "shatter", 70, 1)
	src.transfer_fingerprints_to(B)

	qdel(src)
	return B

/obj/item/reagent_containers/food/drinks/bottle/verb/smash_bottle()
	set name = "Smash Bottle"
	set category = "Object"

	var/list/things_to_smash_on = list()
	for(var/atom/A in range (1, usr))
		if(A.density && usr.Adjacent(A) && !istype(A, /mob))
			things_to_smash_on += A

	var/atom/choice = tgui_input_list(usr, "Select what you want to smash the bottle on.", "SMASH!", things_to_smash_on)
	if(!choice)
		return
	if(!(choice.density && usr.Adjacent(choice)))
		to_chat(usr, span_warning("You must stay close to your target! You moved away from \the [choice]"))
		return

	usr.put_in_hands(src.smash(usr.loc, choice))
	usr.visible_message(span_danger("\The [usr] smashed \the [src] on \the [choice]!"))
	to_chat(usr, span_danger("You smash \the [src] on \the [choice]!"))

/obj/item/reagent_containers/food/drinks/bottle/attackby(obj/item/W, mob/user)
	if(!rag && istype(W, /obj/item/reagent_containers/glass/rag))
		insert_rag(W, user)
		return
	if(rag && istype(W, /obj/item/flame))
		rag.attackby(W, user)
		return
	..()

/obj/item/reagent_containers/food/drinks/bottle/attack_self(mob/user)
	if(rag)
		remove_rag(user)
	else
		..()

/obj/item/reagent_containers/food/drinks/bottle/proc/insert_rag(obj/item/reagent_containers/glass/rag/R, mob/user)
	if(!isGlass || rag) return
	if(user.unEquip(R))
		to_chat(user, span_notice("You stuff [R] into [src]."))
		rag = R
		rag.forceMove(src)
		flags &= ~OPENCONTAINER
		update_icon()

/obj/item/reagent_containers/food/drinks/bottle/proc/remove_rag(mob/user)
	if(!rag) return
	user.put_in_hands(rag)
	rag = null
	flags |= (initial(flags) & OPENCONTAINER)
	update_icon()

/obj/item/reagent_containers/food/drinks/bottle/open(mob/user)
	if(rag) return
	..()

/obj/item/reagent_containers/food/drinks/bottle/update_icon()
	underlays.Cut()
	if(rag)
		var/underlay_image = image(icon='icons/obj/drinks.dmi', icon_state=rag.on_fire? "[rag_underlay]_lit" : rag_underlay)
		underlays += underlay_image
		set_light(rag.light_range, rag.light_power, rag.light_color)
	else
		set_light(0)

/obj/item/reagent_containers/food/drinks/bottle/apply_hit_effect(mob/living/target, mob/living/user, var/hit_zone)
	var/blocked = ..()

	if(user.a_intent != I_HURT)
		return
	if(!smash_check(1))
		return //won't always break on the first hit

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/weaken_duration = 0
	if(blocked < 100)
		weaken_duration = smash_duration + min(0, force - target.getarmor(hit_zone, "melee") + 10)

	if(hit_zone == "head" && istype(target, /mob/living/carbon/))
		user.visible_message(span_danger("\The [user] smashes [src] over [target]'s head!"))
		if(weaken_duration)
			target.apply_effect(min(weaken_duration, 5), WEAKEN, blocked) // Never weaken more than a flash!
	else
		user.visible_message(span_danger("\The [user] smashes [src] into [target]!"))

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	if(reagents)
		user.visible_message(span_notice("The contents of \the [src] splash all over [target]!"))
		reagents.splash(target, reagents.total_volume)

	//Finally, smash the bottle. This kills (qdel) the bottle.
	var/obj/item/broken_bottle/B = smash(target.loc, target)
	user.put_in_active_hand(B)

/obj/item/reagent_containers/food/drinks/bottle/verb/spin_bottle()
	set name = "Spin The Bottle"
	set category = "Object"
	set src in view(1)

	if(isobserver(usr) || usr.stat)
		return

	if(!isturf(src.loc))
		to_chat(usr, span_notice("\The [src] needs to be on the floor to spin."))
		return

	var/spin_rotation = (rand(0,359))
	usr.visible_message(span_warning("\The [usr] spins \the [src]!"),span_notice("You spin \the [src]!"))
	SpinAnimation(3,10)
	spawn(30)
		icon_rotation = spin_rotation
		update_transform()

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/broken_bottle
	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 10
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	item_state = "beer"
	flags = NOCONDUCT
	attack_verb = list("stabbed", "slashed", "attacked")
	sharp = TRUE
	edge = FALSE
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")

/obj/item/broken_bottle/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in Alpha Centauri."
	icon_state = "ginbottle"
	center_of_mass_x = 16
	center_of_mass_y = 4

/obj/item/reagent_containers/food/drinks/bottle/gin/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_GIN, 100)

/obj/item/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured in a highly classified location."
	icon_state = "whiskeybottle1"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/whiskey/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_WHISKEY, 100)

/obj/item/reagent_containers/food/drinks/bottle/specialwhiskey
	name = REAGENT_SPECIALWHISKEY
	desc = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
	icon_state = "whiskeybottle2"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/specialwhiskey/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_SPECIALWHISKEY, 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink and fuel by Russians worldwide."
	icon_state = "vodkabottle"
	center_of_mass_x = 17
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/vodka/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_VODKA, 100)

/obj/item/reagent_containers/food/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequilla"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/tequila/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_TEQUILA, 100)

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing"
	icon_state = "bottleofnothing"
	center_of_mass_x = 17
	center_of_mass_y = 5

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_NOTHING, 100)

/obj/item/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in night clubs across the galaxy."
	icon_state = "patronbottle"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/patron/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_PATRON, 100)

/obj/item/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically Cuba in a bottle."
	icon_state = "rumbottle"
	center_of_mass_x = 16
	center_of_mass_y = 8

/obj/item/reagent_containers/food/drinks/bottle/rum/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_RUM, 100)

/obj/item/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	center_of_mass_x = 17
	center_of_mass_y = 10

/obj/item/reagent_containers/food/drinks/bottle/holywater/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_HOLYWATER, 100)

/obj/item/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	center_of_mass_x = 17
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/vermouth/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_VERMOUTH, 100)

/obj/item/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936."
	icon_state = "kahluabottle"
	center_of_mass_x = 17
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/kahlua/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_KAHLUA, 100)

/obj/item/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	center_of_mass_x = 15
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/goldschlager/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_GOLDSCHLAGER, 100)

/obj/item/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alcoholic drink, made after numerous distillations and years of maturing."
	icon_state = "cognacbottle"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/cognac/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_COGNAC, 100)

/obj/item/reagent_containers/food/drinks/bottle/absinthe
	name = "Jailbreaker Verte"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/absinthe/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_ABSINTHE, 100)

/obj/item/reagent_containers/food/drinks/bottle/melonliquor //MODIFIED ON 04/21/2021
	name = "Emeraldine Melon Liqueur"
	desc = "A bottle of 46 proof Emeraldine Melon Liquor. Sweet and light."
	icon_state = "melon_liqueur"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/melonliquor/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_MELONLIQUOR, 100)

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao //MODIFIED ON 04/21/2021
	name = "Miss Blue Curacao"
	desc = "A fruity, exceptionally azure drink. Does not allow the imbiber to use the fifth magic."
	icon_state = "blue_curacao"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_BLUECURACAO, 100)

/obj/item/reagent_containers/food/drinks/bottle/redeemersbrew
	name = REAGENT_UNATHILIQUOR
	desc = "Just opening the top of this bottle makes you feel a bit tipsy. Not for the faint of heart."
	icon_state = "redeemersbrew"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/redeemersbrew/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_UNATHILIQUOR, 100)

/obj/item/reagent_containers/food/drinks/bottle/peppermintschnapps
	name = "Dr. Bone's Peppermint Schnapps"
	desc = "A flavoured grain liqueur with a fresh, minty taste."
	icon_state = "schnapps_pep"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/peppermintschnapps/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_SCHNAPPSPEP, 100)

/obj/item/reagent_containers/food/drinks/bottle/peachschnapps
	name = "Dr. Bone's Peach Schnapps"
	desc = "A flavoured grain liqueur with a fruity peach taste."
	icon_state = "schnapps_pea"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/peachschnapps/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_SCHNAPPSPEA, 100)

/obj/item/reagent_containers/food/drinks/bottle/lemonadeschnapps
	name = "Dr. Bone's Lemonade Schnapps"
	desc = "A flavoured grain liqueur with a sweetish, lemon taste."
	icon_state = "schnapps_lem"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/lemonadeschnapps/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_SCHNAPPSLEM, 100)

/obj/item/reagent_containers/food/drinks/bottle/jager
	name = "Schusskonig"
	desc = "A complex tasting digestif. Thank god the original's trademark lapsed."
	icon_state = "jager_bottle"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/jager/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_JAGER, 100)

/////////////////////////WINES/////////////////////////

/obj/item/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Red"
	desc = "Cheap cooking wine pretending to be drinkable."
	icon_state = "winebottle"
	center_of_mass_x = 16
	center_of_mass_y = 4

/obj/item/reagent_containers/food/drinks/bottle/wine/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_REDWINE, 100)

/obj/item/reagent_containers/food/drinks/bottle/whitewine
	name = "Doublebeard Bearded Special White"
	desc = "Cooking wine pretending to be drinkable."
	icon_state = "whitewinebottle"
	center_of_mass_x = 16
	center_of_mass_y = 4

/obj/item/reagent_containers/food/drinks/bottle/whitewine/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_WHITEWINE, 100)

/obj/item/reagent_containers/food/drinks/bottle/carnoth //anagram of 'ntcahors' where the bottle sprite originated from
	name = "NanoTrasen Carnoth Red"
	desc = "A NanoTrasen branded wine given to high ranking staff as gifts. Made special on the agricultural planet Carnoth."
	icon_state = "carnoth"
	center_of_mass_x = 16
	center_of_mass_y = 4

/obj/item/reagent_containers/food/drinks/bottle/carnoth/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_CARNOTH, 100)

/obj/item/reagent_containers/food/drinks/bottle/pwine
	name = "Warlock's Velvet"
	desc = "What a delightful packaging for a surely high quality wine! The vintage must be amazing!"
	icon_state = "pwinebottle"
	center_of_mass_x = 16
	center_of_mass_y = 4

/obj/item/reagent_containers/food/drinks/bottle/pwine/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_PWINE, 100)

/obj/item/reagent_containers/food/drinks/bottle/champagne
	name = "Gilthari Luxury Champagne"
	desc = "For those special occassions."
	icon_state = "champagne"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/champagne/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_CHAMPAGNE, 100)

/obj/item/reagent_containers/food/drinks/bottle/sake
	name = "Mono-No-Aware Luxury Sake"
	desc = "Dry alcohol made from rice, a favorite of businessmen."
	icon_state = "sakebottle"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/sake/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_SAKE, 100)

//////////////////////////JUICES AND STUFF///////////////////////

/obj/item/reagent_containers/food/drinks/bottle/cola
	name = "\improper two-liter Space Cola"
	desc = "Cola. In space. Contains caffeine."
	icon_state = "colabottle"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/cola/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_COLA, 100)

/obj/item/reagent_containers/food/drinks/bottle/decaf_cola
	name = "\improper two-liter Space Cola Free"
	desc = "Cola. In space. Caffeine free."
	icon_state = "decafcolabottle"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/decaf_cola/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_DECAFCOLA, 100)

/obj/item/reagent_containers/food/drinks/bottle/space_up
	name = "\improper two-liter Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up_bottle"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/space_up/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_SPACEUP, 100)

/obj/item/reagent_containers/food/drinks/bottle/space_mountain_wind
	name = "\improper two-liter Space Mountain Wind"
	desc = "Blows right through you like a space wind. Contains caffeine."
	icon_state = "space_mountain_wind_bottle"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/space_mountain_wind/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_SPACEMOUNTAINWIND, 100)

/obj/item/reagent_containers/food/drinks/bottle/dr_gibb
	name = "\improper two-liter Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors. Contains caffeine."
	icon_state = "dr_gibb_bottle"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/dr_gibb/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_DRGIBB, 100)

/obj/item/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	center_of_mass_x = 16
	center_of_mass_y = 7
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/orangejuice/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_ORANGEJUICE, 100)

/obj/item/reagent_containers/food/drinks/bottle/applejuice
	name = REAGENT_APPLEJUICE
	desc = "Squeezed, pressed and ground to perfection!"
	icon_state = "applejuice"
	item_state = "carton"
	center_of_mass_x = 16
	center_of_mass_y = 7
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/applejuice/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_APPLEJUICE, 100)

/obj/item/reagent_containers/food/drinks/bottle/milk
	name = "Large Milk Carton"
	desc = "It's milk. This carton's large enough to serve your biggest milk drinkers."
	icon_state = "milk"
	item_state = "carton"
	center_of_mass_x = 16
	center_of_mass_y = 9
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/milk/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_MILK, 100)

/obj/item/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	center_of_mass_x = 16
	center_of_mass_y = 8
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/cream/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_CREAM, 100)

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice
	name = REAGENT_TOMATOJUICE
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	center_of_mass_x = 16
	center_of_mass_y = 8
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_TOMATOJUICE, 100)

/obj/item/reagent_containers/food/drinks/bottle/limejuice
	name = REAGENT_LIMEJUICE
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	center_of_mass_x = 16
	center_of_mass_y = 8
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/limejuice/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_LIMEJUICE, 100)

/obj/item/reagent_containers/food/drinks/bottle/lemonjuice
	name = REAGENT_LEMONJUICE
	desc = "Sweet-sour goodness. Minus the sweet."
	icon_state = "lemonjuice"
	item_state = "carton"
	center_of_mass_x = 16
	center_of_mass_y = 8
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/lemonjuice/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_LEMONJUICE, 100)

/obj/item/reagent_containers/food/drinks/bottle/grenadine
	name = "Briar Rose Grenadine Syrup"
	desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
	icon_state = "grenadinebottle"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/grenadine/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_GRENADINE, 100)

/obj/item/reagent_containers/food/drinks/bottle/grapejuice
	name = "Special Blend Grapejuice"
	desc = "A delicious blend of various grape species in one succulent blend."
	icon_state = "grapejuicebottle"
	center_of_mass_x = 16
	center_of_mass_y = 3

/obj/item/reagent_containers/food/drinks/bottle/grapejuice/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_GRAPEJUICE, 100)

//////////////////////////SMALL BOTTLES///////////////////////

/obj/item/reagent_containers/food/drinks/bottle/small
	volume = 50
	smash_duration = 1
	flags = 0 //starts closed
	rag_underlay = "rag_small"

/obj/item/reagent_containers/food/drinks/bottle/small/beer
	name = "Spacer beer"
	desc = "A remarkably unremarkable pale lager. Barley malt, hops and yeast."
	description_fluff = "Identical to an earlier Earth-based variety of beer, Spacer beer was rebranded at the height of humanity's first extra-solar colonization boom in the 2130s and become the go-to cheap booze for those dreaming of a brighter future in the stars. Today, the beer is advertised as 'brewed in space, for space."
	icon_state = "beer"
	center_of_mass_x = 16
	center_of_mass_y = 12

/obj/item/reagent_containers/food/drinks/bottle/small/beer/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_BEER, 50)

/obj/item/reagent_containers/food/drinks/bottle/small/beer/silverdragon
	name = "Silver Dragon pilsner"
	desc = "An earthy pale lager produced exclusively on Nisp, best served cold."
	description_fluff = "Brewed using locally grown hops, with hints of local flora, Silver Dragon has a reputation as the beer of the frontier hunter - and those trying to look just as tough."
	icon_state = "beer2"

/obj/item/reagent_containers/food/drinks/bottle/small/beer/meteor
	name = "Meteor beer"
	desc = "A strong, premium beer with a hint of maize."
	description_fluff = "Sold across human space, Meteor beer has won more awards than any single variety in history. It should be noted that Meteor's parent company Gilthari Exports, owns most alcohol awards agencies."
	icon_state = "beerprem"

/obj/item/reagent_containers/food/drinks/bottle/small/litebeer
	name = "Lite-Speed Lite beer"
	desc = "A reduced-alcohol, reduced-calorie beer for the drunk on a diet."
	description_fluff = "Lite-Speed is Spacer Beer's light brand, and despite being widely considered inferior in every regard, it's still pretty cheap. The lower alcohol content also appeals to some Skrell, for whom full-strength beer is too strong."
	icon_state = "beerlite"

/obj/item/reagent_containers/food/drinks/bottle/small/litebeer/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_LITEBEER, 50)

/obj/item/reagent_containers/food/drinks/bottle/small/cider
	name = "Crisp's Cider"
	desc = "Fermented apples never tasted this good."
	icon_state = "cider"
	center_of_mass_x = 16
	center_of_mass_y = 12

/obj/item/reagent_containers/food/drinks/bottle/small/cider/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_CIDER, 50)

/obj/item/reagent_containers/food/drinks/bottle/small/ale
	name = "\improper Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	item_state = "beer"
	center_of_mass_x = 16
	center_of_mass_y = 10

/obj/item/reagent_containers/food/drinks/bottle/small/ale/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_ALE, 50)

/obj/item/reagent_containers/food/drinks/bottle/small/ale/hushedwhisper
	name = "Hushed Whisper IPA"
	desc = "A popular Sivian pale ale named for an infamous space pirate."
	description_fluff = "Named for one of history's most infamous pirates, Qar’raqel, who ruled over Natuna before suffering a mysterious fate. This ale is brewed on Sif by a small company... Owned by Centauri Provisions."
	icon_state = "alebottle2"

/obj/item/reagent_containers/food/drinks/bottle/small/ale/hushedwhisper/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_ALE, 50)

//////////////////////////SMALL BOTTLED SODA///////////////////////

/obj/item/reagent_containers/food/drinks/bottle/small/cola
	name = REAGENT_COLA
	desc = "Cola. In space."
	icon_state = "colabottle2"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/small/cola/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_COLA, 50)

/obj/item/reagent_containers/food/drinks/bottle/small/space_up
	name = REAGENT_SPACEUP
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up_bottle2"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/small/space_up/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_SPACEUP, 50)

/obj/item/reagent_containers/food/drinks/bottle/small/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind_bottle2"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/small/space_mountain_wind/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_SPACEMOUNTAINWIND, 50)

/obj/item/reagent_containers/food/drinks/bottle/small/dr_gibb
	name = REAGENT_DRGIBB
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb_bottle2"
	center_of_mass_x = 16
	center_of_mass_y = 6

/obj/item/reagent_containers/food/drinks/bottle/small/dr_gibb/Initialize(mapload)
	. = ..()
	reagents.add_reagent(REAGENT_ID_DRGIBB, 50)
