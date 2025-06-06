/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "secure1"
	density = TRUE
	opened = 0
	var/locked = 1
	var/broken = 0
	var/large = 1
	wall_mounted = 0 //never solid (You can always pass over it)
	health = 200

	closet_appearance = /decl/closet_appearance/secure_closet

/obj/structure/closet/secure_closet/can_open()
	if(locked)
		return 0
	return ..()

/obj/structure/closet/secure_closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken)
		if(prob(50/severity))
			locked = !locked
			update_icon()
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				req_access = list()
				req_access += pick(get_all_station_access())
	..()

/obj/structure/closet/secure_closet/proc/togglelock(mob/user as mob)
	if(opened)
		to_chat(user, span_notice("Close the locker first."))
		return
	if(broken)
		to_chat(user, span_warning("The locker appears to be broken."))
		return
	if(user.loc == src)
		to_chat(user, span_notice("You can't reach the lock from inside."))
		return
	if(allowed(user))
		locked = !locked
		playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				to_chat(O, span_notice("The locker has been [locked ? null : "un"]locked by [user]."))
		update_icon()
	else
		to_chat(user, span_notice("Access Denied"))

/obj/structure/closet/secure_closet/attackby(obj/item/W as obj, mob/user as mob)
	if(W.has_tool_quality(TOOL_WRENCH))
		if(opened)
			if(anchored)
				user.visible_message("\The [user] begins unsecuring \the [src] from the floor.", "You start unsecuring \the [src] from the floor.")
			else
				user.visible_message("\The [user] begins securing \the [src] to the floor.", "You start securing \the [src] to the floor.")
			if(do_after(user, 20 * W.toolspeed))
				if(!src) return
				to_chat(user, span_notice("You [anchored? "un" : ""]secured \the [src]!"))
				anchored = !anchored
				return
		else
			to_chat(user, span_notice("You can't reach the anchoring bolts when the door is closed!"))
	else if(opened)
		if(istype(W, /obj/item/storage/laundry_basket))
			return ..(W,user)
		if(istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if(large)
				MouseDrop_T(G.affecting, user)	//act like they were dragged onto the closet
			else
				to_chat(user, span_notice("The locker is too small to stuff [G.affecting] into!"))
		if(isrobot(user))
			return
		if(W.loc != user) // This should stop mounted modules ending up outside the module.
			return
		user.drop_item()
		if(W)
			W.forceMove(loc)
	else if(istype(W, /obj/item/melee/energy/blade))
		if(emag_act(INFINITY, user, span_danger("The locker has been sliced open by [user] with \an [W]!"), span_danger("You hear metal being sliced and sparks flying.")))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, loc)
			spark_system.start()
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(src, "sparks", 50, 1)
	else if(istype(W,/obj/item/packageWrap) || W.has_tool_quality(TOOL_WELDER))
		return ..(W,user)
	else
		togglelock(user)

/obj/structure/closet/secure_closet/emag_act(var/remaining_charges, var/mob/user, var/emag_source, var/visual_feedback = "", var/audible_feedback = "")
	if(!broken)
		broken = 1
		locked = 0
		desc = "It appears to be broken."

		if(visual_feedback)
			visible_message(visual_feedback, audible_feedback)
		else if(user && emag_source)
			visible_message(span_warning("\The [src] has been broken by \the [user] with \an [emag_source]!"), "You hear a faint electrical spark.")
		else
			visible_message(span_warning("\The [src] sparks and breaks open!"), "You hear a faint electrical spark.")
		update_icon()
		return 1

/obj/structure/closet/secure_closet/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(locked)
		togglelock(user)
	else
		toggle(user)

/obj/structure/closet/secure_closet/AltClick()
	..()
	verb_togglelock()

/obj/structure/closet/secure_closet/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(!usr.canmove || usr.stat || usr.restrained() || !Adjacent(usr)) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr) || isrobot(usr))
		add_fingerprint(usr)
		togglelock(usr)
	else
		to_chat(usr, span_warning("This mob type can't use this verb."))

/obj/structure/closet/secure_closet/update_icon()
	if(opened)
		icon_state = "open"
	else
		if(broken)
			icon_state = "closed_emagged[sealed ? "_welded" : ""]"
		else
			if(locked)
				icon_state = "closed_locked[sealed ? "_welded" : ""]"
			else
				icon_state = "closed_unlocked[sealed ? "_welded" : ""]"

/obj/structure/closet/secure_closet/req_breakout()
	if(!opened && locked) return 1
	return ..() //It's a secure closet, but isn't locked.

/obj/structure/closet/secure_closet/break_open()
	desc += " It appears to be broken."
	broken = 1
	locked = 0
	..()

/obj/structure/closet/secure_closet/mind
	name = "mind secured locker"
	var/datum/mind/owner
	var/self_del = 1
	anchored = 0

/obj/structure/closet/secure_closet/mind/Initialize(mapload, var/datum/mind/mind_target, var/del_self = 1)
	. = ..()
	self_del = del_self
	if(mind_target)
		owner = mind_target
		name = "Owned by [owner.name]"
		if(owner.current)
			var/icon/I = get_flat_icon(owner.current, dir=SOUTH, no_anim=TRUE)
			var/image/IM = image(I, pixel_x = (32 - I.Width()))
			//icon2base64(get_flat_icon(owner.current,dir=SOUTH,no_anim=TRUE))
			/*
			I.appearance_flags |= (RESET_COLOR|PIXEL_SCALE)
			I.plane = MOB_PLANE
			I.layer = MOB_LAYER
			*/
			add_overlay(IM)
			qdel(I)

/obj/structure/closet/secure_closet/mind/allowed(mob/user)
	if(user.mind == owner)
		return TRUE
	else
		return FALSE

/obj/structure/closet/secure_closet/mind/open()
	.=..()
	if(self_del)
		qdel(src)

/obj/structure/closet/secure_closet/mind/LateInitialize()
	if(ispath(closet_appearance))
		closet_appearance = GLOB.closet_appearances[closet_appearance]
		if(istype(closet_appearance))
			icon = closet_appearance.icon
			color = null
	update_icon()
