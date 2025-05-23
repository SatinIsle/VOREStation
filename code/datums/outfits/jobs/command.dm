/decl/hierarchy/outfit/job/captain
	name = OUTFIT_JOB_NAME(JOB_ALT_CAPTAIN) // Keep Captain for now, not JOB_SITE_MANAGER
	glasses = /obj/item/clothing/glasses/sunglasses
	uniform = /obj/item/clothing/under/rank/captain

	shoes = /obj/item/clothing/shoes/brown
	backpack = /obj/item/storage/backpack/captain
	satchel_one = /obj/item/storage/backpack/satchel/cap
	messenger_bag = /obj/item/storage/backpack/messenger/com
	id_type = /obj/item/card/id/gold
	pda_type = /obj/item/pda/captain

	headset = /obj/item/radio/headset/heads/captain
	headset_alt = /obj/item/radio/headset/alt/heads/captain
	headset_earbud = /obj/item/radio/headset/earbud/heads/captain

/decl/hierarchy/outfit/job/captain/post_equip(var/mob/living/carbon/human/H)
	..()
	if(H.age>49)
		// Since we can have something other than the default uniform at this
		// point, check if we can actually attach the medal
		var/obj/item/clothing/uniform = H.w_uniform
		if(uniform)
			var/obj/item/clothing/accessory/medal/gold/captain/medal = new()
			if(uniform.can_attach_accessory(medal))
				uniform.attach_accessory(null, medal)
			else
				qdel(medal)

/decl/hierarchy/outfit/job/hop
	name = OUTFIT_JOB_NAME(JOB_HEAD_OF_PERSONNEL)
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/brown
	id_type = /obj/item/card/id/silver/hop
	pda_type = /obj/item/pda/heads/hop

	headset = /obj/item/radio/headset/heads/hop
	headset_alt = /obj/item/radio/headset/alt/heads/hop
	headset_earbud = /obj/item/radio/headset/earbud/heads/hop

/decl/hierarchy/outfit/job/secretary
	name = OUTFIT_JOB_NAME(JOB_COMMAND_SECRETARY)
	shoes = /obj/item/clothing/shoes/brown
	id_type = /obj/item/card/id/silver/secretary
	pda_type = /obj/item/pda/heads
	r_hand = /obj/item/clipboard

	headset = /obj/item/radio/headset/headset_com
	headset_alt = /obj/item/radio/headset/alt/headset_com
	headset_earbud = /obj/item/radio/headset/earbud/headset_com

/decl/hierarchy/outfit/job/secretary/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/suit_jacket/female/skirt
	else
		uniform = /obj/item/clothing/under/suit_jacket/charcoal
