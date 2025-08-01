/obj/item/clothing
	name = DEVELOPER_WARNING_NAME // "Clothing"
	siemens_coefficient = 0.9
	drop_sound = 'sound/items/drop/clothing.ogg'
	pickup_sound = 'sound/items/pickup/clothing.ogg'
	var/list/species_restricted = null //Only these species can wear this kit.

	var/list/accessories
	var/list/valid_accessory_slots
	var/list/restricted_accessory_slots
	var/list/starting_accessories

	var/flash_protection = FLASH_PROTECTION_NONE
	var/tint = TINT_NONE
	var/list/enables_planes		//Enables these planes in the wearing mob's plane_holder
	var/list/plane_slots		//But only if it's equipped into this specific slot

	var/ear_protection = 0
	var/blood_sprite_state

	var/update_icon_define = null	// Only needed if you've got multiple files for the same type of clothing

	var/polychromic = FALSE //VOREStation edit

	var/update_icon_define_orig = null	// temp storage for original update_icon_define (if it exists)
	var/update_icon_define_digi = null	// dmi used for the digi sprites
	var/fit_for_digi = FALSE // flag for if clothing has already been reskinned to digitigrade
	var/datum/weakref/wearer	//Who the person currently wearing us is.

//Updates the icons of the mob wearing the clothing item, if any.
/obj/item/clothing/proc/update_clothing_icon()
	return

/obj/item/clothing/Initialize(mapload)
	. = ..()
	if(starting_accessories)
		for(var/T in starting_accessories)
			var/obj/item/clothing/accessory/tie = new T(src)
			src.attach_accessory(null, tie)
	set_clothing_index()

	//VOREStation edit start
	if(polychromic)
		verbs |= /obj/item/clothing/proc/change_color
	//VOREStation edit start

/obj/item/clothing/update_icon()
	cut_overlays() //This removes all the overlays on the sprite and then goes down a checklist adding them as required.
	if(forensic_data?.has_blooddna())
		add_blood()
	. = ..()

/obj/item/clothing/equipped(var/mob/user,var/slot)
	..()
	if(enables_planes)
		user.recalculate_vis()

/obj/item/clothing/dropped(mob/user)
	..()
	if(enables_planes)
		user.recalculate_vis()

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(M as mob, slot, disable_warning = FALSE)

	//if we can't equip the item anyway, don't bother with species_restricted (cuts down on spam)
	if (!..())
		return 0

	if(LAZYLEN(species_restricted) && ishuman(M))
		var/exclusive = null
		var/wearable = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		if(H.species)
			if(exclusive)
				if(!(H.species.get_bodytype(H) in species_restricted))
					wearable = 1
			else
				if(H.species.get_bodytype(H) in species_restricted)
					wearable = 1

			if(!wearable && !(slot in list(slot_l_store, slot_r_store, slot_s_store)))
				to_chat(H, span_danger("Your species cannot wear [src]."))
				return 0
	return 1

/obj/item/clothing/handle_shield(mob/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	. = ..()
	if((. == 0) && LAZYLEN(accessories))
		for(var/obj/item/I in accessories)
			var/check = I.handle_shield(user, damage, damage_source, attacker, def_zone, attack_text)

			if(check != 0)	// Projectiles sometimes use negatives IIRC, 0 is only returned if something is not blocked.
				. = check
				break

// For now, these two temp procs only return TRUE or FALSE if they can provide resistance to a given temperature.
/obj/item/clothing/proc/handle_low_temperature(var/tempcheck = T20C)
	. = FALSE
	if(LAZYLEN(accessories))
		for(var/obj/item/clothing/C in accessories)
			if(C.handle_low_temperature(tempcheck))
				. = TRUE

	if(min_cold_protection_temperature && min_cold_protection_temperature <= tempcheck)
		. = TRUE

/obj/item/clothing/proc/handle_high_temperature(var/tempcheck = T20C)
	. = FALSE
	if(LAZYLEN(accessories))
		for(var/obj/item/clothing/C in accessories)
			if(C.handle_high_temperature(tempcheck))
				. = TRUE

	if(max_heat_protection_temperature && max_heat_protection_temperature >= tempcheck)
		. = TRUE

// Returns the relative flag-vars for covered protection.
/obj/item/clothing/proc/get_cold_protection_flags()
	. = cold_protection

	if(LAZYLEN(accessories))
		for(var/obj/item/clothing/C in accessories)
			. |= C.get_cold_protection_flags()

/obj/item/clothing/proc/get_heat_protection_flags()
	. = heat_protection

	if(LAZYLEN(accessories))
		for(var/obj/item/clothing/C in accessories)
			. |= C.get_heat_protection_flags()

/obj/item/clothing/proc/refit_for_species(var/target_species)
	if(!species_restricted)
		return //this item doesn't use the species_restricted system

	//Set species_restricted list
	switch(target_species)
		//VOREStation Edit Start
		if(SPECIES_HUMAN, SPECIES_SKRELL)	//humanoid bodytypes
			species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_RAPALA, SPECIES_VASILISSAN, SPECIES_ALRAUNE, SPECIES_PROMETHEAN)
		if(SPECIES_UNATHI)
			species_restricted = list(SPECIES_UNATHI, SPECIES_XENOHYBRID)
		if(SPECIES_TAJARAN)
			species_restricted = list(SPECIES_TAJARAN, SPECIES_XENOCHIMERA)
		if(SPECIES_VULPKANIN)
			species_restricted = list(SPECIES_VULPKANIN, SPECIES_ZORREN_HIGH, SPECIES_FENNEC)
		if(SPECIES_SERGAL)
			species_restricted = list(SPECIES_SERGAL, SPECIES_NEVREAN)
		//VOREStation Edit End
		else
			species_restricted = list(target_species)

	//Set icon
	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

//VOREStation edit start
/obj/item/clothing/proc/change_color()
	set name = "Change Color"
	set category = "Object"
	set desc = "Change the color of the clothing."
	set src in usr

	if(usr.stat || usr.restrained() || usr.incapacitated())
		return

	var/new_color = tgui_color_picker(usr, "Pick a new color", "Color", color)

	if(new_color && (new_color != color))
		color = new_color
	update_icon()
	update_clothing_icon()
//VOREStation edit end

/obj/item/clothing/head/helmet/refit_for_species(var/target_species)
	if(!species_restricted)
		return //this item doesn't use the species_restricted system

	//Set species_restricted list
	switch(target_species)
		//VOREStation Edit Start
		if(SPECIES_HUMAN)
			species_restricted = list(SPECIES_HUMAN, SPECIES_RAPALA, SPECIES_VASILISSAN, SPECIES_ALRAUNE, SPECIES_PROMETHEAN, SPECIES_XENOCHIMERA)
		if(SPECIES_SKRELL)
			species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_RAPALA, SPECIES_VASILISSAN, SPECIES_ALRAUNE, SPECIES_PROMETHEAN, SPECIES_XENOCHIMERA)
		if(SPECIES_UNATHI)
			species_restricted = list(SPECIES_UNATHI, SPECIES_XENOHYBRID)
		if(SPECIES_VULPKANIN)
			species_restricted = list(SPECIES_VULPKANIN, SPECIES_ZORREN_HIGH, SPECIES_FENNEC)
		if(SPECIES_SERGAL)
			species_restricted = list(SPECIES_SERGAL, SPECIES_NEVREAN)
		//VOREStation Edit End
		else
			species_restricted = list(target_species)

	//Set icon
	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

///////////////////////////////////////////////////////////////////////
// Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = ITEMSIZE_TINY
	throwforce = 2
	slot_flags = SLOT_EARS
	sprite_sheets = list(
		SPECIES_TESHARI = 'icons/inventory/ears/mob_teshari.dmi',
		SPECIES_VOX = 'icons/inventory/hands/mob_vox.dmi')

/obj/item/clothing/ears/attack_hand(mob/user as mob)
	if (!user) return

	if (src.loc != user || !ishuman(user))
		..()
		return

	var/mob/living/carbon/human/H = user
	if(H.l_ear != src && H.r_ear != src)
		..()
		return

	if(!canremove)
		return

	var/obj/item/clothing/ears/O
	if(slot_flags & SLOT_TWOEARS )
		O = (H.l_ear == src ? H.r_ear : H.l_ear)
		user.u_equip(O)
		if(!istype(src,/obj/item/clothing/ears/offear))
			qdel(O)
			O = src
	else
		O = src

	user.unEquip(src)

	if (O)
		user.put_in_hands(O)
		O.add_fingerprint(user)

	if(istype(src,/obj/item/clothing/ears/offear))
		qdel(src)

/obj/item/clothing/ears/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_ears()

/obj/item/clothing/ears/MouseDrop(var/obj/over_object)
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		// If this covers both ears, we want to return the result of unequipping the primary object, and kill the off-ear one
		if(slot_flags & SLOT_TWOEARS)
			var/obj/item/clothing/ears/O = (H.l_ear == src ? H.r_ear : H.l_ear)
			if(istype(src, /obj/item/clothing/ears/offear))
				. = O.MouseDrop(over_object)
				H.drop_from_inventory(src)
				qdel(src)
			else
				. = ..()
				H.drop_from_inventory(O)
				qdel(O)
		else
			. = ..()


/obj/item/clothing/ears/offear
	name = "Other ear"
	w_class = ITEMSIZE_HUGE
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "block"
	slot_flags = SLOT_EARS | SLOT_TWOEARS

/obj/item/clothing/ears/offear/Initialize(mapload)
	. = ..()
	if(isobj(loc))
		var/obj/O = loc
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		set_dir(O.dir)

////////////////////////////////////////////////////////////////////////////////////////
//Gloves
/obj/item/clothing/gloves
	name = DEVELOPER_WARNING_NAME // "Gloves"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_gloves.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_gloves.dmi',
		)
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = ITEMSIZE_SMALL
	icon = 'icons/inventory/hands/item.dmi'
	siemens_coefficient = 0.9
	blood_sprite_state = "bloodyhands"
	var/wired = 0
	var/obj/item/cell/cell = 0
	var/fingerprint_chance = 0					//How likely the glove is to let fingerprints through
	var/obj/item/clothing/accessory/ring = null	//Covered ring
	var/obj/item/clothing/gloves/gloves = null	//Undergloves. Used for gauntlets.
	var/glove_level = 2							//What "layer" the glove is on
	var/overgloves = 0							//Used by gauntlets and arm_guards
	var/punch_force = 0							//How much damage do these gloves add to a punch?
	var/punch_damtype = BRUTE					//What type of damage does this make fists be?
	heat_protection = HANDS
	cold_protection = HANDS
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	sprite_sheets = list(
		SPECIES_TESHARI = 'icons/inventory/hands/mob_teshari.dmi',
		SPECIES_VOX = 'icons/inventory/hands/mob_vox.dmi'
		)
	drop_sound = 'sound/items/drop/gloves.ogg'
	pickup_sound = 'sound/items/pickup/gloves.ogg'

	valid_accessory_slots = (\
		ACCESSORY_SLOT_RING\
		|ACCESSORY_SLOT_WRIST)
	restricted_accessory_slots = (\
		ACCESSORY_SLOT_RING\
		|ACCESSORY_SLOT_WRIST)

/obj/item/clothing/gloves/Destroy()
	for(var/mob/living/M in contents)
		M.forceMove(get_turf(src))
	if(ring)
		qdel_null(ring)
	if(gloves)
		qdel_null(gloves)
	wearer = null
	return ..()

/obj/item/clothing/proc/set_clothing_index()
	return

/obj/item/clothing/gloves/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_gloves()

/obj/item/clothing/gloves/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	if(ring)
		ring.emp_act(severity)
	..()

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(var/atom/A, var/proximity)
	return 0 // return 1 to cancel attack_hand()

/*/obj/item/clothing/gloves/attackby(obj/item/W, mob/user)
	if(W.has_tool_quality(TOOL_WIRECUTTER) || istype(W, /obj/item/scalpel))
		if (clipped)
			to_chat(user, span_notice("The [src] have already been clipped!"))
			update_icon()
			return

		playsound(src, W.usesound, 50, 1)
		user.visible_message(span_red("[user] cuts the fingertips off of the [src]."),span_red("You cut the fingertips off of the [src]."))

		clipped = 1
		name = "modified [name]"
		desc = "[desc]<br>They have had the fingertips cut off of them."
		if("exclude" in species_restricted)
			species_restricted -= SPECIES_UNATHI
			species_restricted -= SPECIES_TAJARAN
		return
*/

/obj/item/clothing/gloves/wash()
	. = ..()
	transfer_blood = 0
	update_icon()

/obj/item/clothing/gloves/mob_can_equip(mob/user, slot, disable_warning = FALSE)
	var/mob/living/carbon/human/H = user

	if(slot && slot == slot_gloves)
		var/obj/item/clothing/G = H.gloves
		if(istype(G))
			ring = H.gloves
			if(ring.glove_level >= src.glove_level)
				to_chat(user, "You are unable to wear \the [src] as \the [H.gloves] are in the way.")
				ring = null
				return 0
			else
				H.drop_from_inventory(ring)	//Remove the ring (or other under-glove item in the hand slot?) so you can put on the gloves.
				ring.forceMove(src)
				to_chat(user, "You slip \the [src] on over \the [src.ring].")
				if(!(flags & THICKMATERIAL))
					punch_force += ring.punch_force
		else
			ring = null

	if(!..())
		if(ring) //Put the ring back on if the check fails.
			if(H.equip_to_slot_if_possible(ring, slot_gloves))
				src.ring = null
		punch_force = initial(punch_force)
		return 0

	wearer = WEAKREF(H)
	return 1

/obj/item/clothing/gloves/dropped(mob/user)
	..()

	punch_force = initial(punch_force)
	wearer = null
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(gloves) //We have nested gloves! Gloves under our gloves!
		if(!H.equip_to_slot_if_possible(gloves, slot_gloves))
			gloves.forceMove(get_turf(src))
		if(ring)
			gloves.ring = ring
		src.gloves = null
	else if(ring && istype(H)) //We do NOT have gloves under our gloves but have a ring under our glove instead!
		if(!H.equip_to_slot_if_possible(ring, slot_gloves))
			ring.forceMove(get_turf(src))
		src.ring = null

/obj/item/clothing/gloves
	var/datum/unarmed_attack/special_attack = null //do the gloves have a special unarmed attack?
	var/special_attack_type = null

/obj/item/clothing/gloves/Initialize(mapload)
	. = ..()
	if(special_attack_type && ispath(special_attack_type))
		special_attack = new special_attack_type

/////////////////////////////////////////////////////////////////////
//Rings

/obj/item/clothing/gloves/ring
	name = DEVELOPER_WARNING_NAME // "ring"
	w_class = ITEMSIZE_TINY
	icon = 'icons/inventory/hands/item.dmi'
	gender = NEUTER
	species_restricted = list("exclude", SPECIES_DIONA)
	siemens_coefficient = 1
	glove_level = 1
	fingerprint_chance = 100
	punch_force = 2
	body_parts_covered = 0
	drop_sound = 'sound/items/drop/ring.ogg'
	pickup_sound = 'sound/items/pickup/ring.ogg'

///////////////////////////////////////////////////////////////////////
//Head
/obj/item/clothing/head
	name = DEVELOPER_WARNING_NAME // "Head"
	icon = 'icons/inventory/head/item.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_hats.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_hats.dmi',
		)
	body_parts_covered = HEAD
	heat_protection = HEAD
	cold_protection = HEAD
	slot_flags = SLOT_HEAD
	w_class = ITEMSIZE_SMALL
	blood_sprite_state = "helmetblood"

	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_cone_y_offset = 11

	var/light_overlay = "helmet_light"
	var/image/helmet_light

	sprite_sheets = list(
		SPECIES_TESHARI = 'icons/inventory/head/mob_teshari.dmi',
		SPECIES_VOX = 'icons/inventory/head/mob_vox.dmi'
		)
	drop_sound = 'sound/items/drop/hat.ogg'
	pickup_sound = 'sound/items/pickup/hat.ogg'

/obj/item/clothing/head/attack_self(mob/user)
	if(light_range)
		if(!isturf(user.loc))
			to_chat(user, "You cannot toggle the light while in this [user.loc]")
			return
		update_flashlight(user)
		to_chat(user, "You [light_on ? "enable" : "disable"] the helmet light.")
	else
		return ..(user)

/obj/item/clothing/head/proc/update_flashlight(var/mob/user = null)
	set_light_on(!light_on)

	if(light_system == STATIC_LIGHT)
		update_light()

	update_icon(user)
	user.update_mob_action_buttons()

/obj/item/clothing/head/attack_ai(var/mob/user)
	if(!mob_wear_hat(user))
		return ..()

/obj/item/clothing/head/attack_generic(var/mob/user)
	if(!mob_wear_hat(user))
		return ..()

/obj/item/clothing/head/proc/mob_wear_hat(var/mob/user)
	if(!Adjacent(user))
		return 0
	var/success
	if(istype(user, /mob/living/silicon/robot/drone))
		var/mob/living/silicon/robot/drone/D = user
		if(D.hat)
			success = 2
		else
			D.wear_hat(src)
			success = 1
	else if(istype(user, /mob/living/carbon/alien/diona))
		var/mob/living/carbon/alien/diona/D = user
		if(D.hat)
			success = 2
		else
			D.wear_hat(src)
			success = 1

	if(!success)
		return 0
	else if(success == 2)
		to_chat(user, span_warning("You are already wearing a hat."))
	else if(success == 1)
		to_chat(user, span_notice("You crawl under \the [src]."))
	return 1

/obj/item/clothing/head/update_icon(var/mob/user)
	var/mob/living/carbon/human/H
	if(ishuman(user))
		H = user

	if(light_on)
		// Generate object icon.
		if(!GLOB.light_overlay_cache["[light_overlay]_icon"])
			GLOB.light_overlay_cache["[light_overlay]_icon"] = image(icon = 'icons/obj/light_overlays.dmi', icon_state = "[light_overlay]")
		helmet_light = GLOB.light_overlay_cache["[light_overlay]_icon"]
		add_overlay(helmet_light)

		// Generate and cache the on-mob icon, which is used in update_inv_head().
		var/body_type = (H && H.species.get_bodytype(H))
		var/cache_key = "[light_overlay][body_type && LAZYACCESS(sprite_sheets, body_type) ? body_type : ""]"
		if(!GLOB.light_overlay_cache[cache_key])
			var/use_icon = LAZYACCESS(sprite_sheets, body_type) || 'icons/mob/light_overlays.dmi'
			GLOB.light_overlay_cache[cache_key] = image(icon = use_icon, icon_state = "[light_overlay]")

	else if(helmet_light)
		cut_overlay(helmet_light)
		helmet_light = null

	user.update_inv_head() //Will redraw the helmet with the light on the mob

/obj/item/clothing/head/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_head()

///////////////////////////////////////////////////////////////////////
//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/inventory/face/item.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_masks.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_masks.dmi',
		)
	heat_protection = FALSE //No heat protection anywhere
	cold_protection = FALSE //No heat protection anywhere
	slot_flags = SLOT_MASK
	body_parts_covered = FACE|EYES
	blood_sprite_state = "maskblood"
	sprite_sheets = list(
		SPECIES_TESHARI = 'icons/inventory/face/mob_teshari.dmi',
		SPECIES_VOX = 'icons/inventory/face/mob_vox.dmi',
		SPECIES_TAJARAN = 'icons/inventory/face/mob_tajaran.dmi',
		SPECIES_UNATHI = 'icons/inventory/face/mob_unathi.dmi'
		)

	var/voicechange = 0
	var/list/say_messages
	var/list/say_verbs

	drop_sound = "generic_drop"
	pickup_sound = "generic_pickup"

/obj/item/clothing/mask/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_mask()

/obj/item/clothing/mask/proc/filter_air(datum/gas_mixture/air)
	return

///////////////////////////////////////////////////////////////////////
//Shoes
/obj/item/clothing/shoes
	name = DEVELOPER_WARNING_NAME // "shoes"
	icon = 'icons/inventory/feet/item.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_shoes.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_shoes.dmi',
		)
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	siemens_coefficient = 0.9
	body_parts_covered = FEET
	heat_protection = FEET
	cold_protection = FEET
	slot_flags = SLOT_FEET
	blood_sprite_state = "shoeblood"

	var/can_hold_knife = 0
	var/obj/item/holding

	var/shoes_under_pants = 0

	var/water_speed = 0		//Speed boost/decrease in water, lower/negative values mean more speed
	var/snow_speed = 0		//Speed boost/decrease on snow, lower/negative values mean more speed

	var/step_volume_mod = 1	//How quiet or loud footsteps in this shoe are
	var/obj/item/clothing/shoes/shoes = null	//If we are wearing shoes in our shoes. Used primarily for magboots.
	var/blocks_footsteps = TRUE //Does this shoe block custom footstep sounds?

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	force = 2
	var/overshoes = 0
	species_restricted = list("exclude",SPECIES_TESHARI, SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_TESHARI = 'icons/inventory/feet/mob_teshari.dmi',
		SPECIES_VOX = 'icons/inventory/feet/mob_vox.dmi'
		)
	drop_sound = 'sound/items/drop/shoes.ogg'
	pickup_sound = 'sound/items/pickup/shoes.ogg'

	update_icon_define_digi = "icons/inventory/feet/mob_digi.dmi"

/obj/item/clothing/shoes/Destroy()
	if(shoes)
		qdel_null(shoes)
	if(holding)
		qdel_null(holding)
	return ..()

/obj/item/clothing/shoes/proc/draw_knife(mob/living/user)
	set name = "Draw Boot Knife"
	set desc = "Pull out your boot knife."
	set category = "IC.Game"
	set src in usr

	if(user.stat || user.restrained() || user.incapacitated())
		return

	holding.forceMove(get_turf(user))

	if(user.put_in_hands(holding))
		user.visible_message(span_danger("\The [user] pulls a knife out of their boot!"))
		playsound(src, 'sound/weapons/holster/sheathout.ogg', 25)
		holding = null
		cut_overlay("[icon_state]_knife")
	else
		to_chat(user, span_warning("Your need an empty, unbroken hand to do that."))
		holding.forceMove(src)

	if(!holding)
		verbs -= /obj/item/clothing/shoes/proc/draw_knife

	update_icon()
	return

/obj/item/clothing/shoes/attack_hand(var/mob/living/M)
	if(can_hold_knife == 1 && holding && src.loc == M)
		draw_knife(M)
		return
	..()

/obj/item/clothing/shoes/attackby(var/obj/item/I, var/mob/user)
	if((can_hold_knife == 1) && (istype(I, /obj/item/material/shard) || \
		istype(I, /obj/item/material/butterfly) || \
		istype(I, /obj/item/material/kitchen/utensil) || \
		istype(I, /obj/item/material/knife/tacknife)))
		if(holding)
			to_chat(user, span_warning("\The [src] is already holding \a [holding]."))
			return
		user.unEquip(I)
		I.forceMove(src)
		holding = I
		user.visible_message(span_infoplain(span_bold("\The [user]") + " shoves \the [I] into \the [src]."))
		verbs |= /obj/item/clothing/shoes/proc/draw_knife
		update_icon()
	else
		return ..()

/obj/item/clothing/shoes/verb/toggle_layer()
	set name = "Switch Shoe Layer"
	set category = "Object"

	if(shoes_under_pants == -1)
		to_chat(usr, span_notice("\The [src] cannot be worn above your suit!"))
		return
	shoes_under_pants = !shoes_under_pants
	update_icon()

/obj/item/clothing/shoes/update_icon()
	. = ..()
	if(holding)
		add_overlay("[icon_state]_knife")
	if(contaminated)
		add_overlay(contamination_overlay)
	if(gurgled) //VOREStation Edit Start
		wash(CLEAN_ALL)
		gurgle_contaminate() //VOREStation Edit End
	if(ismob(usr))
		var/mob/M = usr
		M.update_inv_shoes()

/obj/item/clothing/shoes/wash()
	. = ..()
	update_icon()

/obj/item/clothing/shoes/proc/handle_movement(var/turf/walking, var/running)
	if(prob(1) && !recent_squish) //VOREStation edit begin
		recent_squish = 1
		spawn(100)
			recent_squish = 0
		for(var/mob/living/M in contents)
			var/emote = pick(inside_emotes)
			to_chat(M,emote) //VOREStation edit end
	return

/obj/item/clothing/shoes/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_shoes()


///////////////////////////////////////////////////////////////////////
//Suit
/obj/item/clothing/suit
	name = DEVELOPER_WARNING_NAME // "suit"
	icon = 'icons/inventory/suit/item.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_suits.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_suits.dmi',
		)
	var/fire_resist = T0C+100
	body_parts_covered = CHEST|ARMS|LEGS
	//Switch to taur sprites if a taur equips
	sprite_sheets = list(
		SPECIES_TESHARI = 'icons/inventory/suit/mob_teshari.dmi',
		SPECIES_VOX = 'icons/inventory/suit/mob_vox.dmi',
		SPECIES_WEREBEAST = 'icons/inventory/suit/mob_vr_werebeast.dmi')
	max_heat_protection_temperature = T0C+100
	allowed = list(POCKET_EMERGENCY)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0)
	slot_flags = SLOT_OCLOTHING
	heat_protection = ARMS|LEGS|CHEST //At a minimum. Some might be more covering or less covering!
	cold_protection = ARMS|LEGS|CHEST //At a minimum. Some might be more covering or less covering!
	var/blood_overlay_type = "suit"
	blood_sprite_state = "suitblood" //Defaults to the suit's blood overlay, so that some blood renders instead of no blood.

	//Hood stuff. See hooded.dm for more info. This should be expanded so all suits can have hoods if desired.
	//Currently only used by /obj/item/clothing/suit/storage/hooded.
	var/obj/item/clothing/head/hood
	var/hoodtype = null //so the chaplain hoodie or other hoodies can override this
	var/hood_up = FALSE
	var/has_hood_sprite = FALSE
	var/special_hood_handling = FALSE
	var/toggleicon
	actions_types = list()

	var/taurized = FALSE
	siemens_coefficient = 0.9
	w_class = ITEMSIZE_NORMAL
	preserve_item = 1
	equip_sound = 'sound/items/jumpsuit_equip.ogg'


	sprite_sheets = list(
		SPECIES_TESHARI = 'icons/inventory/suit/mob_teshari.dmi',
		SPECIES_VOX = 'icons/inventory/suit/mob_vox.dmi'
		)

	valid_accessory_slots = (ACCESSORY_SLOT_OVER | ACCESSORY_SLOT_ARMBAND)
	restricted_accessory_slots = (ACCESSORY_SLOT_ARMBAND)

	update_icon_define_digi = "icons/inventory/suit/mob_digi.dmi"

/obj/item/clothing/suit/Initialize(mapload)
	MakeHood()
	toggleicon = "[initial(icon_state)]"
	. = ..()

/obj/item/clothing/suit/Destroy()
	QDEL_NULL(hood)
	return ..()

/obj/item/clothing/suit/update_icon()
	. = ..()
	if(has_hood_sprite) //If we have a special hood_sprite, great, let's use it! Only used by /obj/item/clothing/suit/storage/hooded atm.
		icon_state = "[toggleicon][hood_up ? "_t" : ""]"

/obj/item/clothing/suit/equipped(mob/user, slot)
	if(slot != slot_wear_suit)
		RemoveHood()
	..()

/obj/item/clothing/suit/dropped(mob/user)
	RemoveHood()
	..()

/obj/item/clothing/suit/ui_action_click(mob/user, actiontype)
	if(..())
		return TRUE
	ToggleHood()

/// HOOD STUFF BELOW HERE.
/obj/item/clothing/suit/proc/MakeHood()
	if(!hoodtype)
		return
	var/obj/item/clothing/head/hood/H = new hoodtype(src)
	hood = H
	if(!actions_types.len) //If we don't already have a special action type, let's add it.
		actions_types |= /datum/action/item_action/toggle_hood

/obj/item/clothing/suit/proc/RemoveHood()
	hood_up = FALSE
	update_icon()
	if(hood)
		hood.canremove = TRUE // This shouldn't matter anyways but just incase.
		if(ishuman(hood.loc))
			var/mob/living/carbon/H = hood.loc
			H.unEquip(hood, 1)
			H.update_inv_wear_suit()
		hood.forceMove(src)

/obj/item/clothing/suit/proc/ToggleHood()
	if(!hood || special_hood_handling) //Some suits have special handling (See: void.dm with it's ui_action_click doing toggle_helmet())
		return //In that case, we return and allow it to do it's special handling!
	if(hood_up)
		RemoveHood()
		return
	if(ishuman(loc))
		var/mob/living/carbon/human/H = src.loc
		if(H.wear_suit != src)
			to_chat(H, span_warning("You must be wearing [src] to put up the hood!"))
			return
		if(H.head)
			to_chat(H, span_warning("You're already wearing something on your head!"))
			return
		else
			if(color != hood.color)
				hood.color = color
			H.equip_to_slot_if_possible(hood,slot_head,0,0,1)
			hood_up = TRUE
			hood.canremove = FALSE
			update_icon()
			H.update_inv_wear_suit()
///Hood stuff end.

/obj/item/clothing/suit/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_suit()

/obj/item/clothing/suit/equipped(var/mob/user, var/slot)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/taurtail = istaurtail(H.tail_style)
		if((taurized && !taurtail) || (!taurized && taurtail))
			taurize(user, taurtail)

	return ..()

/obj/item/clothing/suit/proc/taurize(var/mob/living/carbon/human/taur, has_taur_tail = FALSE)
	if(has_taur_tail)
		var/datum/sprite_accessory/tail/taur/taurtail = taur.tail_style
		if(taurtail.suit_sprites && (get_worn_icon_state(slot_wear_suit_str) in cached_icon_states(taurtail.suit_sprites)))
			icon_override = taurtail.suit_sprites
			taurized = TRUE
	// means that if a taur puts on an already taurized suit without a taur sprite
	// for their taur type, but the previous taur type had a sprite, it stays
	// taurized and they end up with that taur style which is funny
	else
		taurized = FALSE

	if(!taurized)
		icon_override = initial(icon_override)
		taurized = FALSE

// Taur suits need to be shifted so its centered on their taur half.
/obj/item/clothing/suit/make_worn_icon(var/body_type,var/slot_name,var/inhands,var/default_icon,var/default_layer = 0,var/icon/clip_mask)
	var/image/standing = ..()
	if(taurized) //Special snowflake var on suits
		standing.pixel_x = -16
		standing.layer = BODY_LAYER + 17 // 17 is above tail layer, so will not be covered by taurbody. TAIL_UPPER_LAYER +1
	return standing

/obj/item/clothing/suit/apply_accessories(var/image/standing)
	if(LAZYLEN(accessories) && taurized)
		for(var/obj/item/clothing/accessory/A in accessories)
			var/image/I = new(A.get_mob_overlay())
			I.pixel_x = 16 //Opposite of the pixel_x on the suit (-16) from taurization to cancel it out and puts the accessory in the correct place on the body.
			standing.add_overlay(I)
	else
		return ..()


///////////////////////////////////////////////////////////////////////
//Under clothing
/obj/item/clothing/under
	icon = 'icons/inventory/uniform/item.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_uniforms.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_uniforms.dmi',
		)
	name = "under"
	body_parts_covered = ARMS|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_ICLOTHING
	heat_protection = ARMS|LEGS|CHEST
	cold_protection = ARMS|LEGS|CHEST
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	equip_sound = 'sound/items/jumpsuit_equip.ogg'
	w_class = ITEMSIZE_NORMAL
	show_messages = 1
	blood_sprite_state = "uniformblood"

	var/has_sensor = 1 //For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1
	var/rolled_down = -1 //0 = unrolled, 1 = rolled, -1 = cannot be toggled
	var/rolled_down_icon_override = TRUE
	var/rolled_sleeves = -1 //0 = unrolled, 1 = rolled, -1 = cannot be toggled
	var/rolled_sleeves_icon_override = TRUE
	sprite_sheets = list(
		SPECIES_TESHARI = 'icons/inventory/uniform/mob_teshari.dmi',
		SPECIES_VOX = 'icons/inventory/uniform/mob_vox.dmi'
		)

	//convenience var for defining the icon state for the overlay used when the clothing is worn.
	//Also used by rolling/unrolling.
	var/worn_state = null
	valid_accessory_slots = (\
		ACCESSORY_SLOT_UTILITY\
		|ACCESSORY_SLOT_WEAPON\
		|ACCESSORY_SLOT_ARMBAND\
		|ACCESSORY_SLOT_DECOR\
		|ACCESSORY_SLOT_MEDAL\
		|ACCESSORY_SLOT_INSIGNIA\
		|ACCESSORY_SLOT_TIE\
		|ACCESSORY_SLOT_RANK\
		|ACCESSORY_SLOT_DEPT\
		|ACCESSORY_SLOT_OVER\
		|ACCESSORY_SLOT_RING\
		|ACCESSORY_SLOT_WRIST)
	restricted_accessory_slots = (\
		ACCESSORY_SLOT_UTILITY\
		|ACCESSORY_SLOT_WEAPON\
		|ACCESSORY_SLOT_ARMBAND\
		|ACCESSORY_SLOT_TIE\
		|ACCESSORY_SLOT_RANK\
		|ACCESSORY_SLOT_DEPT\
		|ACCESSORY_SLOT_OVER)

	var/icon/rolled_down_icon = 'icons/inventory/uniform/mob_rolled_down.dmi'
	var/icon/rolled_down_sleeves_icon = 'icons/inventory/uniform/mob_sleeves_rolled.dmi'

	update_icon_define_digi = "icons/inventory/uniform/mob_digi.dmi"

/obj/item/clothing/under/attack_hand(var/mob/user)
	if(LAZYLEN(accessories))
		..()
	if ((ishuman(user) || issmall(user)) && src.loc == user)
		return
	..()

/obj/item/clothing/under/Initialize(mapload)
	. = ..()
	if(worn_state)
		LAZYSET(item_state_slots, slot_w_uniform_str, worn_state)
	else
		worn_state = icon_state

	//autodetect rollability
	if(rolled_down < 0)
		if(("[worn_state]_d" in cached_icon_states(icon)) || (worn_state in cached_icon_states(rolled_down_icon)) || ("[worn_state]_d" in cached_icon_states(icon_override)))
			rolled_down = 0

	if(rolled_down == -1)
		verbs -= /obj/item/clothing/under/verb/rollsuit
	if(rolled_sleeves == -1)
		verbs -= /obj/item/clothing/under/verb/rollsleeves

/obj/item/clothing/under/proc/update_rolldown_status()
	var/mob/living/carbon/human/H
	if(ishuman(src.loc))
		H = src.loc

	var/icon/under_icon
	if(icon_override && rolled_down_icon_override)
		under_icon = icon_override
	else if(H && LAZYACCESS(sprite_sheets, H.species.get_bodytype(H)))
		under_icon = sprite_sheets[H.species.get_bodytype(H)]
	else if(LAZYACCESS(item_icons, slot_w_uniform_str))
		under_icon = item_icons[slot_w_uniform_str]
	else if (worn_state in cached_icon_states(rolled_down_icon))
		under_icon = rolled_down_icon

	// The _s is because the icon update procs append it.
	if((under_icon == rolled_down_icon && ("[worn_state]" in cached_icon_states(under_icon))) || ("[worn_state]_d" in cached_icon_states(under_icon)))
		if(rolled_down != 1)
			rolled_down = 0
	else
		rolled_down = -1
	if(H) update_clothing_icon()

/obj/item/clothing/under/proc/update_rollsleeves_status()
	var/mob/living/carbon/human/H
	if(ishuman(src.loc))
		H = src.loc

	var/icon/under_icon
	if(icon_override && rolled_sleeves_icon_override)
		under_icon = icon_override
	else if(H && LAZYACCESS(sprite_sheets, H.species.get_bodytype(H)))
		under_icon = sprite_sheets[H.species.get_bodytype(H)]
	else if(LAZYACCESS(item_icons, slot_w_uniform_str))
		under_icon = item_icons[slot_w_uniform_str]
	else if (worn_state in cached_icon_states(rolled_down_sleeves_icon))
		under_icon = rolled_down_sleeves_icon
	else
		under_icon = new /icon(INV_W_UNIFORM_DEF_ICON)

	// The _s is because the icon update procs append it.
	if((under_icon == rolled_down_sleeves_icon && ("[worn_state]" in cached_icon_states(under_icon))) || ("[worn_state]_r" in cached_icon_states(under_icon)))
		if(rolled_sleeves != 1)
			rolled_sleeves = 0
	else
		rolled_sleeves = -1
	if(H) update_clothing_icon()

/obj/item/clothing/under/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_w_uniform()

	set_clothing_index()


/obj/item/clothing/under/examine(mob/user)
	. = ..()
	switch(src.sensor_mode)
		if(0)
			. += "Its sensors appear to be disabled."
		if(1)
			. += "Its binary life sensors appear to be enabled."
		if(2)
			. += "Its vital tracker appears to be enabled."
		if(3)
			. += "Its vital tracker and tracking beacon appear to be enabled."

/obj/item/clothing/under/proc/set_sensors(mob/user)
	if (istype(user, /mob/observer)) return
	if (user.stat || user.restrained()) return
	if(has_sensor >= 2)
		to_chat(user, "The controls are locked.")
		return 0
	if(has_sensor <= 0)
		to_chat(user, "This suit does not have any sensors.")
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = tgui_input_list(user, "Select a sensor mode:", "Suit Sensor Mode", modes)
	if(get_dist(user, src) > 1)
		to_chat(user, "You have moved too far away.")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == user)
		switch(sensor_mode)
			if(0)
				user.visible_message("[user] adjusts their sensors.", "You disable your suit's remote sensing equipment.")
			if(1)
				user.visible_message("[user] adjusts their sensors.", "Your suit will now report whether you are live or dead.")
			if(2)
				user.visible_message("[user] adjusts their sensors.", "Your suit will now report your vital lifesigns.")
			if(3)
				user.visible_message("[user] adjusts their sensors.", "Your suit will now report your vital lifesigns as well as your coordinate position.")

	else if (istype(src.loc, /mob))
		user.visible_message("[user] adjusts [src.loc]'s sensors.", "You adjust [src.loc]'s sensors.")

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!isliving(usr)) return
	if(usr.stat) return

	update_rolldown_status()
	if(rolled_down == -1)
		to_chat(usr, span_notice("You cannot roll down [src]!"))
		return
	if((rolled_sleeves == 1) && !(rolled_down))
		rolled_sleeves = 0

	rolled_down = !rolled_down
	if(rolled_down)
		body_parts_covered = initial(body_parts_covered)
		body_parts_covered &= ~(UPPER_TORSO|ARMS)
		heat_protection &= ~(UPPER_TORSO|ARMS)
		cold_protection &= ~(UPPER_TORSO|ARMS)
		if(worn_state in cached_icon_states(rolled_down_icon))
			icon_override = rolled_down_icon
			LAZYSET(item_state_slots, slot_w_uniform_str, worn_state)
		else
			LAZYSET(item_state_slots, slot_w_uniform_str, "[worn_state]_d")

		to_chat(usr, span_notice("You roll down your [src]."))
	else
		body_parts_covered = initial(body_parts_covered)
		heat_protection = initial(heat_protection)
		cold_protection = initial(heat_protection)
		if(icon_override == rolled_down_icon)
			icon_override = initial(icon_override)
		LAZYSET(item_state_slots, slot_w_uniform_str, worn_state)
		to_chat(usr, span_notice("You roll up your [src]."))
	update_clothing_icon()

/obj/item/clothing/under/verb/rollsleeves()
	set name = "Roll Up Sleeves"
	set category = "Object"
	set src in usr
	if(!isliving(usr)) return
	if(usr.stat) return

	update_rollsleeves_status()
	if(rolled_sleeves == -1)
		to_chat(usr, span_notice("You cannot roll up your [src]'s sleeves!"))
		return
	if(rolled_down == 1)
		to_chat(usr, span_notice("You must roll up your [src] first!"))
		return

	rolled_sleeves = !rolled_sleeves
	if(rolled_sleeves)
		body_parts_covered &= ~(ARMS)
		heat_protection &= ~(ARMS)
		cold_protection &= ~(ARMS)
		if(worn_state in cached_icon_states(rolled_down_sleeves_icon))
			icon_override = rolled_down_sleeves_icon
			LAZYSET(item_state_slots, slot_w_uniform_str, worn_state)
		else
			LAZYSET(item_state_slots, slot_w_uniform_str, "[worn_state]_r")
		to_chat(usr, span_notice("You roll up your [src]'s sleeves."))
	else
		body_parts_covered = initial(body_parts_covered)
		heat_protection = initial(heat_protection)
		cold_protection = initial(heat_protection)
		if(icon_override == rolled_down_sleeves_icon)
			icon_override = initial(icon_override)
		LAZYSET(item_state_slots, slot_w_uniform_str, worn_state)
		to_chat(usr, span_notice("You roll down your [src]'s sleeves."))
	update_clothing_icon()

/obj/item/clothing/under/rank/Initialize(mapload)
	. = ..()
	sensor_mode = pick(0,1,2,3)

/obj/item/clothing/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(IC)
		IC.clothing = null
		action_circuit = null // Will get deleted by qdel-ing the IC assembly.
		qdel_null(IC)
	for(var/mob/living/M in contents)
		M.forceMove(get_turf(src))
	wearer = null
	return ..()

/obj/item/clothing/proc/handle_digitigrade(var/mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		// if digitigrade-use flag is set
		if(H.digitigrade)

			// Don't reset if already set
			if(!fit_for_digi)
				fit_for_digi = TRUE // set flag even if no icon_state exists, so we don't repeat checks

				//if update_icon_define is already set to something, place it in a var to hold it temporarily
				if(update_icon_define)
					update_icon_define_orig = update_icon_define

				// only override icon if a corresponding digitigrade replacement icon_state exists
				// otherwise, keep the old non-digi icon_define (or nothing)
				if(icon_state && icon_states(update_icon_define_digi)?.Find(icon_state))
					update_icon_define = update_icon_define_digi


		// if not-digitigrade, only act if the clothing was previously fit for a digitigrade char
		else
			if(fit_for_digi)
				fit_for_digi = FALSE

				//either reset update_icon_define to it's old value
				// or reset update_icon_define to null
				if(update_icon_define_orig)
					update_icon_define = update_icon_define_orig
					update_icon_define_orig = null
				else
					update_icon_define = null

/obj/item/clothing/shoes/equipped(var/mob/user, var/slot)
	. = ..()
	handle_digitigrade(user)

/obj/item/clothing/suit/equipped(var/mob/user, var/slot)
	. = ..()
	handle_digitigrade(user)

/obj/item/clothing/under/equipped(var/mob/user, var/slot)
	. = ..()
	handle_digitigrade(user)
