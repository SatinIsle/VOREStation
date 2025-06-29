/datum/disease/appendicitis
	form = "Condition"
	name = "Appendicitis"
	medical_name = "Appendicitis"
	max_stages = 3
	spread_text = "Non-contagious"
	disease_flags = CAN_CARRY|CAN_RESIST|CAN_NOT_POPULATE
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	virus_modifiers = NEEDS_ALL_CURES | BYPASSES_IMMUNITY
	cure_text = "Surgery"
	agent = "Shitty Appendix"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated the subject will become very weak, and may vomit often."
	danger = DISEASE_MINOR
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/internal/appendix)

/datum/disease/appendicitis/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.adjustToxLoss(1)
		if(2)
			var/obj/item/organ/internal/appendix/A = affected_mob.internal_organs_by_name[O_APPENDIX]
			if(A)
				A.inflamed = TRUE
			if(prob(3))
				to_chat(affected_mob, span_warning("You feel a stabbing pain in your abdomen!"))
				affected_mob.automatic_custom_emote(VISIBLE_MESSAGE, "winces painfully.", check_stat = TRUE)
				affected_mob.Stun(rand(4, 6))
				affected_mob.adjustToxLoss(1)
		if(3)
			if(prob(1))
				to_chat(affected_mob, span_danger("Your abdomen is a world of pain!"))
				affected_mob.automatic_custom_emote(VISIBLE_MESSAGE, "winces painfully.", check_stat = TRUE)
				affected_mob.Weaken(10)
			if(prob(1))
				affected_mob.vomit(95)
			if(prob(5))
				to_chat(affected_mob, span_warning("You feel a stabbing pain in your abdomen!"))
				affected_mob.automatic_custom_emote(VISIBLE_MESSAGE, "winces painfully.", check_stat = TRUE)
				affected_mob.Stun(rand(4, 6))
				affected_mob.adjustToxLoss(2)
