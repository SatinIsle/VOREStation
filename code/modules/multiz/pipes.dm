////////////////////////////
// parent class for pipes //
////////////////////////////
/obj/machinery/atmospherics/pipe/zpipe
	icon = 'icons/obj/structures.dmi'
	icon_state = "up"

	name = "upwards pipe"
	desc = "A pipe segment to connect upwards."

	volume = 70

	dir = SOUTH
	initialize_directions = SOUTH

	construction_type = /obj/item/pipe/directional
	pipe_state = "cap"

	// node1 is the connection on the same Z
	// node2 is the connection on the other Z

	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

	var/maximum_pressure = 70*ONE_ATMOSPHERE
	var/fatigue_pressure = 55*ONE_ATMOSPHERE
	alert_pressure = 55*ONE_ATMOSPHERE

	level = 1

/obj/machinery/atmospherics/pipe/zpipe/Initialize(mapload)
	. = ..()
	init_dir()

/obj/machinery/atmospherics/pipe/zpipe/init_dir()
	switch(dir)
		if(SOUTH)
			initialize_directions = SOUTH
		if(NORTH)
			initialize_directions = NORTH
		if(WEST)
			initialize_directions = WEST
		if(EAST)
			initialize_directions = EAST
		if(NORTHEAST)
			initialize_directions = NORTH
		if(NORTHWEST)
			initialize_directions = WEST
		if(SOUTHEAST)
			initialize_directions = EAST
		if(SOUTHWEST)
			initialize_directions = SOUTH

/obj/machinery/atmospherics/pipe/zpipe/hide(var/i)
	if(istype(loc, /turf/simulated))
		invisibility = i ? INVISIBILITY_ABSTRACT : INVISIBILITY_NONE
	update_icon()

/obj/machinery/atmospherics/pipe/zpipe/process()
	if(!parent) //This should cut back on the overhead calling build_network thousands of times per cycle
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/zpipe/check_pressure(pressure)
	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - environment.return_pressure()

	if(pressure_difference > maximum_pressure)
		burst()

	else if(pressure_difference > fatigue_pressure)
		//TODO: leak to turf, doing pfshhhhh
		if(prob(5))
			burst()

	else return 1

/obj/machinery/atmospherics/pipe/zpipe/proc/burst()
	src.visible_message(span_warning("\The [src] bursts!"));
	playsound(src, 'sound/effects/bang.ogg', 25, 1)
	var/datum/effect/effect/system/smoke_spread/smoke = new
	smoke.set_up(1,0, src.loc, 0)
	smoke.start()
	qdel(src) // NOT qdel.

/obj/machinery/atmospherics/pipe/zpipe/proc/normalize_dir()
	if(dir == (NORTH|SOUTH))
		set_dir(NORTH)
	else if(dir == (EAST|WEST))
		set_dir(EAST)

/obj/machinery/atmospherics/pipe/zpipe/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)
	. = ..()

/obj/machinery/atmospherics/pipe/zpipe/pipeline_expansion()
	return list(node1, node2)

/obj/machinery/atmospherics/pipe/zpipe/update_icon()
	color = pipe_color
	return

/obj/machinery/atmospherics/pipe/zpipe/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null

	return null
/////////////////////////
// the elusive up pipe //
/////////////////////////
/obj/machinery/atmospherics/pipe/zpipe/up
		icon = 'icons/obj/structures.dmi'
		icon_state = "up"

		name = "upwards pipe"
		desc = "A pipe segment to connect upwards."

/obj/machinery/atmospherics/pipe/zpipe/up/atmos_init()
	normalize_dir()
	var/node1_dir

	for(var/direction in GLOB.cardinal)
		if(direction&initialize_directions)
			if (!node1_dir)
				node1_dir = direction

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
		if(can_be_node(target, 1))
			node1 = target
			break

	var/turf/above = GetAbove(src)
	if(above)
		for(var/obj/machinery/atmospherics/target in above)
			if(istype(target, /obj/machinery/atmospherics/pipe/zpipe/down))
				if (check_connectable(target) && target.check_connectable(src))
					node2 = target
					break


	var/turf/T = src.loc			// hide if turf is not intact
	if(level == 1 && !T.is_plating()) hide(1)	// but respect level

///////////////////////
// and the down pipe //
///////////////////////

/obj/machinery/atmospherics/pipe/zpipe/down
		icon = 'icons/obj/structures.dmi'
		icon_state = "down"

		name = "downwards pipe"
		desc = "A pipe segment to connect downwards."

/obj/machinery/atmospherics/pipe/zpipe/down/atmos_init()
	normalize_dir()
	var/node1_dir

	for(var/direction in GLOB.cardinal)
		if(direction&initialize_directions)
			if (!node1_dir)
				node1_dir = direction

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
		if(can_be_node(target, 1))
			node1 = target
			break

	var/turf/below = GetBelow(src)
	if(below)
		for(var/obj/machinery/atmospherics/target in below)
			if(istype(target, /obj/machinery/atmospherics/pipe/zpipe/up))
				if (check_connectable(target) && target.check_connectable(src))
					node2 = target
					break


	var/turf/T = src.loc			// hide if turf is not intact
	if(level == 1 && !T.is_plating()) hide(1)	// but respect level

///////////////////////
// supply/scrubbers  //
///////////////////////

/obj/machinery/atmospherics/pipe/zpipe/up/scrubbers
	icon_state = "up-scrubbers"
	name = "upwards scrubbers pipe"
	desc = "A scrubbers pipe segment to connect upwards."
	connect_types = CONNECT_TYPE_SCRUBBER
	piping_layer = PIPING_LAYER_SCRUBBER
	layer = PIPES_SCRUBBER_LAYER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/zpipe/up/supply
	icon_state = "up-supply"
	name = "upwards supply pipe"
	desc = "A supply pipe segment to connect upwards."
	connect_types = CONNECT_TYPE_SUPPLY
	piping_layer = PIPING_LAYER_SUPPLY
	layer = PIPES_SUPPLY_LAYER
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/zpipe/up/fuel
	icon_state = "up-fuel"
	name = "upwards fuel pipe"
	desc = "A fuel pipe segment to connect upwards."
	connect_types = CONNECT_TYPE_FUEL
	piping_layer = PIPING_LAYER_FUEL
	layer = PIPES_FUEL_LAYER
	icon_connect_type = "-fuel"
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/zpipe/up/aux
	icon_state = "up-aux"
	name = "upwards aux pipe"
	desc = "A aux pipe segment to connect upwards."
	connect_types = CONNECT_TYPE_AUX
	piping_layer = PIPING_LAYER_AUX
	layer = PIPES_AUX_LAYER
	icon_connect_type = "-aux"
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/zpipe/down/scrubbers
	icon_state = "down-scrubbers"
	name = "downwards scrubbers pipe"
	desc = "A scrubbers pipe segment to connect downwards."
	connect_types = CONNECT_TYPE_SCRUBBER
	piping_layer = PIPING_LAYER_SCRUBBER
	layer = PIPES_SCRUBBER_LAYER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/zpipe/down/supply
	icon_state = "down-supply"
	name = "downwards supply pipe"
	desc = "A supply pipe segment to connect downwards."
	connect_types = CONNECT_TYPE_SUPPLY
	piping_layer = PIPING_LAYER_SUPPLY
	layer = PIPES_SUPPLY_LAYER
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/zpipe/down/fuel
	icon_state = "down-fuel"
	name = "downwards fuel pipe"
	desc = "A fuel pipe segment to connect downwards."
	connect_types = CONNECT_TYPE_FUEL
	piping_layer = PIPING_LAYER_FUEL
	layer = PIPES_FUEL_LAYER
	icon_connect_type = "-fuel"
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/zpipe/down/aux
	icon_state = "down-aux"
	name = "upwards aux pipe"
	desc = "A aux pipe segment to connect upwards."
	connect_types = CONNECT_TYPE_AUX
	piping_layer = PIPING_LAYER_AUX
	layer = PIPES_AUX_LAYER
	icon_connect_type = "-aux"
	color = PIPE_COLOR_CYAN
