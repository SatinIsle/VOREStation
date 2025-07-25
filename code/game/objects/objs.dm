/obj
	layer = OBJ_LAYER
	plane = OBJ_PLANE
	vis_flags = VIS_INHERIT_PLANE //when this be added to vis_contents of something it inherit something.plane, important for visualisation of obj in openspace.
	//Used to store information about the contents of the object.
	var/list/matter
	var/w_class // Size of the object.
	var/unacidable = FALSE //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2
	var/throwforce = 1
	var/catchable = 1	// can it be caught on throws/flying?
	var/sharp = FALSE		// whether this object cuts
	var/edge = FALSE		// whether this object is more likely to dismember
	var/pry = 0			//Used in attackby() to open doors
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
	var/damtype = "brute"
	var/armor_penetration = 0
	var/show_messages
	var/preserve_item = 0 //whether this object is preserved when its owner goes into cryo-storage, gateway, etc
	var/can_speak = 0 //For MMIs and admin trickery. If an object has a brainmob in its contents, set this to 1 to allow it to speak.

	var/show_examine = TRUE	// Does this pop up on a mob when the mob is examined?

	var/redgate_allowed = TRUE	//can we be taken through the redgate, in either direction?
	var/being_used = 0

/obj/Destroy()
	STOP_PROCESSING(SSobj, src)

	//VOREStation Add Start - I really am an idiot why did I make it this way
	if(micro_target)
		for(var/thing in src.contents)
			if(!ismob(thing))
				continue
			var/mob/m = thing
			if(isbelly(src.loc))
				m.forceMove(src.loc)
			else
				m.forceMove(get_turf(src.loc))
			m.visible_message(span_notice("\The [m] tumbles out of \the [src]!"))
	//VOREStation Add End

	if(istype(src, /obj/item))
		var/obj/item/I = src
		if(I.possessed_voice && I.possessed_voice.len)
			for(var/mob/living/voice/V in I.possessed_voice)
				if(!V.tf_mob_holder)
					V.ghostize(0)
					V.stat = DEAD
					qdel(V)

	return ..()

/obj/Topic(href, href_list, var/datum/tgui_state/state = GLOB.tgui_default_state)
	if(usr && ..())
		return 1

	// In the far future no checks are made in an overriding Topic() beyond if(..()) return
	// Instead any such checks are made in CanUseTopic()
	if(CanUseTopic(usr, state, href_list) == STATUS_INTERACTIVE)
		CouldUseTopic(usr)
		return 0

	CouldNotUseTopic(usr)
	return 1

/obj/CanUseTopic(var/mob/user, var/datum/tgui_state/state = GLOB.tgui_default_state)
	if(user.CanUseObjTopic(src))
		return ..()
	to_chat(user, span_danger("[icon2html(src, user.client)]Access Denied!"))
	return STATUS_CLOSE

/mob/living/silicon/CanUseObjTopic(var/obj/O)
	var/id = src.GetIdCard()
	return O.check_access(id)

/mob/proc/CanUseObjTopic()
	return 1

/obj/proc/CouldUseTopic(var/mob/user)
	var/atom/host = tgui_host()
	host.add_hiddenprint(user)

/obj/proc/CouldNotUseTopic(var/mob/user)
	// Nada

/obj/item/proc/is_used_on(obj/O, mob/user)

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/updateUsrDialog(mob/user)
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.attack_hand(M)
		if (isAI(user) || isrobot(user))
			if (!(user in nearby))
				if (user.client && user.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = 1
					src.attack_ai(user)

		// check for TK users

		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.get_type_in_hands(/obj/item/tk_grab))
				if(!(H in nearby))
					if(H.client && H.machine==src)
						is_in_use = 1
						src.attack_hand(H)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/attack_ghost(mob/user)
	tgui_interact(user)
	..()

/mob/proc/unset_machine()
	machine?.remove_visual(src)
	src.machine = null

/mob/proc/set_machine(var/obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = 1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

/obj/proc/hide(h)
	return

/obj/proc/hides_under_flooring()
	return 0

/obj/proc/hear_talk(mob/M, list/message_pieces, verb)
	if(talking_atom)
		talking_atom.catchMessage(multilingual_to_message(message_pieces), M)
/*
	var/mob/mo = locate(/mob) in src
	if(mo)
		var/rendered = span_game(span_say(span_name("[M.name]:") + " " + span_message("[text]"))))
		mo.show_message(rendered, 2)
		*/
	return

/obj/proc/hear_signlang(mob/M as mob, text, verb, datum/language/speaking) // Saycode gets worse every day.
	return FALSE

/obj/proc/see_emote(mob/M as mob, text, var/emote_type)
	return

// Used to mark a turf as containing objects that are dangerous to step onto.
/obj/proc/register_dangerous_to_step()
	var/turf/T = get_turf(src)
	if(T)
		T.register_dangerous_object(src)

/obj/proc/unregister_dangerous_to_step()
	var/turf/T = get_turf(src)
	if(T)
		T.unregister_dangerous_object(src)

// Test for if stepping on a tile containing this obj is safe to do, used for things like landmines and cliffs.
/obj/proc/is_safe_to_step(mob/living/L)
	return TRUE

/obj/proc/container_resist(var/mob/living)
	return

//To be called from things that spill objects on the floor.
//Makes an object move around randomly for a couple of tiles
/obj/proc/tumble(var/dist = 2)
	set waitfor = FALSE
	if (dist >= 1)
		dist += rand(0,1)
		for(var/i = 1, i <= dist, i++)
			if(src)
				step(src, pick(NORTH,SOUTH,EAST,WEST))
				sleep(rand(2,4))

// Gives the object a shake animation.
/obj/proc/animate_shake()
	var/init_px = pixel_x
	var/shake_dir = pick(-1, 1)
	animate(src, transform=turn(matrix(), 8*shake_dir), pixel_x=init_px + 2*shake_dir, time=1)
	animate(transform=null, pixel_x=init_px, time=6, easing=ELASTIC_EASING)

/obj/item/wash(clean_types)
	. = ..()
	if(blood_overlay && clean_types & CLEAN_WASH)
		overlays.Remove(blood_overlay)
	if(gurgled && clean_types & CLEAN_WASH)
		gurgled = FALSE
		cut_overlay(gurgled_overlays[gurgled_color])
	if(contaminated && clean_types & CLEAN_RAD) // Phoron and stuff, washing machine needed
		contaminated = FALSE
		cut_overlay(contamination_overlay)

/obj/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_MASS_DEL_TYPE, "Delete all of type")
	VV_DROPDOWN_OPTION(VV_HK_FAKE_CONVO, "Add Fake Prop Conversation")
	//VV_DROPDOWN_OPTION(VV_HK_OSAY, "Object Say")

/obj/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	//if(href_list[VV_HK_OSAY])
	//	return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/object_say, src)

	if(href_list[VV_HK_MASS_DEL_TYPE])
		if(!check_rights(R_DEBUG|R_SERVER))
			return
		var/action_type = tgui_alert(usr, "Strict type ([type]) or type and all subtypes?",,list("Strict type","Type and subtypes","Cancel"))
		if(action_type == "Cancel" || !action_type)
			return
		if(tgui_alert(usr, "Are you really sure you want to delete all objects of type [type]?",,list("Yes","No")) != "Yes")
			return
		if(tgui_alert(usr, "Second confirmation required. Delete?",,list("Yes","No")) != "Yes")
			return
		var/O_type = type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
				message_admins(span_notice("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) "))
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")
				message_admins(span_notice("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) "))

	if(href_list[VV_HK_FAKE_CONVO])
		if(!check_rights(R_FUN))
			return

		var/obj/item/pda/P = src
		if(!istype(P))
			to_chat(usr, span_warning("This can only be done to instances of type /pda"))
			return

		P.createPropFakeConversation_admin(usr)
