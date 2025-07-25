/obj/item
	var/list/possessed_voice //Allows for items to be possessed/inhabited by voices.
	var/list/warned_of_possession //Checks to see who has been informed this item is possessed.


/obj/item/proc/inhabit_item(var/mob/candidate, var/candidate_name, var/mob/living/candidate_original_form, var/is_item_tf = FALSE)
	//This makes it so that any object in the game can have something put in it like the cursed sword!
	//This means the proc can also be manually called by admin commands.
	//Handle moving the person into the object.
	if(!possessed_voice) //Create the list for possessed_voice if it doesn't already have one.
		possessed_voice = list()
	if(!warned_of_possession) //Creates a list of warned users.
		warned_of_possession = list()
	var/mob/living/voice/new_voice = new /mob/living/voice(src) 	//Make the voice mob the person is going to be.
	new_voice.transfer_identity(candidate) 			//Now make the voice mob load from the ghost's active character in preferences.
	new_voice.mind = candidate.mind					//Transfer the mind, if any.
	new_voice.ckey = candidate.ckey					//Finally, bring the client over.
	new_voice.tf_mob_holder = candidate_original_form //Save what mob they are! We'll need this for OOC escape and transformation back to their normal form.
	if(candidate_name) 								//Were we given a candidate_name? Great! Name them that.
		new_voice.name = "[candidate_name]"
	else
		new_voice.name = "[name]" 					//No name given? Give them the name of the object they're inhabiting.
	new_voice.real_name = "[new_voice.real_name]" 	//We still know their real name though!
	possessed_voice.Add(new_voice)
	GLOB.listening_objects |= src
	remove_verb(new_voice, /mob/living/voice/verb/change_name) //No changing your name! Bad!
	remove_verb(new_voice, /mob/living/voice/verb/hang_up) //Also you can't hang up. You are the item!
	src.item_tf_spawnpoint_used()
	// Let the inhabitor know what happened to them
	if(!istype(src, /obj/item/communicator) && is_item_tf)
		new_voice.item_tf = is_item_tf 					// allows items to use /me
		new_voice.emote_type = 1
		to_chat(new_voice,span_notice("You have become [src]!"))

/obj/item/proc/muffled_by_belly(var/mob/user)
	if(isbelly(user.loc))
		var/obj/belly/B = user.loc
		if(B.mode_flags & DM_FLAG_MUFFLEITEMS)
			return TRUE
	return FALSE
