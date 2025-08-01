/mob/living/silicon/pai/Life()

	if(src.cable)
		if(get_dist(src, src.cable) > 1)
			var/turf/T = get_turf_or_move(src.loc)
			for (var/mob/M in viewers(T))
				M.show_message(span_red("The data cable rapidly retracts back into its spool."), 3, span_red("You hear a click and the sound of wire spooling rapidly."), 2)
			playsound(src, 'sound/machines/click.ogg', 50, 1)

			qdel(src.cable)
			src.cable = null

	if (src.stat == DEAD)
		return

	if(card.cell != PP_FUNCTIONAL|| card.processor != PP_FUNCTIONAL || card.board != PP_FUNCTIONAL || card.capacitor != PP_FUNCTIONAL)
		death()

	if(card.projector != PP_FUNCTIONAL && card.emitter != PP_FUNCTIONAL)
		if(loc != card)
			close_up()
			to_chat(src, span_warning("ERROR: System malfunction. Service required!"))
	else if(card.projector  != PP_FUNCTIONAL|| card.emitter != PP_FUNCTIONAL)
		if(prob(5))
			close_up()
			to_chat(src, span_warning("ERROR: System malfunction. Service recommended!"))

	handle_regular_hud_updates()
	handle_vision()

	if(silence_time)
		if(world.timeofday >= silence_time)
			silence_time = null
			to_chat(src, span_green("Communication circuit reinitialized. Speech and messaging functionality restored."))

	handle_statuses()
	handle_sleeping()

	if(health <= 0)
		card.death_damage()
		death(null,"fizzles out and clatters to the floor...")
	else if(health < maxHealth && istype(src.loc , /obj/item/paicard))
		adjustBruteLoss(-0.5)
		adjustFireLoss(-0.5)

/mob/living/silicon/pai/updatehealth()
	if(SEND_SIGNAL(src, COMSIG_UPDATE_HEALTH) & COMSIG_UPDATE_HEALTH_GOD_MODE)
		health = getMaxHealth()
		set_stat(CONSCIOUS)
	else
		health = getMaxHealth() - getBruteLoss() - getFireLoss()
		if(health <= -getMaxHealth()) //die only once
			death()
			return
