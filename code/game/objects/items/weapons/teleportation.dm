/* Teleportation devices.
 * Contains:
 *		Locator
 *		Hand-tele
 */

/*
 * Locator
 */
/obj/item/locator
	name = "locator"
	desc = "Used to track those with locater implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/temp = null
	var/frequency = 1451
	var/broadcasting = null
	var/listening = 1.0
	w_class = ITEMSIZE_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MAT_STEEL = 400)
	pickup_sound = 'sound/items/pickup/device.ogg'
	drop_sound = 'sound/items/drop/device.ogg'

/obj/item/locator/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = {"
<B>Persistent Signal Locator</B><HR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

<A href='byond://?src=\ref[src];refresh=1'>Refresh</A>"}
	user << browse("<html>[dat]</html>", "window=radio")
	onclose(user, "radio")
	return

/obj/item/locator/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/turf/current_location = get_turf(usr)//What turf is the user on?
	if(!current_location||current_location.z==2)//If turf was not found or they're on z level 2.
		to_chat(usr, "The [src] is malfunctioning.")
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_machine(src)
		if (href_list["refresh"])
			src.temp = span_bold("Persistent Signal Locator") + "<HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				src.temp += span_bold("Located Beacons:") + "<BR>"

				for(var/obj/item/radio/beacon/W in GLOB.all_beacons)
					if (W.frequency == src.frequency)
						var/turf/tr = get_turf(W)
						if (tr.z == sr.z && tr)
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									if (direct < 20)
										direct = "weak"
									else
										direct = "very weak"
							src.temp += "[W.code]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += span_bold("Extraneous Signals:") + "<BR>"
				for (var/obj/item/implant/tracking/W in GLOB.all_tracking_implants)
					if (!W.implanted || !(istype(W.loc,/obj/item/organ/external) || ismob(W.loc) || W.malfunction))
						continue

					var/turf/tr = get_turf(W)
					if (tr.z == sr.z && tr)
						var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						if (direct < 20)
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									direct = "weak"
							src.temp += "[W.id]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += span_bold("You are at \[[sr.x],[sr.y],[sr.z]\]") + " in orbital coordinates.<BR><BR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A><BR>"
			else
				src.temp += span_bold(span_red("Processing Error:")) + " Unable to locate orbital position.<BR>"
		else
			if (href_list["freq"])
				src.frequency += text2num(href_list["freq"])
				src.frequency = sanitize_frequency(src.frequency)
			else
				if (href_list["temp"])
					src.temp = null
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return


/*
 * Hand-tele
 */
/obj/item/hand_tele
	name = "hand tele"
	desc = "A portable item using blue-space technology."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 5
	w_class = ITEMSIZE_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_MAGNET = 1, TECH_BLUESPACE = 3)
	matter = list(MAT_STEEL = 10000)
	preserve_item = 1

/obj/item/hand_tele/attack_self(mob/user as mob)
	var/turf/current_location = get_turf(user)//What turf is the user on?
	if(!current_location || (current_location.z in using_map.admin_levels) || current_location.block_tele)//If turf was not found or they're on z level 2 or >7 which does not currently exist.
		to_chat(user, span_notice("\The [src] is malfunctioning."))
		return
	var/list/L = list(  )
	for(var/obj/machinery/teleport/hub/R in GLOB.machines)
		var/obj/machinery/computer/teleporter/com
		var/obj/machinery/teleport/station/station
		for(var/direction in GLOB.cardinal)
			station = locate(/obj/machinery/teleport/station, get_step(R, direction))
			if(station)
				for(direction in GLOB.cardinal)
					com = locate(/obj/machinery/computer/teleporter, get_step(station, direction))
					if(com)
						break
				break
		if (istype(com, /obj/machinery/computer/teleporter) && com.teleport_control.locked && !com.one_time_use)
			if(R.icon_state == "tele1")
				L["[com.id] (Active)"] = com.teleport_control.locked
			else
				L["[com.id] (Inactive)"] = com.teleport_control.locked
	var/list/turfs = list(	)
	for(var/turf/T in orange(10))
		if(T.x>world.maxx-8 || T.x<8)	continue	//putting them at the edge is dumb
		if(T.y>world.maxy-8 || T.y<8)	continue
		if(T.block_tele) continue
		turfs += T
	if(turfs.len)
		L["None (Dangerous)"] = pick(turfs)
	var/t1 = tgui_input_list(user, "Please select a teleporter to lock in on.", "Hand Teleporter", L)
	if(!t1)
		return
	if ((user.get_active_hand() != src || user.stat || user.restrained()))
		return
	var/count = 0	//num of portals from this teleport in world
	for(var/obj/effect/portal/PO in GLOB.all_portals)
		if(PO.creator == src)	count++
	if(count >= 3)
		user.show_message(span_notice("\The [src] is recharging!"))
		return
	var/T = L[t1]
	for(var/mob/O in hearers(user, null))
		O.show_message(span_notice("Locked In."), 2)
	var/obj/effect/portal/P = new /obj/effect/portal( get_turf(src) )
	P.target = T
	P.creator = src
	src.add_fingerprint(user)
	return
