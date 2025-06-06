/datum/event2/meta/gas_leak
	name = "gas leak"
	departments = list(DEPARTMENT_ENGINEERING, DEPARTMENT_SYNTHETIC)
	chaos = 10
	chaotic_threshold = EVENT_CHAOS_THRESHOLD_LOW_IMPACT
	reusable = TRUE
	event_type = /datum/event2/event/gas_leak

/datum/event2/meta/gas_leak/get_weight()
	// Synthetics are counted in higher value because they can wirelessly connect to alarms.
	var/engineering_factor = GLOB.metric.count_people_in_department(DEPARTMENT_ENGINEERING) * 10
	var/synthetic_factor =  GLOB.metric.count_people_in_department(DEPARTMENT_SYNTHETIC) * 30
	return (15 + engineering_factor + synthetic_factor) / (times_ran + 1)



/datum/event2/event/gas_leak
	var/potential_gas_choices = list(GAS_CO2, GAS_N2O, GAS_PHORON, GAS_VOLATILE_FUEL)
	var/chosen_gas = null
	var/turf/chosen_turf = null

/datum/event2/event/gas_leak/set_up()
	chosen_gas = pick(potential_gas_choices)

	var/list/turfs = find_random_turfs()
	if(!turfs.len)
		log_debug("Gas Leak event failed to find any available turfs to leak into. Aborting.")
		abort()
		return
	chosen_turf = pick(turfs)

/datum/event2/event/gas_leak/announce()
	if(chosen_turf)
		command_announcement.Announce("Warning, hazardous [lowertext(GLOB.gas_data.name[chosen_gas])] gas leak detected in \the [chosen_turf.loc], evacuate the area.", "Hazard Alert")

/datum/event2/event/gas_leak/start()
	// Okay, time to actually put the gas in the room!
	// TODO - Would be nice to break a waste pipe perhaps?
	// TODO - Maybe having it released from a single point and thus causing airflow to blow stuff around

	// Fow now just add a bunch of it to the air

	var/datum/gas_mixture/air_contents = new
	air_contents.temperature = T20C + rand(-50, 50)
	air_contents.gas[chosen_gas] = 10 * MOLES_CELLSTANDARD
	chosen_turf.assume_air(air_contents)
	playsound(chosen_turf, 'sound/effects/smoke.ogg', 75, 1)
