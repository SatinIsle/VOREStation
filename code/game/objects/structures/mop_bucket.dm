/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	w_class = ITEMSIZE_NORMAL
	pressure_resistance = 5
	flags = OPENCONTAINER
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

GLOBAL_LIST_BOILERPLATE(all_mopbuckets, /obj/structure/mopbucket)

/obj/structure/mopbucket/Initialize(mapload, ...)
	create_reagents(300)
	. = ..()
	AddElement(/datum/element/climbable)

/obj/structure/mopbucket/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += "It contains [reagents.total_volume] unit\s of water!"

/obj/structure/mopbucket/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap) || istype(I, /obj/item/reagent_containers/glass/rag)) //VOREStation Edit - "Allows soap and rags to be used on mopbuckets"
		if(reagents.total_volume < 1)
			to_chat(user, span_warning("\The [src] is out of water!"))
		else
			reagents.trans_to_obj(I, 5)
			to_chat(user, span_notice("You wet \the [I] in \the [src]."))
			playsound(src, 'sound/effects/slosh.ogg', 25, 1)
