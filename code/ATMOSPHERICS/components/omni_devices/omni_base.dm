//--------------------------------------------
// Base omni device
//--------------------------------------------
/obj/machinery/atmospherics/omni
	name = "omni device"
	icon = 'icons/atmos/omni_devices_vr.dmi' //VOREStation Edit - New Icon
	icon_state = "base"
	use_power = USE_POWER_IDLE
	initialize_directions = 0
	construction_type = /obj/item/pipe/quaternary
	level = 1

	var/configuring = 0
	//var/target_pressure = ONE_ATMOSPHERE	//a base type as abstract as this should NOT be making these kinds of assumptions

	var/tag_north = ATM_NONE
	var/tag_south = ATM_NONE
	var/tag_east = ATM_NONE
	var/tag_west = ATM_NONE

	var/overlays_on[5]
	var/overlays_off[5]
	var/overlays_error[2]
	var/underlays_current[4]

	var/list/ports = new()

/obj/machinery/atmospherics/omni/Initialize(mapload)
	. = ..()

	icon_state = "base"

	ports = new()
	for(var/d in GLOB.cardinal)
		var/datum/omni_port/new_port = new(src, d)
		switch(d)
			if(NORTH)
				new_port.mode = tag_north
			if(SOUTH)
				new_port.mode = tag_south
			if(EAST)
				new_port.mode = tag_east
			if(WEST)
				new_port.mode = tag_west
		if(new_port.mode > 0)
			initialize_directions |= d
		ports += new_port

	build_icons()

/obj/machinery/atmospherics/omni/update_icon()
	if(stat & NOPOWER)
		overlays = overlays_off
	else if(error_check())
		overlays = overlays_error
	else
		overlays = use_power ? (overlays_on) : (overlays_off)

	underlays = underlays_current

	return

/obj/machinery/atmospherics/omni/proc/error_check()
	return

/obj/machinery/atmospherics/omni/process()
	last_power_draw = 0
	last_flow_rate = 0

	if(error_check())
		update_use_power(USE_POWER_OFF)

	if((stat & (NOPOWER|BROKEN)) || !use_power)
		return 0
	return 1

/obj/machinery/atmospherics/omni/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/omni/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(!W.has_tool_quality(TOOL_WRENCH))
		return ..()

	if(!can_unwrench())
		to_chat(user, span_warning("You cannot unwrench \the [src], it is too exerted due to internal pressure."))
		add_fingerprint(user)
		return 1
	to_chat(user, span_notice("You begin to unfasten \the [src]..."))
	playsound(src, W.usesound, 50, 1)
	if(do_after(user, 40 * W.toolspeed))
		user.visible_message( \
			span_infoplain(span_bold("\The [user]") + "unfastens \the [src]."), \
			span_notice("You have unfastened \the [src]."), \
			"You hear a ratchet.")
		deconstruct()

/obj/machinery/atmospherics/omni/attack_hand(user as mob)
	if(..())
		return

	src.add_fingerprint(user)
	tgui_interact(user)
	return

/obj/machinery/atmospherics/omni/proc/build_icons()
	if(!check_icon_cache())
		return

	var/core_icon = null
	if(istype(src, /obj/machinery/atmospherics/omni/mixer))
		core_icon = "mixer"
	else if(istype(src, /obj/machinery/atmospherics/omni/atmos_filter))
		core_icon = "filter"
	else
		return

	//directional icons are layers 1-4, with the core icon on layer 5
	if(core_icon)
		overlays_off[5] = icon_manager.get_atmos_icon("omni", , , core_icon)
		overlays_on[5] = icon_manager.get_atmos_icon("omni", , , core_icon + "_glow")

		overlays_error[1] = icon_manager.get_atmos_icon("omni", , , core_icon)
		overlays_error[2] = icon_manager.get_atmos_icon("omni", , , "error")

/obj/machinery/atmospherics/omni/proc/update_port_icons()
	if(!check_icon_cache())
		return

	for(var/datum/omni_port/P in ports)
		if(P.update)
			var/ref_layer = 0
			switch(P.dir)
				if(NORTH)
					ref_layer = 1
				if(SOUTH)
					ref_layer = 2
				if(EAST)
					ref_layer = 3
				if(WEST)
					ref_layer = 4

			if(!ref_layer)
				continue

			var/list/port_icons = select_port_icons(P)
			if(port_icons)
				if(P.node)
					underlays_current[ref_layer] = port_icons["pipe_icon"]
				else
					underlays_current[ref_layer] = null
				overlays_off[ref_layer] = port_icons["off_icon"]
				overlays_on[ref_layer] = port_icons["on_icon"]
			else
				underlays_current[ref_layer] = null
				overlays_off[ref_layer] = null
				overlays_on[ref_layer] = null

	update_icon()

/obj/machinery/atmospherics/omni/proc/select_port_icons(var/datum/omni_port/P)
	if(!istype(P))
		return

	if(P.mode > 0)
		var/ic_dir = dir_name(P.dir)
		var/ic_on = ic_dir
		var/ic_off = ic_dir
		switch(P.mode)
			if(ATM_INPUT)
				ic_on += "_in_glow"
				ic_off += "_in"
			if(ATM_OUTPUT)
				ic_on += "_out_glow"
				ic_off += "_out"
			if(ATM_O2 to ATM_N2O)
				ic_on += "_filter"
				ic_off += "_out"

		ic_on = icon_manager.get_atmos_icon("omni", , , ic_on)
		ic_off = icon_manager.get_atmos_icon("omni", , , ic_off)

		var/pipe_state
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(!T.is_plating() && istype(P.node, /obj/machinery/atmospherics/pipe) && P.node.level == 1 )
			//pipe_state = icon_manager.get_atmos_icon("underlay_down", P.dir, color_cache_name(P.node))
			pipe_state = icon_manager.get_atmos_icon("underlay", P.dir, color_cache_name(P.node), "down")
		else
			//pipe_state = icon_manager.get_atmos_icon("underlay_intact", P.dir, color_cache_name(P.node))
			pipe_state = icon_manager.get_atmos_icon("underlay", P.dir, color_cache_name(P.node), "intact")

		return list("on_icon" = ic_on, "off_icon" = ic_off, "pipe_icon" = pipe_state)

/obj/machinery/atmospherics/omni/update_underlays()
	for(var/datum/omni_port/P in ports)
		P.update = 1
	update_ports()

/obj/machinery/atmospherics/omni/hide(var/i)
	update_underlays()

/obj/machinery/atmospherics/omni/proc/update_ports()
	sort_ports()
	update_port_icons()
	for(var/datum/omni_port/P in ports)
		P.update = 0

/obj/machinery/atmospherics/omni/proc/sort_ports()
	return


// Housekeeping and pipe network stuff below
/obj/machinery/atmospherics/omni/get_neighbor_nodes_for_init()
	var/list/neighbor_nodes = list()
	for(var/datum/omni_port/P in ports)
		neighbor_nodes += P.node
	return neighbor_nodes

/obj/machinery/atmospherics/omni/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	for(var/datum/omni_port/P in ports)
		if(reference == P.node)
			P.network = new_network
			break

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	return null

/obj/machinery/atmospherics/omni/Destroy()
	loc = null

	for(var/datum/omni_port/P in ports)
		if(P.node)
			P.node.disconnect(src)
			qdel(P.network)
			P.node = null
	ports = null
	. = ..()

/obj/machinery/atmospherics/omni/atmos_init()
	for(var/datum/omni_port/P in ports)
		if(P.node || P.mode == 0)
			continue
		for(var/obj/machinery/atmospherics/target in get_step(src, P.dir))
			if(can_be_node(target, 1))
				P.node = target
				break

	for(var/datum/omni_port/P in ports)
		P.update = 1

	update_ports()

/obj/machinery/atmospherics/omni/build_network()
	for(var/datum/omni_port/P in ports)
		if(!P.network && P.node)
			P.network = new /datum/pipe_network()
			P.network.normal_members += src
			P.network.build_network(P.node, src)

/obj/machinery/atmospherics/omni/return_network(obj/machinery/atmospherics/reference)
	build_network()

	for(var/datum/omni_port/P in ports)
		if(reference == P.node)
			return P.network

	return null

/obj/machinery/atmospherics/omni/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	for(var/datum/omni_port/P in ports)
		if(P.network == old_network)
			P.network = new_network

	return 1

/obj/machinery/atmospherics/omni/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	for(var/datum/omni_port/P in ports)
		if(P.network == reference)
			results += P.air

	return results

/obj/machinery/atmospherics/omni/disconnect(obj/machinery/atmospherics/reference)
	for(var/datum/omni_port/P in ports)
		if(reference == P.node)
			qdel(P.network)
			P.node = null
			P.update = 1
			break

	update_ports()

	return null
