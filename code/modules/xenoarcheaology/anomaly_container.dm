/obj/structure/anomaly_container
	name = "anomaly container"
	desc = "Used to safely contain and move anomalies."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anomaly_container"
	density = TRUE

	var/obj/machinery/artifact/contained

/obj/structure/anomaly_container/Initialize(mapload)
	. = ..()

	var/obj/machinery/artifact/A = locate() in loc
	if(A)
		contain(A)

	else
		for(var/obj/Ob in loc)
			if(can_contain(Ob))
				contain(Ob)
				break

/obj/structure/anomaly_container/proc/can_contain(var/obj/O)
	return O.is_anomalous()

/obj/structure/anomaly_container/attack_hand(var/mob/user)
	release()

/obj/structure/anomaly_container/attack_robot(var/mob/user)
	if(Adjacent(user))
		release()

/obj/structure/anomaly_container/proc/contain(var/obj/machinery/artifact/artifact)
	if(contained)
		return
	contained = artifact
	artifact.forceMove(src)
	underlays += image(artifact)
	desc = "Used to safely contain and move anomalies. \The [contained] is kept inside."

/obj/structure/anomaly_container/proc/release()
	if(!contained)
		return
	contained.dropInto(src)
	contained = null
	underlays.Cut()
	desc = initial(desc)

/atom/MouseDrop(var/obj/structure/anomaly_container/over_object)
	. = ..()

	if(istype(over_object))
		if(!QDELETED(src) && isturf(loc) && is_anomalous() && Adjacent(over_object) && CanMouseDrop(over_object, usr))
			Bumped(usr)
			over_object.contain(src)
