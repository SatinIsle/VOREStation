/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon = 'icons/obj/furniture.dmi'
	icon_state = "bed"
	pressure_resistance = 15
	anchored = TRUE
	can_buckle = TRUE
	buckle_dir = SOUTH
	buckle_lying = 1
	var/datum/material/material
	var/datum/material/padding_material
	var/base_icon = "bed"
	var/applies_material_colour = 1
	var/flippable = TRUE

/obj/structure/bed/Initialize(mapload, var/new_material, var/new_padding_material)
	..()
	color = null
	if(!new_material)
		new_material = MAT_STEEL
	material = get_material_by_name(new_material)
	if(!istype(material))
		return INITIALIZE_HINT_QDEL
	if(new_padding_material)
		padding_material = get_material_by_name(new_padding_material)
	update_icon()
	return INITIALIZE_HINT_NORMAL

/obj/structure/bed/get_material()
	return material

// Reuse the cache/code from stools, todo maybe unify.
/obj/structure/bed/update_icon()
	// Prep icon.
	icon_state = ""
	cut_overlays()
	// Base icon.
	var/cache_key = "[base_icon]-[material.name]"
	if(isnull(GLOB.stool_cache[cache_key]))
		var/image/I = image(icon, base_icon)
		if(applies_material_colour) //VOREStation Add - Goes with added var
			I.color = material.icon_colour
		GLOB.stool_cache[cache_key] = I
	add_overlay(GLOB.stool_cache[cache_key])
	// Padding overlay.
	if(padding_material)
		var/padding_cache_key = "[base_icon]-padding-[padding_material.name]"
		if(isnull(GLOB.stool_cache[padding_cache_key]))
			var/image/I =  image(icon, "[base_icon]_padding")
			I.color = padding_material.icon_colour
			GLOB.stool_cache[padding_cache_key] = I
		add_overlay(GLOB.stool_cache[padding_cache_key])
	// Strings.
	desc = initial(desc)
	if(padding_material)
		name = "[padding_material.display_name] [initial(name)]" //this is not perfect but it will do for now.
		desc += " It's made of [material.use_name] and covered with [padding_material.use_name]."
	else
		name = "[material.display_name] [initial(name)]"
		desc += " It's made of [material.use_name]."

/obj/structure/bed/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	return ..()

/obj/structure/bed/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return

/obj/structure/bed/attackby(obj/item/W as obj, mob/user as mob)
	if(W.has_tool_quality(TOOL_WRENCH))
		playsound(src, W.usesound, 50, 1)
		dismantle()
		qdel(src)
	else if(istype(W,/obj/item/stack))
		if(padding_material)
			to_chat(user, "\The [src] is already padded.")
			return
		var/obj/item/stack/C = W
		if(C.get_amount() < 1) // How??
			user.drop_from_inventory(C)
			qdel(C)
			return
		var/padding_type //This is awful but it needs to be like this until tiles are given a material var.
		if(istype(W,/obj/item/stack/tile/carpet))
			padding_type = MAT_CARPET
		else if(istype(W,/obj/item/stack/material))
			var/obj/item/stack/material/M = W
			if(M.material && (M.material.flags & MATERIAL_PADDING))
				padding_type = "[M.material.name]"
		if(!padding_type)
			to_chat(user, "You cannot pad \the [src] with that.")
			return
		C.use(1)
		if(!istype(src.loc, /turf))
			user.drop_from_inventory(src)
			src.loc = get_turf(src)
		to_chat(user, "You add padding to \the [src].")
		add_padding(padding_type)
		return

	else if(W.has_tool_quality(TOOL_WIRECUTTER))
		if(!padding_material)
			to_chat(user, "\The [src] has no padding to remove.")
			return
		to_chat(user, "You remove the padding from \the [src].")
		playsound(src, W.usesound, 100, 1)
		remove_padding()

	else if(istype(W, /obj/item/disk) || (istype(W, /obj/item/toy/plushie)))
		user.drop_from_inventory(W, get_turf(src))
		W.pixel_x = 10 //make sure they reach the pillow
		W.pixel_y = -6
		if(istype(W, /obj/item/disk))
			user.visible_message(span_notice("[src] sleeps soundly. Sleep tight, disky."))

	else if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		var/mob/living/affecting = G.affecting
		if(has_buckled_mobs()) //Handles trying to buckle someone else to a chair when someone else is on it
			to_chat(user, span_notice("\The [src] already has someone buckled to it."))
			return
		user.visible_message(span_notice("[user] attempts to buckle [affecting] into \the [src]!"))
		if(do_after(user, 20, G.affecting))
			affecting.loc = loc
			spawn(0)
				if(buckle_mob(affecting))
					affecting.visible_message(\
						span_danger("[affecting.name] is buckled to [src] by [user.name]!"),\
						span_danger("You are buckled to [src] by [user.name]!"),\
						span_notice("You hear metal clanking."))
			qdel(W)
	else
		..()

/obj/structure/bed/proc/remove_padding()
	if(padding_material)
		padding_material.place_sheet(get_turf(src), 1)
		padding_material = null
	update_icon()

/obj/structure/bed/proc/add_padding(var/padding_type)
	padding_material = get_material_by_name(padding_type)
	update_icon()

/obj/structure/bed/proc/dismantle()
	material.place_sheet(get_turf(src), 1)
	if(padding_material)
		padding_material.place_sheet(get_turf(src), 1)

/obj/structure/bed/verb/turn_around()
	set name = "Turn Around"
	set category = "Object"
	set src in oview(1)

	if(!flippable)
		to_chat(usr,span_notice("\The [src] can't face the other direction."))
		return

	if(!usr || !isturf(usr.loc))
		return
	if(usr.stat || usr.restrained())
		return
	if(ismouse(usr) || (isobserver(usr) && !CONFIG_GET(flag/ghost_interaction)))
		return
	if(dir == 2)
		src.set_dir(1)
	else if(dir == 1)
		src.set_dir(2)
	else if(dir == 4)
		src.set_dir(8)
	else if(dir == 8)
		src.set_dir(4)

/obj/structure/bed/psych
	name = "psychiatrist's couch"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"
	base_icon = "psychbed"

/obj/structure/bed/psych/Initialize(mapload)
	. = ..(mapload,MAT_WOOD,MAT_LEATHER)

/obj/structure/bed/padded/Initialize(mapload)
	. = ..(mapload,MAT_PLASTIC,MAT_COTTON)

/obj/structure/bed/double
	name = "double bed"
	icon_state = "doublebed"
	base_icon = "doublebed"

/obj/structure/bed/double/padded/Initialize(mapload)
	. = ..(mapload,MAT_WOOD,MAT_COTTON)

/obj/structure/bed/double/post_buckle_mob(mob/living/M as mob)
	if(M.buckled == src)
		M.pixel_y = 13
		M.old_y = 13
	else
		M.pixel_y = 0
		M.old_y = 0

/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "roller bed"
	desc = "A portable bed-on-wheels made for transporting medical patients."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "rollerbed"
	anchored = FALSE
	surgery_odds = 50 //VOREStation Edit
	var/bedtype = /obj/structure/bed/roller
	var/rollertype = /obj/item/roller
	flippable = FALSE

/obj/structure/bed/roller/adv
	name = "advanced roller bed"
	icon_state = "rollerbedadv"
	bedtype = /obj/structure/bed/roller/adv
	rollertype = /obj/item/roller/adv

/obj/structure/bed/roller/update_icon()
	return

/obj/structure/bed/roller/attackby(obj/item/W as obj, mob/user as mob)
	if(W.has_tool_quality(TOOL_WRENCH) || istype(W,/obj/item/stack) || W.has_tool_quality(TOOL_WIRECUTTER))
		return
	else if(istype(W,/obj/item/roller_holder))
		if(has_buckled_mobs())
			for(var/A in buckled_mobs)
				user_unbuckle_mob(A, user)
		else
			visible_message("[user] collapses \the [src.name].")
			new rollertype(get_turf(src))
			spawn(0)
				qdel(src)
		return
	..()

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded_rollerbed"
	center_of_mass_x = 17
	center_of_mass_y = 7
	slot_flags = SLOT_BACK
	w_class = ITEMSIZE_LARGE
	var/rollertype = /obj/item/roller
	var/bedtype = /obj/structure/bed/roller
	drop_sound = 'sound/items/drop/axe.ogg'
	pickup_sound = 'sound/items/pickup/axe.ogg'

/obj/item/roller/attack_self(mob/user)
	var/obj/structure/bed/roller/R = new bedtype(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/attackby(obj/item/W as obj, mob/user as mob)

	if(istype(W,/obj/item/roller_holder))
		var/obj/item/roller_holder/RH = W
		if(!RH.held)
			to_chat(user, span_notice("You collect the roller bed."))
			src.loc = RH
			RH.held = src
			return

	..()

/obj/item/roller/adv
	name = "advanced roller bed"
	desc = "A high-tech, compact version of the regular roller bed."
	icon_state = "folded_rollerbedadv"
	w_class = ITEMSIZE_NORMAL
	rollertype = /obj/item/roller/adv
	bedtype = /obj/structure/bed/roller/adv

/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "rollerbed"
	var/obj/item/roller/held

/obj/item/roller_holder/Initialize(mapload)
	. = ..()
	held = new /obj/item/roller(src)

/obj/item/roller_holder/attack_self(mob/user as mob)

	if(!held)
		to_chat(user, span_notice("The rack is empty."))
		return

	to_chat(user, span_notice("You deploy the roller bed."))
	var/obj/structure/bed/roller/R = new held.bedtype(user.loc)
	R.add_fingerprint(user)
	qdel(held)
	held = null


/obj/structure/bed/roller/Moved(atom/old_loc, direction, forced = FALSE)
	. = ..()

	playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/bed/roller/post_buckle_mob(mob/living/M as mob)
	if(M.buckled == src)
		M.pixel_y = 6
		M.old_y = 6
		density = TRUE
		icon_state = "[initial(icon_state)]_up"
	else
		M.pixel_y = 0
		M.old_y = 0
		density = FALSE
		icon_state = "[initial(icon_state)]"
	update_icon()
	return ..()

/obj/structure/bed/roller/MouseDrop(over_object, src_location, over_location)
	..()
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if(!ishuman(usr))	return
		if(has_buckled_mobs())	return 0
		visible_message("[usr] collapses \the [src.name].")
		new rollertype(get_turf(src))
		spawn(0)
			qdel(src)
		return

/datum/category_item/catalogue/anomalous/precursor_a/alien_bed
	name = "Precursor Alpha Object - Resting Contraption"
	desc = "This appears to be a relatively long and flat object, with the top side being made of \
	an soft material, giving it very similar characteristics to an ordinary bed. If this object was \
	designed to act as a bed, this carries several implications for whatever species had built it, such as;\
	<br><br>\
	Being capable of experiencing comfort, or at least being able to suffer from some form of fatigue.<br>\
	Developing while under the influence of gravitational forces, to be able to 'lie' on the object.<br>\
	Being within a range of sizes in order for the object to function as a bed. Too small, and the species \
	would be unable to reach the top of the object. Too large, and they would have little room to contact \
	the top side of the object.<br>\
	<br><br>\
	As a note, the size of this object appears to be within the bounds for an average human to be able to \
	rest comfortably on top of it."
	value = CATALOGUER_REWARD_EASY

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "Whatever species designed this must've enjoyed relaxation as well. Looks vaguely comfy."
	catalogue_data = list(/datum/category_item/catalogue/anomalous/precursor_a/alien_bed)
	icon = 'icons/obj/abductor.dmi'
	icon_state = "bed"
	flippable = FALSE

/obj/structure/bed/alien/update_icon()
	return // Doesn't care about material or anything else.

/obj/structure/bed/alien/attackby(obj/item/W, mob/user)
	return // No deconning.

/*
 * Dirty Mattress
 */
/obj/structure/dirtybed
	name = "dirty mattress"
	desc = "A stained matress. Guess it's better than sleeping on the floor."
	icon = 'icons/obj/furniture.dmi'
	icon_state = "dirtybed"
	pressure_resistance = 15
	anchored = TRUE
	can_buckle = TRUE
	buckle_dir = SOUTH
	buckle_lying = 1

/obj/structure/dirtybed/attackby(obj/item/W as obj, mob/user as mob)
	if(W.has_tool_quality(TOOL_WRENCH))
		playsound(src, W.usesound, 100, 1)
		if(anchored)
			user.visible_message("[user] begins unsecuring \the [src] from the floor.", "You start unsecuring \the [src] from the floor.")
		else
			user.visible_message("[user] begins securing \the [src] to the floor.", "You start securing \the [src] to the floor.")

		if(do_after(user, 20 * W.toolspeed))
			if(!src) return
			to_chat(user, span_notice("You [anchored? "un" : ""]secured \the [src]!"))
			anchored = !anchored
		return

	if(!anchored)
		to_chat(user,span_notice(" The bed isn't secured."))
		return
