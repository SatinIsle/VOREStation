/datum/technomancer/spell/asphyxiation
	name = "Asphyxiation"
	desc = "Launches a projectile at a target.  If the projectile hits, a short-lived toxin is created inside what the projectile \
	hits, which inhibits the delivery of oxygen.  The effectiveness of the toxin is heavily dependent on how healthy the target is, \
	with the target taking more damage the more wounded they are.  The effect lasts for twelve seconds."
	cost = 140
	obj_path = /obj/item/spell/insert/asphyxiation

/obj/item/spell/insert/asphyxiation
	name = "asphyxiation"
	desc = "Now you can cause suffication from afar!"
	icon_state = "generic"
	cast_methods = CAST_RANGED
	aspect = ASPECT_BIOMED
	light_color = "#FF5C5C"
	inserting = /obj/item/inserted_spell/asphyxiation

// maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss

/obj/item/inserted_spell/asphyxiation/on_insert()
	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		if(H.isSynthetic() || H.does_not_breathe) // It's hard to choke a robot or something that doesn't breathe.
			on_expire()
			return
		to_chat(H, span_warning("You are having difficulty breathing!"))
		var/pulses = 3
		var/warned_victim = 0
		if(!warned_victim)
			warned_victim = predict_crit(pulses, H, 0)

		looped_insert(3, H, warned_victim)


/obj/item/inserted_spell/mend_wires/looped_insert(remaining_callbacks, mob/living/carbon/human/H, var/warned)
	if(H)
		remaining_callbacks --
		H.adjustOxyLoss(5)
		var/health_lost = H.getMaxHealth() - H.getOxyLoss() + H.getToxLoss() + H.getFireLoss() + H.getBruteLoss() + H.getCloneLoss()
		H.adjustOxyLoss(round(abs(health_lost * 0.25)))

		if(remaining_callbacks > 0)
			if(!warned)
				warned = predict_crit(pulses, H, 0)
			addtimer(CALLBACK(src, PROC_REF(looped_insert), remaining_callbacks, H, warned), 4 SECONDS, TIMER_DELETE_ME)
			return

	on_expire()

/obj/item/inserted_spell/asphyxiation/on_expire()
	..()

// if((getOxyLoss() > (species.total_health/2)) || (health <= get_crit_point())

/obj/item/inserted_spell/asphyxiation/proc/predict_crit(var/pulses_remaining, var/mob/living/carbon/human/victim, var/previous_damage = 0)
	if(pulses_remaining <= 0) // Infinite loop protection
		return 0
	var/health_lost
	var/predicted_damage
	// First, we sum up all the damage we have.
	health_lost = victim.getOxyLoss() + victim.getToxLoss() + victim.getFireLoss() + victim.getBruteLoss() + victim.getCloneLoss()
	// Then add the damage we had done in the last check, if such a number exists, as this is a recursive proc.
	health_lost += previous_damage
	// We inflict 25% of the total health loss as oxy damage.
	predicted_damage = round(abs(health_lost * 0.25))
	// Add our prediction to previous_damage, so we will remember it for the next iteration.
	previous_damage = previous_damage + predicted_damage
	// Now do this again a few more times.
	if(pulses_remaining)
		pulses_remaining--
		return .(pulses_remaining, victim, previous_damage)
	// Now check if our damage predictions are going to cause the victim to go into crit if no healing occurs.
	if(previous_damage + health_lost >= victim.getMaxHealth()) // We're probably going to hardcrit
		to_chat(victim, span_danger(span_large("A feeling of immense dread starts to overcome you as everything starts \
		to fade to black...")))
		//to_world("Predicted hardcrit.")
		return 1
	else if(predicted_damage >= victim.species.total_health / 2) // Or perhaps we're gonna go into 'oxy crit'.
		to_chat(victim, span_danger("You feel really light-headed, and everything seems to be fading..."))
		//to_world("Predicted oxycrit.")
		return 1
	//If we're at this point, the spell is not going to result in critting.
	return 0
