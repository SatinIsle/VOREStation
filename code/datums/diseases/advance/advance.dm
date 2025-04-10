GLOBAL_LIST_EMPTY(archive_diseases)

GLOBAL_LIST_INIT(advance_cures, list(
	REAGENT_ID_SPACEACILLIN,
	REAGENT_ID_ORANGEJUICE,
	REAGENT_ID_ETHANOL,
	REAGENT_ID_GLUCOSE,
	REAGENT_ID_COPPER,
	REAGENT_ID_LEAD,
	REAGENT_ID_LITHIUM,
	REAGENT_ID_RADIUM,
	REAGENT_ID_MERCURY,
	REAGENT_ID_BLISS,
	REAGENT_ID_MUTAGEN,
	REAGENT_ID_PHORON,
	REAGENT_ID_SACID
))

/datum/disease/advance
	name = "Unknown"
	desc = "An engineered disease which can contain a multitude of symptoms."
	form = "Advance Disease"
	agent = "advance microbes"
	max_stages = 5
	disease_flags = CURABLE|CAN_CARRY|CAN_RESIST|CAN_NOT_POPULATE
	spread_text = "Unknown"
	viable_mobtypes = list(/mob/living/carbon/human)

	var/s_processing = FALSE
	var/list/symptoms = list()
	var/id = ""

/datum/disease/advance/New(process = 1, datum/disease/advance/D)
	if(!istype(D))
		D = null

	if(!symptoms || !length(symptoms))

		if(!D || !D.symptoms || !length(D.symptoms))
			symptoms = GenerateSymptoms(0, 2)
		else
			for(var/datum/symptom/S in D.symptoms)
				symptoms += new S.type

	Refresh()
	..(process, D)
	return

/datum/disease/advance/Destroy()
	if(s_processing)
		for(var/datum/symptom/S in symptoms)
			S.End(src)
	return ..()

/datum/disease/advance/stage_act()
	if(!..())
		return FALSE
	if(symptoms && length(symptoms))

		if(!s_processing)
			s_processing = TRUE
			for(var/datum/symptom/S in symptoms)
				S.Start(src)

		for(var/datum/symptom/S in symptoms)
			S.Activate(src)
	else
		CRASH("We do not have any symptoms during stage_act()!")
	return TRUE

/datum/disease/advance/IsSame(datum/disease/advance/D)
	if(ispath(D))
		return FALSE

	if(!istype(D, /datum/disease/advance))
		return FALSE

	if(GetDiseaseID() != D.GetDiseaseID())
		return FALSE

	return TRUE

/datum/disease/advance/cure(resistance=1)
	if(affected_mob)
		var/id = "[GetDiseaseID()]"
		if(resistance && !(id in affected_mob.GetResistances()))
			affected_mob.GetResistances()[id] = id
		remove_virus()
	qdel(src)

/datum/disease/advance/Copy(process = 0)
	return new /datum/disease/advance(process, src, 1)

/datum/disease/advance/proc/Mix(datum/disease/advance/D)
	if(!(IsSame(D)))
		var/list/possible_symptoms = shuffle(D.symptoms)
		for(var/datum/symptom/S in possible_symptoms)
			AddSymptom(new S.type)

/datum/disease/advance/proc/HasSymptom(datum/symptom/S)
	for(var/datum/symptom/symp in symptoms)
		if(symp.id == S.id)
			return 1
	return 0

/datum/disease/advance/proc/GenerateSymptomsBySeverity(sev_min, sev_max, amount = 1)

	var/list/generated = list()

	var/list/possible_symptoms = list()
	for(var/symp in GLOB.list_symptoms)
		var/datum/symptom/S = new symp
		if(S.severity >= sev_min && S.severity <= sev_max)
			if(!HasSymptom(S))
				possible_symptoms += S

	if(!length(possible_symptoms))
		return generated

	for(var/i = 1 to amount)
		generated += pick_n_take(possible_symptoms)

	return generated

/datum/disease/advance/proc/GenerateSymptoms(level_min, level_max, amount_get = 0)

	var/list/generated = list()

	// Generate symptoms. By default, we only choose non-deadly symptoms.
	var/list/possible_symptoms = list()
	for(var/symp in GLOB.list_symptoms)
		var/datum/symptom/S = new symp
		if(S.level >= level_min && S.level <= level_max)
			if(!HasSymptom(S))
				possible_symptoms += S

	if(!length(possible_symptoms))
		return generated

	// Random chance to get more than one symptom
	var/number_of = amount_get
	if(!amount_get)
		number_of = 1
		while(prob(20))
			number_of += 1

	for(var/i = 1; number_of >= i && length(possible_symptoms); i++)
		generated += pick_n_take(possible_symptoms)

	return generated

/datum/disease/advance/proc/Refresh(new_name = FALSE, archive = FALSE)
	var/list/properties = GenerateProperties()
	AssignProperties(properties)
	id = null

	if(!GLOB.archive_diseases[GetDiseaseID()])
		if(new_name)
			AssignName()
		GLOB.archive_diseases[GetDiseaseID()] = src // So we don't infinite loop
		GLOB.archive_diseases[GetDiseaseID()] = new /datum/disease/advance(0, src, 1)

	var/datum/disease/advance/A = GLOB.archive_diseases[GetDiseaseID()]
	AssignName(A.name)

/datum/disease/advance/proc/GenerateProperties()

	if(!symptoms || !length(symptoms))
		CRASH("We did not have any symptoms before generating properties.")

	var/list/properties = list("resistance" = 1, "stealth" = 0, "stage rate" = 1, "transmittable" = 1, "severity" = 0)

	for(var/datum/symptom/S in symptoms)

		properties["resistance"] += S.resistance
		properties["stealth"] += S.stealth
		properties["stage rate"] += S.stage_speed
		properties["transmittable"] += S.transmittable
		properties["severity"] = max(properties["severity"], S.severity) // severity is based on the highest severity symptom

	return properties

/datum/disease/advance/proc/AssignProperties(list/properties = list())

	if(properties && length(properties))
		switch(properties["stealth"])
			if(2)
				visibility_flags = HIDDEN_SCANNER
			if(3 to INFINITY)
				visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC

		// The more symptoms we have, the less transmittable it is but some symptoms can make up for it.
		SetSpread(clamp(2 ** (properties["transmittable"] - length(symptoms)), BLOOD, AIRBORNE))
		permeability_mod = max(CEILING(0.4 * properties["transmittable"], 1), 1)
		cure_chance = 15 - clamp(properties["resistance"], -5, 5) // can be between 10 and 20
		stage_prob = max(properties["stage rate"], 2)
		SetSeverity(properties["severity"])
		GenerateCure(properties)
	else
		CRASH("Our properties were empty or null!")

/datum/disease/advance/proc/SetSpread(spread_id)
	switch(spread_id)
		if(NON_CONTAGIOUS, SPECIAL)
			spread_text = "Non-contagious"
		if(CONTACT_GENERAL, CONTACT_HANDS, CONTACT_FEET)
			spread_text = "On contact"
		if(AIRBORNE)
			spread_text = "Airborne"
		if(BLOOD)
			spread_text = "Blood"

	spread_flags = spread_id

/datum/disease/advance/proc/SetSeverity(level_sev)

	switch(level_sev)

		if(-INFINITY to 0)
			severity = NONTHREAT
		if(1)
			severity = MINOR
		if(2)
			severity = MEDIUM
		if(3)
			severity = HARMFUL
		if(4)
			severity = DANGEROUS
		if(5 to INFINITY)
			severity = BIOHAZARD
		else
			severity = "Unknown"

/datum/disease/advance/proc/GenerateCure(list/properties = list())
	if(properties && length(properties))
		var/res = clamp(properties["resistance"] - (length(symptoms) / 2), 1, length(GLOB.advance_cures))
		cures = list(GLOB.advance_cures[res])
		cure_text = cures[1]
	return

// Randomly generate a symptom, has a chance to lose or gain a symptom.
/datum/disease/advance/proc/Evolve(min_level, max_level)
	var/s = safepick(GenerateSymptoms(min_level, max_level, 1))
	if(s)
		AddSymptom(s)
		Refresh(1)
	return

/datum/disease/advance/proc/PickyEvolve(var/list/datum/symptom/D)
	var/s = safepick(D)
	if(s)
		AddSymptom(new s)
		Refresh(1)
	return

// Randomly remove a symptom.
/datum/disease/advance/proc/Devolve()
	if(length(symptoms) > 1)
		var/s = safepick(symptoms)
		if(s)
			RemoveSymptom(s)
			Refresh(1)
	return

// Name the disease.
/datum/disease/advance/proc/AssignName(name = "Unknown")
	src.name = name
	return

// Return a unique ID of the disease.
/datum/disease/advance/GetDiseaseID()
	if(!id)
		var/list/L = list()
		for(var/datum/symptom/S in symptoms)
			L += S.id
		L = sortList(L) // Sort the list so it doesn't matter which order the symptoms are in.
		var/result = jointext(L, ":")
		id = result
	return id

// Add a symptom, if it is over the limit (with a small chance to be able to go over)
// we take a random symptom away and add the new one.
/datum/disease/advance/proc/AddSymptom(datum/symptom/S)

	if(HasSymptom(S))
		return

	if(length(symptoms) < (VIRUS_SYMPTOM_LIMIT - 1) + rand(-1, 1))
		symptoms += S
	else
		RemoveSymptom(pick(symptoms))
		symptoms += S
	return

// Simply removes the symptom.
/datum/disease/advance/proc/RemoveSymptom(datum/symptom/S)
	symptoms -= S
	return

// Mix a list of advance diseases and return the mixed result.
/proc/Advance_Mix(list/D_list)

	var/list/diseases = list()

	for(var/datum/disease/advance/A in D_list)
		diseases += A.Copy()

	if(!length(diseases))
		return null
	if(length(diseases) <= 1)
		return pick(diseases) // Just return the only entry.

	var/i = 0
	// Mix our diseases until we are left with only one result.
	while(i < 20 && length(diseases) > 1)

		i++

		var/datum/disease/advance/D1 = pick(diseases)
		diseases -= D1

		var/datum/disease/advance/D2 = pick(diseases)
		D2.Mix(D1)

	// Should be only 1 entry left, but if not let's only return a single entry
	var/datum/disease/advance/to_return = pick(diseases)
	to_return.Refresh(1)
	return to_return

/proc/SetViruses(datum/reagent/R, list/data)
	if(data)
		var/list/preserve = list()
		if(istype(data) && data["viruses"])
			for(var/datum/disease/A in data["viruses"])
				preserve += A.Copy()
			R.data = data.Copy()
		if(length(preserve))
			R.data["viruses"] = preserve

/client/proc/AdminCreateVirus()
	set category = "Fun.Event Kit"
	set name = "Create Advanced Virus"
	set desc = "Create an advanced virus and release it."

	if(!is_admin())
		return FALSE

	var/i = VIRUS_SYMPTOM_LIMIT
	var/mob/living/carbon/human/H = null

	var/datum/disease/advance/D = new(0, null)
	D.symptoms = list()

	var/list/symptoms = list()
	symptoms += "Done"
	symptoms += GLOB.list_symptoms.Copy()
	do
		if(usr)
			var/symptom = tgui_input_list(usr, "Choose a symptom to add ([i] remaining)", "Choose a Symptom", symptoms)
			if(isnull(symptom))
				return
			else if(istext(symptom))
				i = 0
			else if(ispath(symptom))
				var/datum/symptom/S = new symptom
				if(!D.HasSymptom(S))
					D.symptoms += S
					i -= 1
	while(i > 0)

	if(length(D.symptoms) > 0)

		var/new_name = tgui_input_text(usr, "Name your new disease.", "New Name")
		if(!new_name)
			return FALSE
		D.AssignName(new_name)
		D.Refresh()

		for(var/datum/disease/advance/AD in active_diseases)
			AD.Refresh()

		H = tgui_input_list(usr, "Choose infectee", "Infectees", human_mob_list)

		if(isnull(H))
			return FALSE

		if(!H.HasDisease(D))
			H.ForceContractDisease(D)

		var/list/name_symptoms = list()
		for(var/datum/symptom/S in D.symptoms)
			name_symptoms += S.name
		message_admins("[key_name_admin(usr)] has triggered a custom virus outbreak of [D.name]! It has these symptoms: [english_list(name_symptoms)]")
		log_admin("[key_name_admin(usr)] infected [key_name_admin(H)] with [D.name]. It has these symptoms: [english_list(name_symptoms)]")

		return TRUE

/datum/disease/advance/proc/totalStageSpeed()
	var/total_stage_speed = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_stage_speed += S.stage_speed
	return total_stage_speed

/datum/disease/advance/proc/totalStealth()
	var/total_stealth = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_stealth += S.stealth
	return total_stealth

/datum/disease/advance/proc/totalResistance()
	var/total_resistance = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_resistance += S.resistance
	return total_resistance

/datum/disease/advance/proc/totalTransmittable()
	var/total_transmittable = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_transmittable += S.transmittable
	return total_transmittable
