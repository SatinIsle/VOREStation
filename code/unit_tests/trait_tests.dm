/datum/unit_test/all_traits_unique_names
	name = "TRAITS: All traits shall have unique names"

/datum/unit_test/all_traits_unique_names/start_test()
	var/failed = FALSE

	var/list/used_named = list()
	for(var/traitpath in GLOB.all_traits)
		var/datum/trait/T = GLOB.all_traits[traitpath]
		if(T.name in used_named)
			log_unit_test("[T.type]: Trait - The name \"[T.name]\" is already in use.")
			failed = TRUE
		else
			used_named.Add(T.name)

	if(failed)
		fail("One or more traits shared a name.")
	else
		pass("All [GLOB.all_traits.len] have unique names.")
	return failed


/datum/unit_test/autohiss_shall_be_exclusive
	name = "TRAITS: Autohiss traits shall be exclusive"

/datum/unit_test/autohiss_shall_be_exclusive/start_test()
	var/failed = FALSE

	var/list/hiss_list = list()
	for(var/traitpath in GLOB.all_traits)
		var/datum/trait/T = GLOB.all_traits[traitpath]
		if(!T.var_changes)
			continue
		if(!islist(T.var_changes["autohiss_basic_map"]))
			continue
		hiss_list += T

	for(var/datum/trait/T in hiss_list)
		if(T.type in T.excludes)
			log_unit_test("[T.type]: Trait - Autohiss excludes itself.")
			failed = TRUE

		if(!T.excludes)
			log_unit_test("[T.type]: Trait - Autohiss missing exclusion list.")
			failed = TRUE
			continue

		var/list/exempt_list = hiss_list.Copy() - T // MUST exclude all others except itself
		for(var/datum/trait/EX in exempt_list)
			if(!(EX.type in T.excludes))
				log_unit_test("[T.type]: Trait - Autohiss missing exclusion for [EX].")
				failed = TRUE

	if(failed)
		fail("One or more autohiss traits allow another autohiss to be chosen with it.")
	else
		pass("All [hiss_list.len] autohiss traits are properly exclusive.")
	return failed
