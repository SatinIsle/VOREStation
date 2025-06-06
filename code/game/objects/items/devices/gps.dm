GLOBAL_LIST_EMPTY(GPS_list)

/obj/item/gps
	name = "global positioning system"
	desc = "Triangulates the approximate co-ordinates using a nearby satellite network. Alt+click to toggle power."
	icon = 'icons/obj/gps.dmi'
	icon_state = "gps-gen"
	w_class = ITEMSIZE_TINY
	slot_flags = SLOT_BELT
	origin_tech = list(TECH_MATERIAL = 2, TECH_BLUESPACE = 2, TECH_MAGNET = 1)
	matter = list(MAT_STEEL = 500)

	var/gps_tag = "GEN0"
	var/emped = FALSE
	var/tracking = FALSE		// Will not show other signals or emit its own signal if false.
	var/long_range = FALSE		// If true, can see farther, depending on get_map_levels().
	var/local_mode = FALSE		// If true, only GPS signals of the same Z level are shown.
	var/hide_signal = FALSE		// If true, signal is not visible to other GPS devices.
	var/can_hide_signal = FALSE	// If it can toggle the above var.

	var/mob/holder
	var/is_in_processing_list = FALSE
	var/list/tracking_devices
	var/list/showing_tracked_names
	var/obj/compass_holder/compass
	pickup_sound = 'sound/items/pickup/device.ogg'
	drop_sound = 'sound/items/drop/device.ogg'

/obj/item/gps/Initialize(mapload)
	. = ..()
	compass = new(src)
	GLOB.GPS_list += src
	name = "global positioning system ([gps_tag])"
	update_holder()
	update_icon()

/obj/item/gps/proc/check_visible_to_holder()
	. = (holder && (holder.get_active_hand() == src || holder.get_inactive_hand() == src))

/obj/item/gps/proc/update_holder()

	if(holder && loc != holder)
		UnregisterSignal(holder, COMSIG_OBSERVER_MOVED)
		//GLOB.dir_set_event.unregister(holder, src)
		holder.client?.screen -= compass
		holder = null

	if(istype(loc, /mob))
		holder = loc
		RegisterSignal(holder, COMSIG_OBSERVER_MOVED, PROC_REF(update_compass), override = TRUE)
		holder.AddComponent(/datum/component/recursive_move)
		//GLOB.dir_set_event.register(holder, src, PROC_REF(update_compass))

	if(holder && tracking)
		if(!is_in_processing_list)
			START_PROCESSING(SSobj, src)
			is_in_processing_list = TRUE
		if(holder.client)
			if(check_visible_to_holder())
				holder.client.screen |= compass
			else
				holder.client.screen -= compass
	else
		STOP_PROCESSING(SSobj, src)
		is_in_processing_list = FALSE
		if(holder?.client)
			holder.client.screen -= compass

/obj/item/gps/pickup()
	. = ..()
	update_holder()

/obj/item/gps/equipped_robot()
	. = ..()
	update_holder()

/obj/item/gps/equipped()
	. = ..()
	update_holder()

/obj/item/gps/dropped(mob/user)
	. = ..()
	update_holder()

/obj/item/gps/process()
	if(!tracking)
		is_in_processing_list = FALSE
		return PROCESS_KILL
	update_holder()
	if(holder)
		update_compass(TRUE)

/obj/item/gps/Destroy()
	STOP_PROCESSING(SSobj, src)
	is_in_processing_list = FALSE
	GLOB.GPS_list -= src
	update_holder()
	QDEL_NULL(compass)
	. = ..()

/obj/item/gps/proc/can_track(var/obj/item/gps/other, var/reachable_z_levels)
	if(!other.tracking || other.emped || other.hide_signal)
		return FALSE
	var/turf/origin = get_turf(src)
	var/turf/target = get_turf(other)
	if(!istype(origin) || !istype(target))
		return FALSE
	if(origin.z == target.z)
		return TRUE
	if(local_mode)
		return FALSE
	reachable_z_levels = reachable_z_levels || using_map.get_map_levels(origin.z, long_range)
	return (target.z in reachable_z_levels)

/obj/item/gps/proc/update_compass(var/update_compass_icon)
	SIGNAL_HANDLER
	compass.hide_waypoints(FALSE)
	var/turf/my_turf = get_turf(src)
	for(var/thing in tracking_devices)
		var/obj/item/gps/gps = locate(thing)
		if(!istype(gps) || QDELETED(gps))
			LAZYREMOVE(tracking_devices, thing)
			LAZYREMOVE(showing_tracked_names, thing)
			continue
		var/turf/gps_turf = get_turf(gps)
		var/gps_tag = LAZYACCESS(showing_tracked_names, thing) ? gps.gps_tag : null
		if(istype(gps_turf))
			compass.set_waypoint("\ref[gps]", gps_tag, gps_turf.x, gps_turf.y, gps_turf.z, LAZYACCESS(tracking_devices, "\ref[gps]"))
		else
			compass.set_waypoint("\ref[gps]", gps_tag, 0, 0, 0, LAZYACCESS(tracking_devices, "\ref[gps]"))
		if(can_track(gps) && gps_turf && my_turf && gps_turf.z == my_turf.z)
			compass.show_waypoint("\ref[gps]")
	compass.rebuild_overlay_lists(update_compass_icon)

/obj/item/gps/AltClick(mob/user)
	toggletracking(user)

/obj/item/gps/proc/toggletracking(mob/living/user)
	if(!istype(user))
		return
	if(emped)
		to_chat(user, "It's busted!")
		return

	toggle_tracking()
	if(tracking)
		to_chat(user, "[src] is no longer tracking, or visible to other GPS devices.")
	else
		to_chat(user, "[src] is now tracking, and visible to other GPS devices.")

/obj/item/gps/proc/toggle_tracking()
	tracking = !tracking
	if(tracking)
		if(!is_in_processing_list)
			is_in_processing_list = TRUE
			START_PROCESSING(SSobj, src)
	else
		is_in_processing_list = FALSE
		STOP_PROCESSING(SSobj, src)
	update_compass()
	update_holder()
	update_icon()

/obj/item/gps/emp_act(severity)
	if(emped) // Without a fancy callback system, this will have to do.
		return
	var/severity_modifier = severity ? severity : 4 // In case emp_act gets called without any arguments.
	var/duration = 5 MINUTES / severity_modifier
	emped = TRUE
	update_icon()

	spawn(duration)
		emped = FALSE
		update_icon()
		visible_message("\The [src] appears to be functional again.")

/obj/item/gps/update_icon()
	cut_overlays()
	if(emped)
		add_overlay("emp")
	else if(tracking)
		add_overlay("working")

/obj/item/gps/attack_self(mob/user)
	display(user)

// Compiles all the data not available directly from the GPS
// Like the positions and directions to all other GPS units
/obj/item/gps/proc/display_list()
	var/list/dat = list()

	var/turf/curr = get_turf(src)
	var/area/my_area = get_area(src)

	dat["my_area_name"] = strip_improper(my_area.name)
	dat["curr_x"] = curr.x
	dat["curr_y"] = curr.y
	dat["curr_z"] = curr.z
	dat["curr_z_name"] = strip_improper(using_map.get_zlevel_name(curr.z))
	dat["z_level_detection"] = using_map.get_map_levels(curr.z, long_range)

	var/list/gps_list = list()
	for(var/obj/item/gps/G in GLOB.GPS_list - src)

		if(!can_track(G, dat["z_level_detection"]))
			continue

		var/gps_data[0]
		gps_data["ref"] = G
		gps_data["gps_tag"] = G.gps_tag

		var/area/A = get_area(G)
		gps_data["area_name"] = strip_improper(A.get_name())

		var/turf/T = get_turf(G)
		gps_data["z_name"] = strip_improper(using_map.get_zlevel_name(T.z))
		gps_data["direction"] = get_adir(curr, T)
		gps_data["degrees"] = round(Get_Angle(curr,T))
		gps_data["distX"] = T.x - curr.x
		gps_data["distY"] = T.y - curr.y
		gps_data["distance"] = get_dist(curr, T)
		gps_data["local"] = (curr.z == T.z)
		gps_data["x"] = T.x
		gps_data["y"] = T.y

		gps_list[++gps_list.len] = gps_data

	dat["gps_list"] = gps_list

	return dat

/obj/item/gps/proc/display(mob/user)

	if(emped)
		to_chat(user, span_warning("It's busted!"))
		return

	var/list/dat = list()
	var/list/gps_data = display_list()

	dat += "<table width = '100%'>"
	if(!tracking)
		dat += "<tr><td colspan = 6></td><a href='byond://?src=\ref[src];toggle_power=1'>\[Switch On\]</a></tr>"
	else
		dat += "<tr><td colspan = 6></td><a href='byond://?src=\ref[src];toggle_power=1'>\[Switch Off\]</a></tr>"
		dat += "<tr><td colspan = 2><b>Current location</b></td><td colspan = 2>[gps_data["my_area_name"]]</td><td colspan = 2><b>([gps_data["curr_x"]], [gps_data["curr_y"]], [gps_data["curr_z_name"]])</b></td></tr>"
		dat += "<tr><td colspan = 4>[hide_signal ? "Tagged" : "Broadcasting"] as '[gps_tag]'.</td>"
		dat += "<td><a href='byond://?src=\ref[src];tag=1'>\[Change Tag\]</a><a href='byond://?src=\ref[src];range=1'>\[Toggle Scan Range\]</a>[can_hide_signal ? "<a href='byond://?src=\ref[src];hide=1'>\[Toggle Signal Visibility\]</a>":""]</td></tr>"

		var/list/gps_list = gps_data["gps_list"]
		if(gps_list.len)
			dat += "<tr><td colspan = 6><b>Detected signals</b></td></tr>"
			for(var/gps in gps_data["gps_list"])
				dat += "<tr>"
				var/gps_ref = "\ref[gps["ref"]]"
				dat += "<td>[gps["gps_tag"]]</td><td>[gps["area_name"]]</td>"

				if(istype(gps_data["ref"], /obj/item/gps/internal/poi))
					dat += "<td>[gps["local"] ? "[gps["direction"]] Dist: [round(gps["distance"], 10)]m" : "[gps["z_name"]]"]</td>"
				else
					dat += "<td>([gps["x"]], [gps["y"]], [gps["z_name"]])</td>"

				if(gps["local"])
					dat += "<td>[gps["distance"]]m</td><td>[gps["direction"]]</td>"
				else
					dat += "<td colspan = 2>Non-local signal.</td>"

				if(LAZYACCESS(tracking_devices, gps_ref))
					dat += "<td><a href='byond://?src=\ref[src];stop_track=[gps_ref]'>\[Stop Tracking\]</a> <a href='byond://?src=\ref[src];track_color=[gps_ref]'>\[Colour [color_square(hex = LAZYACCESS(tracking_devices, gps_ref))]\]</a> <a href='byond://?src=\ref[src];track_label=[gps_ref]'>Show/Hide Label</a></td>"
				else
					dat += "<td><a href='byond://?src=\ref[src];start_track=[gps_ref]'>\[Start Tracking\]</a></td>"
				dat += "</tr>"
		else
			dat += "<tr><td colspan = 5>No other signals detected.</td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "gps_\ref[src]", "Global Positioning System", 700, 1000)
	popup.set_content(dat.Join(null))
	popup.open()

/obj/item/gps/Topic(var/href, var/list/href_list)
	if(..())
		return TRUE

	if(href_list["toggle_power"])
		toggle_tracking()
		. = TRUE

	if(href_list["track_label"])
		var/gps_ref = href_list["track_label"]
		var/obj/item/gps/gps = locate(gps_ref)
		if(istype(gps) && !QDELETED(gps) && !LAZYACCESS(showing_tracked_names, gps_ref))
			LAZYSET(showing_tracked_names, gps_ref, TRUE)
		else
			LAZYREMOVE(showing_tracked_names, gps_ref)
		to_chat(usr, span_notice("\The [src] is [LAZYACCESS(showing_tracked_names, gps_ref) ? "now showing" : "no longer showing"] labels for [gps.gps_tag]."))

	if(href_list["stop_track"])
		var/gps_ref = href_list["stop_track"]
		var/obj/item/gps/gps = locate(gps_ref)
		compass.clear_waypoint(gps_ref)
		LAZYREMOVE(tracking_devices, gps_ref)
		LAZYREMOVE(showing_tracked_names, gps_ref)
		if(istype(gps) && !QDELETED(gps))
			to_chat(usr, span_notice("\The [src] is no longer tracking [gps.gps_tag]."))
		update_compass()
		. = TRUE

	if(href_list["start_track"])
		var/gps_ref = href_list["start_track"]
		var/obj/item/gps/gps = locate(gps_ref)
		if(istype(gps) && !QDELETED(gps))
			LAZYSET(tracking_devices, gps_ref, "#00ffff")
			LAZYSET(showing_tracked_names, gps_ref, TRUE)
			to_chat(usr, span_notice("\The [src] is now tracking [gps.gps_tag]."))
			update_compass()
			. = TRUE

	if(href_list["track_color"])
		var/obj/item/gps/gps = locate(href_list["track_color"])
		if(istype(gps) && !QDELETED(gps))
			var/new_colour = tgui_color_picker(usr, "Enter a new tracking color.", "GPS Waypoint Color")
			if(new_colour && istype(gps) && !QDELETED(gps) && holder == usr && !usr.incapacitated())
				to_chat(usr, span_notice("You adjust the colour \the [src] is using to highlight [gps.gps_tag]."))
				LAZYSET(tracking_devices, href_list["track_color"], new_colour)
				update_compass()
				. = TRUE

	if(href_list["tag"])
		var/a = tgui_input_text(usr, "Please enter desired tag.", name, gps_tag, 10)
		a = uppertext(copytext(sanitize(a), 1, 11))
		if(in_range(src, usr))
			gps_tag = a
			name = "global positioning system ([gps_tag])"
			to_chat(usr, "You set your GPS's tag to '[gps_tag]'.")
			. = TRUE

	if(href_list["range"])
		local_mode = !local_mode
		to_chat(usr, "You set the signal receiver to [local_mode ? "'NARROW'" : "'BROAD'"].")
		. = TRUE

	if(href_list["hide"])
		if(!can_hide_signal)
			return
		hide_signal = !hide_signal
		to_chat(usr, "You set the device to [hide_signal ? "not " : ""]broadcast a signal while scanning for other signals.")
		. = TRUE

	if(. && loc == usr)
		display(usr)

/obj/item/gps/on // Defaults to off to avoid polluting the signal list with a bunch of GPSes without owners. If you need to spawn active ones, use these.
	tracking = TRUE

/obj/item/gps/command
	icon_state = "gps-com"
	gps_tag = "COM0"

/obj/item/gps/command/on
	tracking = TRUE

/obj/item/gps/security
	icon_state = "gps-sec"
	gps_tag = "SEC0"

/obj/item/gps/security/on
	tracking = TRUE

/obj/item/gps/security/hos
	icon_state = "gps-sec-hos"
	gps_tag = "HOS0"

/obj/item/gps/security/hos/on
	tracking = TRUE

/obj/item/gps/medical
	icon_state = "gps-med"
	gps_tag = "MED0"

/obj/item/gps/medical/on
	tracking = TRUE

/obj/item/gps/medical/cmo
	icon_state = "gps-med-cmo"
	gps_tag = "CMO0"

/obj/item/gps/medical/cmo/on
	tracking = TRUE

/obj/item/gps/science
	icon_state = "gps-sci"
	gps_tag = "SCI0"

/obj/item/gps/science/on
	tracking = TRUE

/obj/item/gps/science/rd
	icon_state = "gps-sci-rd"
	gps_tag = "RD0"

/obj/item/gps/science/rd/on
	tracking = TRUE

/obj/item/gps/engineering
	icon_state = "gps-eng"
	gps_tag = "ENG0"

/obj/item/gps/engineering/on
	tracking = TRUE

/obj/item/gps/engineering/atmos
	icon_state = "gps-eng-atm"
	gps_tag = "ATM0"

/obj/item/gps/engineering/atmos/on
	tracking = TRUE

/obj/item/gps/engineering/ce
	icon_state = "gps-eng-ce"
	gps_tag = "CE0"

/obj/item/gps/engineering/ce/on
	tracking = TRUE

/obj/item/gps/mining
	icon_state = "gps-mine"
	gps_tag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life. Alt+click to toggle power."

/obj/item/gps/mining/on
	tracking = TRUE

/obj/item/gps/explorer
	icon_state = "gps-exp"
	gps_tag = "EXP0"
	desc = "A positioning system helpful for rescuing trapped or injured explorers, keeping one on you at all times while exploring might just save your life. Alt+click to toggle power."

/obj/item/gps/explorer/on
	tracking = TRUE

/obj/item/gps/robot
	icon_state = "gps-borg"
	gps_tag = "SYNTH0"
	desc = "A synthetic internal positioning system. Used as a recovery beacon for damaged synthetic assets, or a collaboration tool for mining or exploration teams. \
	Alt+click to toggle power."
	tracking = TRUE // On by default.

/obj/item/gps/internal // Base type for immobile/internal GPS units.
	icon_state = "internal"
	gps_tag = "Eerie Signal"
	desc = "Report to a coder immediately."
	invisibility = INVISIBILITY_MAXIMUM
	tracking = TRUE // Meant to point to a location, so it needs to be on.
	anchored = TRUE

/obj/item/gps/internal/base
	gps_tag = "NT_BASE"
	desc = "A homing signal from NanoTrasen's outpost."

/obj/item/gps/internal/poi
	gps_tag = "Unidentified Signal"
	desc = "A signal that seems forboding."

/obj/item/gps/syndie
	icon_state = "gps-syndie"
	gps_tag = "NULL"
	desc = "A positioning system that has extended range and can detect other GPS device signals without revealing its own. How that works is best left a mystery. Alt+click to toggle power."
	origin_tech = list(TECH_MATERIAL = 2, TECH_BLUESPACE = 3, TECH_MAGNET = 2, TECH_ILLEGAL = 2)
	long_range = TRUE
	hide_signal = TRUE
	can_hide_signal = TRUE

/obj/item/gps/syndie/display(mob/user)

	if(emped)
		to_chat(user, "It's busted!")
		return

	var/list/dat = list()
	var/list/gps_data = display_list()

	dat += "<table width = '100%'>"
	if(!tracking)
		dat += "<tr><td colspan = 6></td><a href='byond://?src=\ref[src];toggle_power=1'>\[Switch On\]</a></tr>"
	else
		dat += "<tr><td colspan = 6></td><a href='byond://?src=\ref[src];toggle_power=1'>\[Switch Off\]</a></tr>"
		dat += "<tr><td colspan = 2><b>Current location</b></td><td colspan = 2>[gps_data["my_area_name"]]</td><td colspan = 2><b>([gps_data["curr_x"]], [gps_data["curr_y"]], [gps_data["curr_z_name"]])</b></td></tr>"
		dat += "<tr><td colspan = 4>[hide_signal ? "Tagged" : "Broadcasting"] as '[gps_tag]'.</td>"
		dat += "<td><a href='byond://?src=\ref[src];tag=1'>\[Change Tag\]</a><a href='byond://?src=\ref[src];range=1'>\[Toggle Scan Range\]</a>[can_hide_signal ? "<a href='byond://?src=\ref[src];hide=1'>\[Toggle Signal Visibility\]</a>":""]</td></tr>"

		var/list/gps_list = gps_data["gps_list"]
		if(gps_list.len)
			dat += "<tr><td colspan = 6><b>Detected signals</b></td></tr>"
			for(var/gps in gps_data["gps_list"])
				dat += "<tr>"
				var/gps_ref = "\ref[gps["ref"]]"
				dat += "<td>[gps["gps_tag"]]</td><td>[gps["area_name"]] ([gps["x"]], [gps["y"]], [gps["z_name"]])</td>"
				if(gps["local"])
					dat += "<td>[gps["distance"]]m</td><td>[gps["direction"]]</td>"
				else
					dat += "<td colspan = 2>Non-local signal.</td>"
				if(LAZYACCESS(tracking_devices, gps_ref))
					dat += "<td><a href='byond://?src=\ref[src];stop_track=[gps_ref]'>\[Stop Tracking\]</a> <a href='byond://?src=\ref[src];track_color=[gps_ref]'>\[Colour [color_square(hex = LAZYACCESS(tracking_devices, gps_ref))]\]</a> <a href='byond://?src=\ref[src];track_label=[gps_ref]'>Show/Hide Label</a></td>"
				else
					dat += "<td><a href='byond://?src=\ref[src];start_track=[gps_ref]'>\[Start Tracking\]</a></td>"
				dat += "</tr>"
		else
			dat += "<tr><td colspan = 6>No other signals detected.</td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "gps_\ref[src]", "Global Positioning System", 700, 1000)
	popup.set_content(dat.Join(null))
	popup.open()
