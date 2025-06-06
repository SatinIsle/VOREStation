///// A mob that gets used when prey dominate predators. Will automatically delete itself if it's not inside a mob.

/mob/living/dominated_brain
	name = "dominated brain"
	desc = "Someone who has taken a back seat within their own body."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain1"
	forced_psay = TRUE
	var/mob/living/prey_body		//The body of the person who dominated the brain
	var/prey_ckey					//The ckey of the person who dominated the brain
	var/prey_name					//In case the body is missing. ;3c
	var/list/prey_langs = list()
	var/mob/living/pred_body		//The body of the person who was dominated
	var/pred_ckey					//The ckey of the person who was dominated
	var/pred_ooc_notes
	var/pred_ooc_likes
	var/pred_ooc_dislikes
	var/pred_ooc_favs
	var/pred_ooc_maybes
	var/pred_ooc_style
	var/prey_ooc_favs
	var/prey_ooc_maybes
	var/prey_ooc_style
	var/prey_ooc_notes
	var/prey_ooc_likes
	var/prey_ooc_dislikes
	var/was_mob

/mob/living/dominated_brain/Initialize(mapload, var/mob/living/pred, preyname, var/mob/living/prey)
	prey_name = preyname
	if(prey)
		prey_body = prey
	pred_body = pred
	if(!isliving(loc))
		return INITIALIZE_HINT_QDEL
	. = ..()
	lets_register_our_signals()
	add_verb(src, /mob/living/dominated_brain/proc/resist_control)

/mob/living/dominated_brain/Life()
	. = ..()
	if(!isliving(loc))
		qdel(src)
	if(!ckey)
		qdel(src)

/mob/living/dominated_brain/say_understands(var/mob/other, var/datum/language/speaking = null)
	if(pred_body.say_understands(other, speaking))
		return TRUE
	else return FALSE

/mob/living/dominated_brain/proc/lets_register_our_signals()
	if(prey_body)
		RegisterSignal(prey_body, COMSIG_PARENT_QDELETING, PROC_REF(prey_was_deleted), TRUE)
	RegisterSignal(pred_body, COMSIG_PARENT_QDELETING, PROC_REF(pred_was_deleted), TRUE)

/mob/living/dominated_brain/proc/lets_unregister_our_signals()
	prey_was_deleted()
	pred_was_deleted()

/mob/living/dominated_brain/proc/prey_was_deleted()
	SIGNAL_HANDLER
	if(prey_body)
		UnregisterSignal(prey_body, COMSIG_PARENT_QDELETING)
		prey_body = null

/mob/living/dominated_brain/proc/pred_was_deleted()
	SIGNAL_HANDLER
	if(pred_body)
		UnregisterSignal(pred_body, COMSIG_PARENT_QDELETING)
		pred_body = null

/mob/living/dominated_brain/Destroy()
	lets_unregister_our_signals()
	. = ..()

/mob/living/dominated_brain/process_resist()
	//Resisting control by an alien mind.
	if(pred_body.ckey == pred_ckey)
		dominate_predator()
		return
	if(pred_ckey == ckey && pred_body.prey_controlled)
		if(tgui_alert(src, "Do you want to wrest control over your body back from \the [prey_name]?", "Regain Control",list("No","Yes")) != "Yes")
			return

		to_chat(src, span_danger("You begin to resist \the [prey_name]'s control!!!"))
		to_chat(pred_body, span_danger("You feel the captive mind of [src] begin to resist your control."))

		if(do_after(src, 10 SECONDS, exclusive = TRUE))
			restore_control()
		else
			to_chat(src, span_notice("Your attempt to regain control has been interrupted..."))
			to_chat(pred_body, span_notice("The dominant sensation fades away..."))
	else
		to_chat(src, span_warning("\The [pred_body] is already dominated, and cannot be controlled at this time."))
		..()

/mob/living/dominated_brain/proc/restore_control(ask = TRUE)

	if(ask && disconnect_time || client && ((client.inactivity / 10) / 60 > 10))
		if(tgui_alert(src, "Your predator's mind does not seem to be active presently. Releasing control in this state may leave you stuck in whatever state you find yourself in. Are you sure?", "Release Control",list("No","Yes")) != "Yes")
			return
	var/mob/living/prey_goes_here

	if(prey_body && prey_body.loc.loc == pred_body)	//The prey body exists and is here, let's handle the prey!

		prey_goes_here = prey_body

	else if(prey_body)	//It exists, but it's not here, let's spawn them a temporary home.
		var/mob/living/dominated_brain/ndb = new /mob/living/dominated_brain(pred_body, pred_body, prey_name, prey_body)
		ndb.name = prey_name
		ndb.prey_ckey = src.prey_ckey
		ndb.pred_ckey = src.pred_ckey

		prey_goes_here = ndb
		prey_goes_here.real_name = src.prey_name
		src.languages -= src.temp_languages
		prey_goes_here.languages |= src.prey_langs
		prey_goes_here.ooc_notes = prey_ooc_notes
		prey_goes_here.ooc_notes_likes = prey_ooc_likes
		prey_goes_here.ooc_notes_dislikes = prey_ooc_dislikes
		prey_goes_here.ooc_notes_favs = prey_ooc_favs
		prey_goes_here.ooc_notes_maybes = prey_ooc_maybes
		prey_goes_here.ooc_notes_style = prey_ooc_style
		add_verb(prey_goes_here, /mob/living/dominated_brain/proc/cease_this_foolishness)


	else		//The prey body does not exist, let's put them in the back seat instead!
		var/mob/living/dominated_brain/ndb = new /mob/living/dominated_brain(pred_body, pred_body, prey_name)
		ndb.name = prey_name
		ndb.prey_ckey = src.prey_ckey
		ndb.pred_ckey = src.pred_ckey

		prey_goes_here = ndb
		src.languages -= src.temp_languages
		prey_goes_here.languages |= src.prey_langs
		prey_goes_here.real_name = src.prey_name
		prey_goes_here.ooc_notes = prey_ooc_notes
		prey_goes_here.ooc_notes_likes = prey_ooc_likes
		prey_goes_here.ooc_notes_dislikes = prey_ooc_dislikes
		prey_goes_here.ooc_notes_favs = prey_ooc_favs
		prey_goes_here.ooc_notes_maybes = prey_ooc_maybes
		prey_goes_here.ooc_notes_style = prey_ooc_style

	///////////////////

	// Handle Pred
	remove_verb(pred_body, /mob/proc/release_predator)

	//Now actually put the people in the mobs
	prey_goes_here.ckey = src.prey_ckey
	pred_body.ckey = src.pred_ckey
	pred_body.ooc_notes = pred_ooc_notes
	pred_body.ooc_notes_likes = pred_ooc_likes
	pred_body.ooc_notes_dislikes = pred_ooc_dislikes
	pred_body.ooc_notes_favs = pred_ooc_favs
	pred_body.ooc_notes_maybes = pred_ooc_maybes
	pred_body.ooc_notes_style = pred_ooc_style
	log_and_message_admins("is now controlled by [pred_body.ckey]. They were restored to control through prey domination, and had been controlled by [prey_ckey].", pred_body)
	pred_body.absorb_langs()
	pred_body.prey_controlled = FALSE
	qdel(src)

/mob/living/proc/absorb_langs()		//This should be called on the predator in the exchange
	var/list/langlist = list()

	languages -= temp_languages
	LAZYCLEARLIST(src.temp_languages)
	src.temp_languages = list()
	for(var/mob/living/L in contents)
		if(istype(L,/mob/living/dominated_brain))
			if(L.ckey)
				langlist |= L.languages
	for(var/b in vore_organs)
		for(var/mob/living/L in b)
			if(isliving(L))
				if(L.ckey)
					langlist |= L.languages
	if(langlist.len)
		langlist -= languages
		for(var/datum/language/L in langlist)
			if(L.flags & HIVEMIND)
				add_verb(src, /mob/proc/adjust_hive_range)
		temp_languages |= langlist
		languages |= langlist

//Welcome to the adapted borer code.
/mob/proc/dominate_predator()
	set category = "Abilities.Vore"
	set name = "Dominate Predator"
	set desc = "Connect to and dominate the brain of your predator."
	var/is_mob = FALSE // - tracks if character is a non player mob TODO: Add

	var/mob/living/pred
	var/mob/living/prey = src
	if(isbelly(prey.loc))
		pred = loc.loc
	else if(isliving(prey.loc))
		pred = loc
	else if(ispAI(src))
		var/mob/living/silicon/pai/pocketpal = src
		if(isbelly(pocketpal.card.loc))
			pred = pocketpal.card.loc.loc
	else
		to_chat(prey, span_notice("You are not inside anyone."))
		return

	if(prey.stat == DEAD)
		to_chat(prey, span_warning("You cannot do that in your current state."))
		return

	if(!pred.allow_mind_transfer)
		to_chat(prey, span_warning("[pred] is unable to be dominated."))
		return

	if(isrobot(pred) && jobban_isbanned(prey, JOB_CYBORG))
		to_chat(prey, span_warning("Forces beyond your comprehension forbid you from taking control of [pred]."))
		return
	if(prey.prey_controlled)
		to_chat(prey, span_warning("You are already controlling someone, you can't control anyone else at this time."))
		return
	if(pred.prey_controlled)
		to_chat(prey, span_warning("\The [pred] is already dominated, and cannot be controlled at this time."))
		return
	if(tgui_alert(prey, "You are attempting to take over [pred], are you sure? Ensure that their preferences align with this kind of play.", "Take Over Predator",list("No","Yes")) != "Yes")
		return
	to_chat(prey, span_notice("You attempt to exert your control over \the [pred]..."))
	log_admin("[key_name_admin(prey)] attempted to take over [pred].")

	if(pred.ckey) //check if body is assigned to another player currently
		if(tgui_alert(pred, "\The [prey] has elected to attempt to take control of you. Is this something you will allow to happen?", "Allow Prey Domination",list("No","Yes")) != "Yes")
			to_chat(prey, span_warning("\The [pred] declined your request for control."))
			return
		if(tgui_alert(pred, "Are you sure? If you should decide to revoke this, you will have the ability to do so in your 'Abilities' tab.", "Allow Prey Domination",list("No","Yes")) != "Yes")
			return
	else if(!pred.client && ("original_player" in pred.vars)) //check if the body belonged to a player and give proper log about it while preparing it
		log_and_message_admins("[key_name_admin(prey)] is taking control over [pred] while they are out of their body.")
		pred.ckey="DOMPLY[rand(100000,999999)]"
		is_mob = TRUE
	else //at this point we end up with a mob
		pred.ckey = "DOMMOB[rand(100000,999999)]" //this is cursed, but it does work and is cleaned up after
		is_mob = TRUE

	to_chat(pred, span_warning("You can feel the will of another overwriting your own, control of your body being sapped away from you..."))
	to_chat(prey, span_warning("You can feel the will of your host diminishing as you exert your will over them!"))
	if(!do_after(prey, 10 SECONDS, exclusive = TRUE))
		to_chat(prey, span_notice("Your attempt to regain control has been interrupted..."))
		to_chat(pred, span_notice("The dominant sensation fades away..."))
		return

	to_chat(prey, span_danger("You plunge your conciousness into \the [pred], assuming control over their very body, leaving your own behind within \the [pred]'s [loc]."))
	to_chat(pred, span_danger("You feel your body move on its own, as you are pushed to the background, and an alien consciousness displaces yours."))
	var/mob/living/dominated_brain/pred_brain
	var/delete_source = FALSE
	if(istype(prey, /mob/living/dominated_brain))
		var/mob/living/dominated_brain/punished_prey = prey
		if(punished_prey.prey_body)
			pred_brain = new /mob/living/dominated_brain(pred, pred, name, punished_prey.prey_body)
		else
			pred_brain = new /mob/living/dominated_brain(pred, pred, name)	//We have to play musical chairs with 3 bodies, or everyone gets d/ced
		delete_source = TRUE
	else
		pred_brain = new /mob/living/dominated_brain(pred, pred, name, prey)

	pred_brain.prey_ooc_notes = prey.ooc_notes
	pred_brain.prey_ooc_likes = prey.ooc_notes_likes
	pred_brain.prey_ooc_dislikes = prey.ooc_notes_dislikes
	pred_brain.prey_ooc_favs = prey.ooc_notes_favs
	pred_brain.prey_ooc_maybes = prey.ooc_notes_maybes
	pred_brain.prey_ooc_style = prey.ooc_notes_style
	pred_brain.pred_ooc_favs = pred.ooc_notes_favs
	pred_brain.pred_ooc_maybes = pred.ooc_notes_maybes
	pred_brain.pred_ooc_style = pred.ooc_notes_style
	pred_brain.pred_ooc_notes = pred.ooc_notes
	pred_brain.pred_ooc_likes = pred.ooc_notes_likes
	pred_brain.pred_ooc_dislikes = pred.ooc_notes_dislikes

	pred_brain.name = pred.name
	var/list/preylangs = list()
	preylangs |= prey.languages
	preylangs -= prey.temp_languages
	pred_brain.prey_langs |= preylangs
	pred_brain.prey_ckey = prey.ckey
	pred_brain.pred_ckey = pred.ckey
	pred_brain.pred_body.absorb_langs()
	pred.ooc_notes = pred_brain.prey_ooc_notes
	pred.ooc_notes_likes = pred_brain.prey_ooc_likes
	pred.ooc_notes_dislikes = pred_brain.prey_ooc_dislikes
	pred.ooc_notes_favs = pred_brain.prey_ooc_favs
	pred.ooc_notes_maybes = pred_brain.prey_ooc_maybes
	pred.ooc_notes_style = pred_brain.prey_ooc_style

	add_verb(pred, /mob/proc/release_predator)

	//Now actually put the people in the mobs
	pred_brain.ckey = pred_brain.pred_ckey
	pred_brain.real_name = pred.real_name
	pred.ckey = pred_brain.prey_ckey
	pred.prey_controlled = TRUE
	log_and_message_admins("is now controlled by [pred.ckey], they were taken over via prey domination, and were originally controlled by [pred_brain.pred_ckey].", pred)
	if(delete_source)
		qdel(prey)

	if(is_mob == 1)
		pred_brain.was_mob = TRUE

/mob/proc/release_predator()
	set category = "Abilities.Vore"
	set name = "Restore Control"
	set desc = "Release control of your predator's body."

	for(var/I in contents)
		if(istype(I, /mob/living/dominated_brain))
			var/mob/living/dominated_brain/db = I
			if(db.ckey == db.pred_ckey)
				to_chat(src, span_notice("You ease off of your control, releasing \the [db]."))
				to_chat(db, span_notice("You feel the alien presence fade, and restore control of your body to you of their own will..."))
				if(db.was_mob)
					db.pred_ckey = null
					db.ckey = null
					db.restore_control()
				else
					db.restore_control()
				return
			else
				continue
	to_chat(src, span_danger("You haven't been taken over, and shouldn't have this verb. I'll clean that up for you. Report this on the github, it is a bug."))
	remove_verb(src, /mob/proc/release_predator)

/mob/living/dominated_brain/proc/resist_control()
	set category = "Abilities.Vore"
	set name = "Resist Control"
	set desc = "Attempt to resist control."
	if(pred_body.ckey == pred_ckey)
		dominate_predator()
		return
	if(pred_ckey == ckey && pred_body.prey_controlled)
		to_chat(src, span_danger("You begin to resist \the [prey_name]'s control!!!"))
		to_chat(pred_body, span_danger("You feel the captive mind of [src] begin to resist your control."))

		if(do_after(src, 10 SECONDS, exclusive = TRUE))
			restore_control()
		else
			to_chat(src, span_notice("Your attempt to regain control has been interrupted..."))
			to_chat(pred_body, span_notice("The dominant sensation fades away..."))
	else
		to_chat(src, span_warning("\The [pred_body] is already dominated, and cannot be controlled at this time."))

/mob/living/proc/dominate_prey()
	set category = "Abilities.Vore"
	set name = "Dominate Prey"
	set desc = "Connect to and dominate the brain of your prey."

	var/list/possible_mobs = list()
	for(var/obj/belly/B in src.vore_organs)
		for(var/mob/living/L in B)
			if(isliving(L) && L.ckey && L.allow_mind_transfer)
				possible_mobs |= L
			else
				continue
	var/obj/item/grab/G = src.get_active_hand()
	if(istype(G))
		var/mob/living/L = G.affecting
		if(istype(L) && L.allow_mind_transfer)
			if(G.state != GRAB_NECK)
				possible_mobs |= "~~[L.name]~~ (reinforce grab first)"
			else
				possible_mobs |= L
	if(!possible_mobs)
		to_chat(src, span_warning("There are no valid targets inside of you."))
		return
	var/input = tgui_input_list(src, "Select a mob to dominate:", "Dominate Prey", possible_mobs)
	if(!input)
		return
	var/mob/living/M = input
	if(!istype(M))
		to_chat(src, span_warning("You must have a tighter grip to dominate this creature."))
		return
	if(!M.allow_mind_transfer) //check if the dominated mob pref is enabled
		to_chat(src, span_warning("[M] is unable to be dominated."))
		return
	if(tgui_alert(src, "You selected [M] to attempt to dominate. Are you sure?", "Dominate Prey",list("No","Yes")) != "Yes")
		return
	log_admin("[key_name_admin(src)] offered to use dominate prey on [M] ([M.ckey]).")
	to_chat(src, span_warning("Attempting to dominate and gather \the [M]'s mind..."))
	if(tgui_alert(M, "\The [src] has elected collect your mind into their own. Is this something you will allow to happen?", "Allow Dominate Prey",list("No","Yes")) != "Yes")
		to_chat(src, span_warning("\The [M] has declined your Dominate Prey attempt."))
		return
	if(tgui_alert(M, "Are you sure? You can only undo this while your body is inside of [src]. (You can resist, or use the resist verb in the abilities tab)", "Allow Dominate Prey",list("No","Yes")) != "Yes")
		to_chat(src, span_warning("\The [M] has declined your Dominate Prey attempt."))
		return
	to_chat(M, span_warning("You can feel the will of another pulling you away from your body..."))
	to_chat(src, span_warning("You can feel the will of your prey diminishing as you gather them!"))

	if(istype(G) && M == G.affecting)
		src.visible_message(span_danger("[src] seems to be doing something to [M], resulting in [M]'s body looking increasingly drowsy with every passing moment!"))
	if(!do_after(src, 10 SECONDS, exclusive = TRUE))
		to_chat(M, span_notice("The alien presence fades, and you are left along in your body..."))
		to_chat(src, span_notice("Your attempt to gather [M]'s mind has been interrupted."))
		return
	if(!isbelly(M.loc) && !(istype(G) && M == G.affecting && G.state == GRAB_NECK)) // Let dominate prey work on grabbed people
		to_chat(M, span_notice("The alien presence fades, and you are left along in your body..."))
		to_chat(src, span_notice("Your attempt to gather [M]'s mind has been interrupted."))
		return

	var/mob/living/dominated_brain/db = new /mob/living/dominated_brain(src, src, M.name, M)


	db.name = M.name
	db.prey_ckey = M.ckey
	db.pred_ckey = src.ckey


	db.real_name = M.real_name

	M.languages -= M.temp_languages
	db.languages |= M.languages
	db.ooc_notes = M.ooc_notes
	db.ooc_notes_likes = M.ooc_notes_likes
	db.ooc_notes_dislikes = M.ooc_notes_dislikes
	db.ooc_notes_favs = M.ooc_notes_favs
	db.ooc_notes_maybes = M.ooc_notes_maybes
	db.ooc_notes_style = M.ooc_notes_style
	db.prey_ooc_favs = M.ooc_notes_favs
	db.prey_ooc_maybes = M.ooc_notes_maybes
	db.prey_ooc_style = M.ooc_notes_style
	db.prey_ooc_likes = M.ooc_notes_likes
	db.prey_ooc_dislikes = M.ooc_notes_dislikes
	add_verb(db, /mob/living/dominated_brain/proc/cease_this_foolishness)

	absorb_langs()

	db.ckey = db.prey_ckey
	log_admin("[db] ([db.ckey]) has agreed to [src]'s dominate prey attempt, and so no longer occupies their original body.")
	to_chat(src, span_notice("You feel your mind expanded as [M] is incorporated into you."))
	to_chat(M, span_warning("Your mind is gathered into \the [src], becoming part of them..."))
	if(istype(G) && M == G.affecting)
		visible_message(span_danger("[src] seems to finish whatever they were doing to [M]."))

/mob/living/dominated_brain/proc/cease_this_foolishness()
	set category = "Abilities.Vore"
	set name = "Return to Body"
	set desc = "If your body is inside of your predator still, attempts to re-insert yourself into it."

	if(prey_body && prey_body.loc.loc == pred_body)
		to_chat(src, span_notice("You exert your will and attempt to return to yout body!!!"))
		to_chat(pred_body, span_warning("\The [src] resists your hold and attempts to return to their body!"))
		if(do_after(src, 10 SECONDS, exclusive = TRUE))
			if(prey_body && prey_body.loc.loc == pred_body)

				prey_body.ckey = prey_ckey
				pred_body.absorb_langs()
				to_chat(src, span_warning("Your connection to [pred_body] fades, and you awaken back in your own body!"))
				to_chat(pred_body, span_warning("You feel as though a piece of yourself is missing, as \the [src] returns to their body."))
				log_admin("[src] ([src.ckey]) has returned to their body, [prey_body].")
				qdel(src)
			else
				to_chat(src, span_warning("Your attempt to regain your body has been interrupted..."))
		else
			to_chat(src, span_warning("Your attempt to regain your body has been interrupted..."))
	else if(prey_body)
		to_chat(src, span_warning("You can sense your body... but it is not contained within [pred_body]... You cannot return to it at this time."))
	else
		to_chat(src, span_warning("Your body seems to no longer exist, so, you cannot return to it."))
		remove_verb(src, /mob/living/dominated_brain/proc/cease_this_foolishness)

/mob/living/proc/lend_prey_control()
	set category = "Abilities.Vore"
	set name = "Give Prey Control"
	set desc = "Allow prey control of your body."

	var/list/possible_mobs = list()
	for(var/obj/belly/B in src.vore_organs)
		for(var/mob/living/L in B)
			if(isliving(L) && L.ckey)
				possible_mobs |= L
			else
				continue
	if(!possible_mobs)
		to_chat(src, span_warning("There are no valid targets inside of you."))
		return
	var/input = tgui_input_list(src, "Select a mob to give control:", "Give Prey Control", possible_mobs)
	if(!input)
		return
	var/mob/living/prey = input
	var/mob/living/pred = src

	if(prey.stat == DEAD)
		to_chat(pred, span_warning("You cannot do that to this prey."))
		return

	if(!prey.ckey)
		to_chat(pred, span_notice("\The [prey] cannot take control."))
		return
	if(isrobot(pred) && jobban_isbanned(prey, JOB_CYBORG))
		to_chat(pred, span_warning("Forces beyond your comprehension prevent you from giving [prey] control."))
		return
	if(prey.prey_controlled)
		to_chat(pred, span_warning("\The [prey] is already under someone's control and cannot be given control of your body."))
		return
	if(pred.prey_controlled)
		to_chat(pred, span_warning("You are already controlling someone's body."))
		return
	if(tgui_alert(pred, "You are attempting to give [prey] control over you, are you sure? Ensure that their preferences align with this kind of play.", "Give Prey Control",list("No","Yes")) != "Yes")
		return
	to_chat(pred, span_notice("You attempt to give your control over to \the [prey]..."))
	log_admin("[key_name_admin(pred)] attempted to give control to [prey].")
	if(tgui_alert(prey, "\The [pred] has elected to attempt to give you control of them. Is this something you will allow to happen?", "Allow Prey Domination",list("No","Yes")) != "Yes")
		to_chat(pred, span_warning("\The [prey] declined your request for control."))
		return
	if(tgui_alert(prey, "Are you sure? If you should decide to revoke this, you will have the ability to do so in your 'Abilities' tab.", "Allow Prey Domination",list("No","Yes")) != "Yes")
		return
	to_chat(pred, span_warning("You diminish your will, reducing it and allowing will of your prey to take over..."))
	to_chat(prey, span_warning("You can feel the will of your host diminishing as you are given control over them!"))
	if(!do_after(pred, 10 SECONDS, exclusive = TRUE))
		to_chat(pred, span_notice("Your attempt to share control has been interrupted..."))
		to_chat(prey, span_notice("The dominant sensation fades away..."))
		return

	to_chat(prey, span_danger("You plunge your conciousness into \the [pred], assuming control over their very body, leaving your own behind within \the [pred]'s [loc]."))
	to_chat(pred, span_danger("You feel your body move on its own, as you move to the background, and an alien consciousness displaces yours."))
	var/mob/living/dominated_brain/pred_brain
	var/delete_source = FALSE
	if(istype(prey, /mob/living/dominated_brain))
		var/mob/living/dominated_brain/punished_prey = prey
		if(punished_prey.prey_body)
			pred_brain = new /mob/living/dominated_brain(pred, pred, name, punished_prey.prey_body)
		else
			pred_brain = new /mob/living/dominated_brain(pred, pred, name)	//We have to play musical chairs with 3 bodies, or everyone gets d/ced
		delete_source = TRUE
	else
		pred_brain = new /mob/living/dominated_brain(pred, pred, name, prey)

	pred_brain.prey_ooc_notes = prey.ooc_notes
	pred_brain.prey_ooc_likes = prey.ooc_notes_likes
	pred_brain.prey_ooc_dislikes = prey.ooc_notes_dislikes
	pred_brain.prey_ooc_favs = prey.ooc_notes_favs
	pred_brain.prey_ooc_maybes = prey.ooc_notes_maybes
	pred_brain.prey_ooc_style = prey.ooc_notes_style
	pred_brain.pred_ooc_favs = pred.ooc_notes_favs
	pred_brain.pred_ooc_maybes = pred.ooc_notes_maybes
	pred_brain.pred_ooc_style = pred.ooc_notes_style
	pred_brain.pred_ooc_notes = pred.ooc_notes
	pred_brain.pred_ooc_likes = pred.ooc_notes_likes
	pred_brain.pred_ooc_dislikes = pred.ooc_notes_dislikes
	pred_brain.name = pred.name
	var/list/preylangs = list()
	preylangs |= prey.languages
	preylangs -= prey.temp_languages
	pred_brain.prey_langs |= preylangs
	pred_brain.prey_ckey = prey.ckey
	pred_brain.pred_ckey = pred.ckey
	pred_brain.pred_body.absorb_langs()
	pred.ooc_notes = pred_brain.prey_ooc_notes
	pred.ooc_notes_likes = pred_brain.prey_ooc_likes
	pred.ooc_notes_dislikes = pred_brain.prey_ooc_dislikes
	pred.ooc_notes_favs = pred_brain.prey_ooc_favs
	pred.ooc_notes_maybes = pred_brain.prey_ooc_maybes
	pred.ooc_notes_style = pred_brain.prey_ooc_style

	add_verb(pred, /mob/proc/release_predator)

	//Now actually put the people in the mobs
	pred_brain.ckey = pred_brain.pred_ckey
	pred_brain.real_name = pred.real_name
	pred.ckey = pred_brain.prey_ckey
	pred.prey_controlled = TRUE
	log_and_message_admins("is now controlled by [pred.ckey], they were taken over via pred submission, and were originally controlled by [pred_brain.pred_ckey].", pred)
	if(delete_source)
		qdel(prey)
