/obj/machinery/cablelayer
	name = "automatic cable layer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = TRUE
	var/obj/structure/cable/last_piece
	var/obj/item/stack/cable_coil/cable
	var/max_cable = 100
	var/on = 0

/obj/machinery/cablelayer/Initialize(mapload)
	cable = new(src, max_cable)
	. = ..()

/obj/machinery/cablelayer/Moved(atom/old_loc, direction, forced = FALSE)
	. = ..()
	layCable(loc,direction)

/obj/machinery/cablelayer/attack_hand(mob/user as mob)
	if(!cable&&!on)
		to_chat(user, span_warning("\The [src] doesn't have any cable loaded."))
		return
	on=!on
	user.visible_message("\The [user] [!on?"dea":"a"]ctivates \the [src].", "You switch [src] [on? "on" : "off"]")
	return

/obj/machinery/cablelayer/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/stack/cable_coil))

		var/result = load_cable(O)
		if(!result)
			to_chat(user, span_warning("\The [src]'s cable reel is full."))
		else
			to_chat(user, "You load [result] lengths of cable into [src].")
		return

	if(O.has_tool_quality(TOOL_WIRECUTTER))
		if(cable && cable.get_amount())
			var/m = tgui_input_number(user, "Please specify the length of cable to cut", "Cut cable", min(cable.get_amount(), 30))
			m = min(m, cable.get_amount())
			m = min(m, 30)
			if(m)
				playsound(src, O.usesound, 50, 1)
				use_cable(m)
				var/obj/item/stack/cable_coil/CC = new (get_turf(src))
				CC.set_amount(m)
		else
			to_chat(user, span_warning("There's no more cable on the reel."))

/obj/machinery/cablelayer/examine(mob/user)
	. = ..()
	. += "[src]'s cable reel has [cable.get_amount()] length\s left."

/obj/machinery/cablelayer/proc/load_cable(var/obj/item/stack/cable_coil/CC)
	if(istype(CC) && CC.get_amount())
		var/cur_amount = cable ? cable.get_amount() : 0
		var/to_load = max(max_cable - cur_amount,0)
		if(to_load)
			to_load = min(CC.get_amount(), to_load)
			if(!cable)
				cable = new(src, to_load)
			else
				cable.add(to_load)
			CC.use(to_load)
			return to_load
		else
			return 0
	return

/obj/machinery/cablelayer/proc/use_cable(amount)
	if(!cable || cable.get_amount() < 1)
		visible_message("A red light flashes on \the [src].")
		return
	cable.use(amount)
	if(QDELETED(cable))
		cable = null
	return 1

/obj/machinery/cablelayer/proc/reset()
	last_piece = null

/obj/machinery/cablelayer/proc/dismantleFloor(var/turf/new_turf)
	if(istype(new_turf, /turf/simulated/floor))
		var/turf/simulated/floor/T = new_turf
		if(!T.is_plating())
			T.make_plating(!(T.broken || T.burnt))
	return new_turf.is_plating()

/obj/machinery/cablelayer/proc/layCable(var/turf/new_turf,var/M_Dir)
	if(!on)
		return reset()
	else
		dismantleFloor(new_turf)
	if(!istype(new_turf) || !dismantleFloor(new_turf))
		return reset()
	var/fdirn = turn(M_Dir,180)
	for(var/obj/structure/cable/LC in new_turf)		// check to make sure there's not a cable there already
		if(LC.d1 == fdirn || LC.d2 == fdirn)
			return reset()
	if(!use_cable(1))
		return reset()
	var/obj/structure/cable/NC = new(new_turf)
	NC.cableColor("red")
	NC.d1 = 0
	NC.d2 = fdirn
	NC.update_icon()

	var/datum/powernet/PN
	if(last_piece && last_piece.d2 != M_Dir)
		last_piece.d1 = min(last_piece.d2, M_Dir)
		last_piece.d2 = max(last_piece.d2, M_Dir)
		last_piece.update_icon()
		PN = last_piece.powernet

	if(!PN)
		PN = new()
	PN.add_cable(NC)
	NC.mergeConnectedNetworks(NC.d2)

	//NC.mergeConnectedNetworksOnTurf()
	last_piece = NC
	return 1
