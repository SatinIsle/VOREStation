/mob/living/silicon/robot/updatehealth()
	if(SEND_SIGNAL(src, COMSIG_UPDATE_HEALTH) & COMSIG_UPDATE_HEALTH_GOD_MODE)
		health = getMaxHealth()
		set_stat(CONSCIOUS)
		return
	health = getMaxHealth() - (getBruteLoss() + getFireLoss())
	if(health <= -getMaxHealth()) //die only once
		death()
		return
	return

/mob/living/silicon/robot/getMaxHealth()
	. = ..()
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		. += C.max_damage - initial(C.max_damage)

/mob/living/silicon/robot/getBruteLoss()
	var/amount = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed != 0) amount += C.brute_damage
	return amount

/mob/living/silicon/robot/getFireLoss()
	var/amount = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed != 0) amount += C.electronics_damage
	return amount

/mob/living/silicon/robot/adjustBruteLoss(var/amount,var/include_robo)
	if(amount > 0)
		take_overall_damage(amount, 0)
	else
		heal_overall_damage(-amount, 0)

/mob/living/silicon/robot/adjustFireLoss(var/amount,var/include_robo)
	if(amount > 0)
		take_overall_damage(0, amount)
	else
		heal_overall_damage(0, -amount)

/mob/living/silicon/robot/proc/get_damaged_components(var/brute, var/burn, var/destroyed = 0)
	var/list/datum/robot_component/parts = list()
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed == 1 || (C.installed == -1 && destroyed))
			if((brute && C.brute_damage) || (burn && C.electronics_damage) || (!C.toggled) || (!C.powered && C.toggled))
				parts += C
	return parts

/mob/living/silicon/robot/proc/get_damageable_components()
	var/list/rval = list()
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed == 1) rval += C
	return rval

/mob/living/silicon/robot/proc/get_armour()

	if(!components.len) return 0
	var/datum/robot_component/C = components["armour"]
	if(C && C.installed == 1)
		return C
	return 0

/mob/living/silicon/robot/heal_organ_damage(var/brute, var/burn)
	var/list/datum/robot_component/parts = get_damaged_components(brute,burn)
	if(!parts.len)	return
	var/datum/robot_component/picked = pick(parts)
	picked.heal_damage(brute,burn)

/mob/living/silicon/robot/take_organ_damage(var/brute = 0, var/burn = 0, var/sharp = FALSE, var/edge = FALSE, var/emp = 0)
	var/list/components = get_damageable_components()
	if(!components.len)
		return

	//Combat shielding absorbs a percentage of damage directly into the cell.
	if(has_active_type(/obj/item/borg/combat/shield))
		var/obj/item/borg/combat/shield/shield = locate() in src
		if(shield && shield.active)
			//Shields absorb a certain percentage of damage based on their power setting.
			var/absorb_brute = brute*shield.shield_level
			var/absorb_burn = burn*shield.shield_level
			var/cost = (absorb_brute+absorb_burn) * 25

			if(!use_direct_power(cost, 200))
				to_chat(src, span_filter_warning("[span_red("Your shield has overloaded!")]"))
			else
				brute -= absorb_brute
				burn -= absorb_burn
				to_chat(src, span_filter_combat("[span_red("Your shield absorbs some of the impact!")]"))

	if(!emp)
		var/datum/robot_component/armour/A = get_armour()
		if(A)
			A.take_damage(brute,burn,sharp,edge)
			return

	var/datum/robot_component/C = pick(components)
	C.take_damage(brute,burn,sharp,edge)

/mob/living/silicon/robot/heal_overall_damage(var/brute, var/burn)
	var/list/datum/robot_component/parts = get_damaged_components(brute,burn)

	while(parts.len && (brute>0 || burn>0) )
		var/datum/robot_component/picked = pick(parts)

		var/brute_was = picked.brute_damage
		var/burn_was = picked.electronics_damage

		picked.heal_damage(brute,burn)

		brute -= (brute_was-picked.brute_damage)
		burn -= (burn_was-picked.electronics_damage)

		parts -= picked

/mob/living/silicon/robot/take_overall_damage(var/brute = 0, var/burn = 0, var/sharp = FALSE, var/used_weapon = null)
	if(SEND_SIGNAL(src, COMSIG_CHECK_FOR_GODMODE) & COMSIG_GODMODE_CANCEL) //Normally we'd let this proc continue on, but it's much less time consumptive to just do a godmode check here.
		return 0	// Cancelled by a component
	var/list/datum/robot_component/parts = get_damageable_components()

	//Combat shielding absorbs a percentage of damage directly into the cell.
	if(has_active_type(/obj/item/borg/combat/shield))
		var/obj/item/borg/combat/shield/shield = locate() in src
		if(shield)
			//Shields absorb a certain percentage of damage based on their power setting.
			var/absorb_brute = brute*shield.shield_level
			var/absorb_burn = burn*shield.shield_level
			var/cost = (absorb_brute+absorb_burn) * 25

			if(!use_direct_power(cost, 200))
				to_chat(src, span_filter_warning("[span_red("Your shield has overloaded!")]"))
			else
				brute -= absorb_brute
				burn -= absorb_burn
				to_chat(src, span_filter_combat("[span_red("Your shield absorbs some of the impact!")]"))

	var/datum/robot_component/armour/A = get_armour()
	if(A)
		A.take_damage(brute,burn,sharp)
		return

	while(parts.len && (brute>0 || burn>0) )
		var/datum/robot_component/picked = pick(parts)

		var/brute_was = picked.brute_damage
		var/burn_was = picked.electronics_damage

		picked.take_damage(brute,burn)

		brute	-= (picked.brute_damage - brute_was)
		burn	-= (picked.electronics_damage - burn_was)

		parts -= picked

/mob/living/silicon/robot/emp_act(severity)
	if(SEND_SIGNAL(src, COMSIG_ROBOT_EMP_ACT, severity) & COMPONENT_BLOCK_EMP)
		return // Cancelled by a component
	uneq_all()
	..() //Damage is handled at /silicon/ level.
