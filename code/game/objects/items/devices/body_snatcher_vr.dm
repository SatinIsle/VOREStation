//Body snatcher. Based off the sleevemate, but instead of storing a mind it lets you swap your mind with someone. Extremely illegal and being caught with one s
/obj/item/bodysnatcher
	name = "\improper Body Snatcher Device"
	desc = "An extremely illegal tool that allows the user to swap minds with the selected humanoid victim. The LED panel on the side states 'Place both heads on the device, pull trigger, then wait for the transfer to complete.'"
	icon = 'icons/obj/device_alt.dmi'
	icon_state = "sleevemate" //Give this a fancier sprite later.
	item_state = "healthanalyzer"
	slot_flags = SLOT_BELT
	w_class = ITEMSIZE_SMALL
	matter = list(MAT_STEEL = 200)
	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2, TECH_ILLEGAL = 1)
	pickup_sound = 'sound/items/pickup/device.ogg'
	drop_sound = 'sound/items/drop/device.ogg'
	flags = NOBLUDGEON

/obj/item/bodysnatcher/attack(mob/living/M, mob/living/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(ishuman(M) || issilicon(M)) //Allows body swapping with humans, synths, and pAI's/borgs since they all have a mind.
		if(user == M)
			to_chat(user,span_warning(" A message pops up on the LED display, informing you that you that the mind transfer to yourself was successful... Wait, did that even do anything?"))
			return

		if(!M.mind) //Do they have a mind?
			to_chat(user,span_warning("A warning pops up on the device, informing you that [M] appears braindead."))
			return

		if(!M.allow_mind_transfer)
			to_chat(user,span_danger("The target's mind is too complex to be affected!"))
			return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.resleeve_lock && user.ckey != H.resleeve_lock)
				to_chat(src, span_danger("[H] cannot be impersonated!"))
				return

		if(M.stat == DEAD) //Are they dead?
			to_chat(user,span_warning("A warning pops up on the device, informing you that [M] is dead, and, as such, the mind transfer can not be done."))
			return

		var/choice = tgui_alert(user,"This will swap your mind with the target's mind. This will result in them controlling your body, and you controlling their body. Continue?","Confirmation",list("Continue","Cancel"))
		if(choice == "Continue" && user.get_active_hand() == src && user.Adjacent(M))
			if(M.ckey && !M.client)
				log_and_message_admins("attempted to body swap with [key_name(M)] while they were SSD!")
			else
				log_and_message_admins("attempted to body swap with [key_name(M)].")
			user.visible_message(span_warning("[user] pushes the device up their forehead and [M]'s head, the device beginning to let out a series of light beeps!"),span_notice("You begin swap minds with [M]!"))
			if(do_after(user,35 SECONDS,M))
				if(user.mind && M.mind && M.stat != DEAD && user.stat != DEAD)
					log_and_message_admins("[user.ckey] used a Bodysnatcher to swap bodies with [M.ckey]", user)
					to_chat(user,span_notice("Your minds have been swapped! Have a nice day."))
					var/datum/mind/user_mind = user.mind
					var/datum/mind/prey_mind = M.mind
					var/target_ooc_notes = M.ooc_notes
					var/target_likes = M.ooc_notes_likes
					var/target_dislikes = M.ooc_notes_dislikes
					var/target_favs = M.ooc_notes_favs
					var/target_maybes = M.ooc_notes_maybes
					var/target_style = M.ooc_notes_style
					var/user_favs = user.ooc_notes_favs
					var/user_maybes = user.ooc_notes_maybes
					var/user_style = user.ooc_notes_style
					var/user_ooc_notes = user.ooc_notes
					var/user_likes = user.ooc_notes_likes
					var/user_dislikes = user.ooc_notes_dislikes
					M.ghostize()
					user.ghostize()
					user.mind = null
					M.mind = null
					user_mind.current = null
					prey_mind.current = null
					user_mind.active = TRUE //If they are 'active', their client is automatically pushed to the mob
					user_mind.transfer_to(M) //This works. Transfers mind & Ckey.
					prey_mind.active = TRUE
					prey_mind.transfer_to(user)
					M.ooc_notes = user_ooc_notes //Let's keep their OOC notes over to their new body.
					M.ooc_notes_likes = user_likes
					M.ooc_notes_dislikes = user_dislikes
					M.ooc_notes_favs = user_favs
					M.ooc_notes_maybes = user_maybes
					M.ooc_notes_style = user_style
					user.ooc_notes_favs = target_favs
					user.ooc_notes_maybes = target_maybes
					user.ooc_notes_style = target_style
					if(M.tf_mob_holder == user)
						M.tf_mob_holder = null
					else
						M.tf_mob_holder = user
					if(user.tf_mob_holder == M)
						user.tf_mob_holder = null
					else
						user.tf_mob_holder = M
					user.ooc_notes = target_ooc_notes
					user.ooc_notes_likes = target_likes
					user.ooc_notes_dislikes = target_dislikes
					user.sleeping = 10 //Device knocks out both the user and the target.
					user.eye_blurry = 30 //Blurry vision while they both get used to their new body's vision
					user.slurring = 50 //And let's also have them slurring while they attempt to get used to using their new body.
					if(ishuman(M)) //Let's not have the AI slurring, even though its downright hilarious.
						M.sleeping = 10
						M.eye_blurry = 30
						M.slurring = 50

	else
		to_chat(user,span_warning(" A warning pops up on the LED display on the side of the device, informing you that the target is not able to have their mind swapped with!"))

/obj/item/bodysnatcher/attack_self(mob/living/user)
		to_chat(user,span_warning(" A message pops up on the LED display, informing you that you that the mind transfer to yourself was successful... Wait, did that even do anything?"))
		return
