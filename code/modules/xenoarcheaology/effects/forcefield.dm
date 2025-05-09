/// Verified to work with the Artifact Harvester
/datum/artifact_effect/forcefield
	name = "Forcefield"
	var/list/created_field = list()
	effect_type = EFFECT_FORCEFIELD

	effect_state = "shield-old"
	effect_color = "#00b7ff"

/datum/artifact_effect/forcefield/New()
	..()
	trigger = TRIGGER_TOUCH

/datum/artifact_effect/forcefield/ToggleActivate()
	var/atom/holder = get_master_holder()
	..()
	if(created_field.len)
		for(var/obj/effect/energy_field/F in created_field)
			created_field.Remove(F)
			qdel(F)
	else if(holder)
		var/turf/T = get_turf(holder)
		while(created_field.len < 16)
			var/obj/effect/energy_field/E = new (locate(T.x,T.y,T.z))
			created_field.Add(E)
			E.strength = 1
			E.density = TRUE
			E.anchored = TRUE
			E.invisibility = INVISIBILITY_NONE
		spawn(10)
			UpdateMove()
	return 1

/datum/artifact_effect/forcefield/process()
	..()
	for(var/obj/effect/energy_field/E in created_field)
		if(E.strength < 1)
			E.adjust_strength(0.15, 0)
		else if(E.strength < 5)
			E.adjust_strength(0.25, 0)

/datum/artifact_effect/forcefield/UpdateMove()
	var/atom/holder = get_master_holder()
	if(created_field.len && holder)
		var/turf/T = get_turf(holder)
		while(created_field.len < 16)
			//for now, just instantly respawn the fields when they get destroyed
			var/obj/effect/energy_field/E = new (locate(T.x,T.y,T))
			created_field.Add(E)
			E.anchored = TRUE
			E.density = TRUE
			E.invisibility = INVISIBILITY_NONE

		var/obj/effect/energy_field/E = created_field[1]
		E.loc = locate(T.x + 2,T.y + 2,T.z)
		E = created_field[2]
		E.loc = locate(T.x + 2,T.y + 1,T.z)
		E = created_field[3]
		E.loc = locate(T.x + 2,T.y,T.z)
		E = created_field[4]
		E.loc = locate(T.x + 2,T.y - 1,T.z)
		E = created_field[5]
		E.loc = locate(T.x + 2,T.y - 2,T.z)
		E = created_field[6]
		E.loc = locate(T.x + 1,T.y + 2,T.z)
		E = created_field[7]
		E.loc = locate(T.x + 1,T.y - 2,T.z)
		E = created_field[8]
		E.loc = locate(T.x,T.y + 2,T.z)
		E = created_field[9]
		E.loc = locate(T.x,T.y - 2,T.z)
		E = created_field[10]
		E.loc = locate(T.x - 1,T.y + 2,T.z)
		E = created_field[11]
		E.loc = locate(T.x - 1,T.y - 2,T.z)
		E = created_field[12]
		E.loc = locate(T.x - 2,T.y + 2,T.z)
		E = created_field[13]
		E.loc = locate(T.x - 2,T.y + 1,T.z)
		E = created_field[14]
		E.loc = locate(T.x - 2,T.y,T.z)
		E = created_field[15]
		E.loc = locate(T.x - 2,T.y - 1,T.z)
		E = created_field[16]
		E.loc = locate(T.x - 2,T.y - 2,T.z)
