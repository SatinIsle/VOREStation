/datum/trait/positive
	category = TRAIT_TYPE_POSITIVE

/datum/trait/positive/speed_fast
	name = "Haste"
	desc = "Allows you to move faster on average than baseline."
	cost = 4
	var_changes = list("slowdown" = -0.5)
//	banned_species = list(SPECIES_ALRAUNE, SPECIES_SHADEKIN_CREW, SPECIES_TESHARI, SPECIES_TAJARAN, SPECIES_DIONA, SPECIES_UNATHI) //Either not applicable or buffs ruin species flavour/balance
//	custom_only = FALSE //Keeping these in comments in case we decide to open them up in future, so the species are already organised.

	// Traitgenes Replaces /datum/trait/positive/superpower_increaserun, made into a genetrait
	is_genetrait = TRUE
	hidden = FALSE

	activation_message="Your leg muscles pulsate."
	primitive_expression_messages=list("dances around.")
	excludes = list(/datum/trait/positive/unusual_running) // you best not be naruto running in this house

/datum/trait/positive/unusual_running
	name = "Unusual Gait"
	desc = "Your method of running is unorthodox, you move faster when not holding things in your hands."
	cost = 2
	var_changes = list("unusual_running" = 1)

	custom_only = FALSE //I think this is probably fine since it's half RP trait and half mechanical trait. also you can't have speed and use your hands so this is kinda niche outside of travel time reduction.
	banned_species = list(SPECIES_ALRAUNE, SPECIES_SHADEKIN_CREW, SPECIES_TESHARI, SPECIES_TAJARAN, SPECIES_DIONA, SPECIES_UNATHI, SPECIES_VASILISSAN, SPECIES_XENOCHIMERA, SPECIES_VOX) //i assume if a dev made your base slowdown different then you shouldn't have this.
	excludes = list(/datum/trait/positive/speed_fast) // olympic sprinters don't naruto run

/datum/trait/positive/punchdamage
	name = "Strong Attacks"
	desc = "Your unarmed attacks deal more damage. (+5 per attack)"
	cost = 1
	custom_only = FALSE
	hidden = TRUE //Disabled on Virgo.
	var_changes = list("unarmed_bonus" = 5)
	excludes = list(/datum/trait/positive/punchdamageplus)
	banned_species = list(SPECIES_TESHARI)

/datum/trait/positive/punchdamageplus
	name = "Crushing Attacks"
	desc = "Your unarmed attacks deal high damage. (+10 per attack)"
	cost = 2
	custom_only = FALSE
	hidden = TRUE //Disabled on Virgo.
	var_changes = list("unarmed_bonus" = 10)
	excludes = list(/datum/trait/positive/punchdamage)
	banned_species = list(SPECIES_TESHARI, SPECIES_VOX)

/datum/trait/positive/shredding_attacks //Variant of plus
	name = "Shredding Attacks"
	desc = "Your unarmed attacks can break windows, APCs, deal massive damage to synthetics, and you can break out of restraints 24 times faster."
	cost = 6
	custom_only = FALSE
	hidden = TRUE
	var_changes = list("shredding" = TRUE)
	banned_species = list(SPECIES_TESHARI, SPECIES_VOX)

/datum/trait/positive/strength //combine effects of hardy + strong punches, for if someone wants a generally "strong" character. Exists for the purposes of the trait limit
	name = "High Strength"
	desc = "Your unarmed attacks deal more damage (+5), and you can carry heavy equipment with 50% less slowdown."
	cost = 2
	custom_only = FALSE
	hidden = TRUE //Disabled on Virgo.
	var_changes = list("unarmed_bonus" = 5, "item_slowdown_mod" = 0.5)
	excludes = list(/datum/trait/positive/punchdamage, /datum/trait/positive/hardy, /datum/trait/positive/hardy_plus)
	banned_species = list(SPECIES_ALRAUNE, SPECIES_TESHARI, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_PROMETHEAN, SPECIES_PROTEAN)

/datum/trait/positive/strengthplus //see above comment
	name = "Inhuman Strength"
	desc = "You are unreasonably strong. Your unarmed attacks do high damage (+10), you experience much less slowdown from heavy equipment (75% less)."
	cost = 4
	custom_only = FALSE
	hidden = TRUE //Disabled on Virgo.
	var_changes = list("unarmed_bonus" = 10, "item_slowdown_mod" = 0.25)
	excludes = list(/datum/trait/positive/punchdamage, /datum/trait/positive/hardy, /datum/trait/positive/punchdamageplus, /datum/trait/positive/hardy_plus)
	banned_species = list(SPECIES_ALRAUNE, SPECIES_TESHARI, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_PROMETHEAN, SPECIES_PROTEAN, SPECIES_VOX)

/datum/trait/positive/hardy
	name = "Hardy"
	desc = "Allows you to carry heavy equipment with less slowdown."
	cost = 1
	var_changes = list("item_slowdown_mod" = 0.5)
	custom_only = FALSE
	banned_species = list(SPECIES_ALRAUNE, SPECIES_TESHARI, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_PROMETHEAN, SPECIES_PROTEAN) //Either not applicable or buffs are too strong

/datum/trait/positive/hardy_plus
	name = "Hardy, Major"
	desc = "Allows you to carry heavy equipment with almost no slowdown."
	cost = 2
	var_changes = list("item_slowdown_mod" = 0.25)
	banned_species = list(SPECIES_ALRAUNE, SPECIES_TESHARI, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_PROMETHEAN, SPECIES_PROTEAN) //Either not applicable or buffs are too strong
	custom_only = FALSE

/datum/trait/positive/endurance_high
	name = "High Endurance"
	desc = "Increases your maximum total hitpoints to 125. You require 250 damage in total to die, compared to 200 normally. You will still go into crit after losing 125 HP, compared to crit at 100 HP."
	cost = 3
	var_changes = list("total_health" = 125)
	custom_only = FALSE
	banned_species = list(SPECIES_TESHARI, SPECIES_UNATHI, SPECIES_SHADEKIN_CREW) //Either not applicable or buffs are too strong

/datum/trait/positive/endurance_high/apply(var/datum/species/S,var/mob/living/carbon/human/H)
	..()
	H.setMaxHealth(S.total_health)

/datum/trait/positive/nonconductive
	name = "Non-Conductive"
	desc = "Decreases your susceptibility to electric shocks by 25%."
	cost = 2
	var_changes = list("siemens_coefficient" = 0.75)

/datum/trait/positive/nonconductive_plus
	name = "Non-Conductive, Major"
	desc = "Decreases your susceptibility to electric shocks by 50%."
	cost = 3
	var_changes = list("siemens_coefficient" = 0.5)

/datum/trait/positive/darksight
	name = "Darksight"
	desc = "Allows you to see a short distance in the dark and 10% more susceptible to flashes."
	cost = 1
	var_changes = list("darksight" = 5, "flash_mod" = 1.1)
	custom_only = FALSE
	banned_species = list(SPECIES_TAJARAN, SPECIES_SHADEKIN_CREW, SPECIES_SHADEKIN, SPECIES_XENOHYBRID, SPECIES_VULPKANIN, SPECIES_XENO, SPECIES_XENOCHIMERA, SPECIES_VASILISSAN, SPECIES_WEREBEAST) //These species already have strong darksight by default.

/datum/trait/positive/darksight_plus
	name = "Darksight, Major"
	desc = "Allows you to see in the dark for almost the whole screen and 20% more susceptible to flashes."
	cost = 2
	var_changes = list("darksight" = 8, "flash_mod" = 1.2)
	custom_only = FALSE
	banned_species = list(SPECIES_TAJARAN, SPECIES_SHADEKIN_CREW, SPECIES_SHADEKIN, SPECIES_XENOHYBRID, SPECIES_VULPKANIN, SPECIES_XENO, SPECIES_XENOCHIMERA, SPECIES_VASILISSAN, SPECIES_WEREBEAST) //These species already have strong darksight by default.

/datum/trait/positive/melee_attack
	name = "Special Attack: Sharp Melee" // Trait Organization for easier browsing. TODO: Proper categorization of 'health/ability/resist/etc'
	desc = "Provides sharp melee attacks that do slightly more damage."
	cost = 1
	var_changes = list("unarmed_types" = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws, /datum/unarmed_attack/bite/sharp))

/datum/trait/positive/melee_attack_fangs
	name = "Special Attack: Sharp Melee & Numbing Fangs" // Trait Organization for easier browsing. TODO: Proper categorization of 'health/ability/resist/etc'
	desc = "Provides sharp melee attacks that do slightly more damage, along with fangs that makes the person bit unable to feel their body or pain."
	cost = 2
	var_changes = list("unarmed_types" = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws, /datum/unarmed_attack/bite/sharp, /datum/unarmed_attack/bite/sharp/numbing))

/datum/trait/positive/fangs
	name = "Special Attack: Numbing Fangs" // Trait Organization for easier browsing. TODO: Proper categorization of 'health/ability/resist/etc'
	desc = "Provides fangs that makes the person bit unable to feel their body or pain."
	cost = 1
	var_changes = list("unarmed_types" = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite/sharp/numbing))

/datum/trait/positive/minor_brute_resist
	name = "Brute Resist, Minor"
	desc = "Adds 15% resistance to brute damage sources."
	cost = 2
	var_changes = list("brute_mod" = 0.85)
	custom_only = FALSE
	banned_species = list(SPECIES_TESHARI, SPECIES_UNATHI, SPECIES_XENOCHIMERA, SPECIES_VASILISSAN, SPECIES_WEREBEAST) //Most of these are already this resistant or stronger, or it'd be way too much of a boost for tesh.

/datum/trait/positive/brute_resist
	name = "Brute Resist"
	desc = "Adds 25% resistance to brute damage sources."
	cost = 3
	var_changes = list("brute_mod" = 0.75)
	excludes = list(/datum/trait/positive/minor_burn_resist,/datum/trait/positive/burn_resist)

/datum/trait/positive/minor_burn_resist
	name = "Burn Resist, Minor"
	desc = "Adds 15% resistance to burn damage sources."
	cost = 2
	var_changes = list("burn_mod" = 0.85)

/datum/trait/positive/burn_resist
	name = "Burn Resist"
	desc = "Adds 25% resistance to burn damage sources."
	cost = 3
	var_changes = list("burn_mod" = 0.75)
	excludes = list(/datum/trait/positive/minor_brute_resist,/datum/trait/positive/brute_resist)

/datum/trait/positive/photoresistant
	name = "Photoresistant"
	desc = "Decreases stun duration from flashes and other light-based stuns and disabilities by 20%"
	cost = 1
	var_changes = list("flash_mod" = 0.8)

/datum/trait/positive/winged_flight
	name = "Winged Flight"
	desc = "Allows you to fly by using your wings. Don't forget to bring them!"
	cost = 0
	custom_only = FALSE
	has_preferences = list("flight_vore" = list(TRAIT_PREF_TYPE_BOOLEAN, "Flight Vore enabled on spawn", TRAIT_VAREDIT_TARGET_MOB, FALSE))

/datum/trait/positive/winged_flight/apply(var/datum/species/S,var/mob/living/carbon/human/H)
	..()
	add_verb(H, /mob/living/proc/flying_toggle)
	add_verb(H, /mob/living/proc/flying_vore_toggle)
	add_verb(H, /mob/living/proc/start_wings_hovering)

/datum/trait/positive/soft_landing
	name = "Soft Landing"
	desc = "You can fall from certain heights without suffering any injuries, be it via wings, lightness of frame or general dexterity."
	cost = 1
	var_changes = list("soft_landing" = TRUE)
	custom_only = FALSE

/datum/trait/positive/hardfeet
	name = "Hard Feet"
	desc = "Makes your nice clawed, scaled, hooved, armored, or otherwise just awfully calloused feet immune to glass shards."
	cost = 0
	allowed_species = list(SPECIES_HANNER, SPECIES_CUSTOM) //So it only shows up for custom species and hanner
	custom_only = FALSE
	var_changes = list("flags" = NO_MINOR_CUT) //Checked the flag is only used by shard stepping.

/datum/trait/positive/antiseptic_saliva
	name = "Antiseptic Saliva"
	desc = "Your saliva has especially strong antiseptic properties that can be used to heal small wounds."
	cost = 1

/datum/trait/positive/antiseptic_saliva/apply(var/datum/species/S,var/mob/living/carbon/human/H)
	..()
	add_verb(H, /mob/living/carbon/human/proc/lick_wounds)

/datum/trait/positive/traceur
	name = "Traceur"
	desc = "You're capable of parkour and can *flip over low objects (most of the time)."
	cost = 2
	var_changes = list("agility" = 90)
	custom_only = FALSE
	varchange_type = TRAIT_VARCHANGE_MORE_BETTER

/datum/trait/positive/snowwalker
	name = "Snow Walker"
	desc = "You are able to move unhindered on snow."
	cost = 1
	var_changes = list("snow_movement" = -2)

/datum/trait/positive/weaver
	name = "Weaver"
	desc = "You can produce silk and create various articles of clothing and objects."
	cost = 2
	allowed_species = list(SPECIES_HANNER, SPECIES_CUSTOM) //So it only shows up for custom species and hanner
	custom_only = FALSE
	has_preferences = list("silk_production" = list(TRAIT_PREF_TYPE_BOOLEAN, "Silk production on spawn", TRAIT_NO_VAREDIT_TARGET), \
							"silk_color" = list(TRAIT_PREF_TYPE_COLOR, "Silk color", TRAIT_NO_VAREDIT_TARGET))
	added_component_path = /datum/component/weaver

/datum/trait/positive/weaver/apply(var/datum/species/S,var/mob/living/carbon/human/H, var/list/trait_prefs)
	..()
	var/datum/component/weaver/W = H.GetComponent(added_component_path)
	if(S.get_bodytype() == SPECIES_VASILISSAN)
		W.silk_reserve = 500
		W.silk_max_reserve = 1000
	if(trait_prefs)
		W.silk_production = trait_prefs["silk_production"]
		W.silk_color = lowertext(trait_prefs["silk_color"])

/datum/trait/positive/aquatic
	name = "Aquatic"
	desc = "You can breathe under water and can traverse water more efficiently. Additionally, you can eat others in the water."
	cost = 1
	custom_only = FALSE
	var_changes = list("water_breather" = 1, "water_movement" = -4) //Negate shallow water. Half the speed in deep water.
	allowed_species = list(SPECIES_HANNER, SPECIES_CUSTOM) //So it only shows up for custom species and hanner
	custom_only = FALSE

/datum/trait/positive/aquatic/apply(var/datum/species/S,var/mob/living/carbon/human/H)
	..()
	add_verb(H, /mob/living/carbon/human/proc/water_stealth)
	add_verb(H, /mob/living/carbon/human/proc/underwater_devour)

/datum/trait/positive/cocoon_tf
	name = "Cocoon Spinner"
	desc = "Allows you to build a cocoon around yourself, using it to transform your body if you desire."
	cost = 1
	allowed_species = list(SPECIES_HANNER, SPECIES_CUSTOM) //So it only shows up for custom species and hanner
	custom_only = FALSE

/datum/trait/positive/cocoon_tf/apply(var/datum/species/S,var/mob/living/carbon/human/H)
	..()
	add_verb(H, /mob/living/carbon/human/proc/enter_cocoon)

/datum/trait/positive/linguist
	name = "Linguist"
	desc = "Allows you to have more languages."
	cost = 1
	var_changes = list("num_alternate_languages" = 6)
	var_changes_pref = list("extra_languages" = 3)
	custom_only = FALSE
	varchange_type = TRAIT_VARCHANGE_MORE_BETTER

/datum/trait/positive/good_shooter
	name = "Eagle Eye"
	desc = "You are better at aiming than most."
	cost = 2
	var_changes = list("gun_accuracy_mod" = 25)
	custom_only = FALSE
	varchange_type = TRAIT_VARCHANGE_MORE_BETTER

/datum/trait/positive/pain_tolerance
	name = "Grit"
	desc = "You can keep going a little longer, a little harder when you get hurt, Injuries only inflict 85% as much pain, and slowdown from pain is 85% as effective."
	cost = 2
	var_changes = list("trauma_mod" = 0.85)
	excludes = list(/datum/trait/negative/neural_hypersensitivity)
	can_take = ORGANICS
	custom_only = FALSE

/datum/trait/positive/throw_resistance
	name = "Firm Body"
	desc = "Your body is firm enough that small thrown items can't do anything to you."
	cost = 1
	var_changes = list("throwforce_absorb_threshold" = 10)

/datum/trait/positive/wall_climber
	name = "Climber, Amateur"
	desc = "You can climb certain walls without tools! This is likely a personal skill you developed. You can also climb lattices and ladders a little bit faster than everyone else."
	tutorial = "You must approach a wall and right click it and select the \
	'climb wall' verb to climb it. You suffer from a movement delay of 1.5 with this trait.\n \
	Your total climb time is expected to be 17.5 seconds. Tools may reduce this. \n\n \
	This likewise allows descending walls, provided you're facing an empty space and standing on \
	a climbable wall. To climbe like so, use the verb 'Climb Down Wall' in IC tab!"
	cost = 1
	custom_only = FALSE
	banned_species = list(SPECIES_TAJARAN, SPECIES_VASILISSAN)	// They got unique climbing delay.
	var_changes = list("can_climb" = TRUE, "climb_mult" = 0.75)
	excludes = list(/datum/trait/positive/wall_climber_pro, /datum/trait/positive/wall_climber_natural)

/datum/trait/positive/wall_climber_natural
	name = "Climber, Natural"
	desc = "You can climb certain walls without tools! This is likely due to the unique anatomy of your species. You can climb lattices and ladders slightly faster than everyone else. CUSTOM AND XENOCHIM ONLY"
	tutorial = "You must approach a wall and right click it and select the \
	'climb wall' verb to climb it. You suffer from a movement delay of 1.5 with this trait.\n \
	Your total climb time is expected to be 17.5 seconds. Tools may reduce this. \n\n \
	This likewise allows descending walls, provided you're facing an empty space and standing on \
	a climbable wall. To climbe like so, use the verb 'Climb Down Wall' in IC tab!"
	cost = 0
	custom_only = FALSE
	var_changes = list("can_climb" = TRUE, "climb_mult" = 0.75)
	allowed_species = list(SPECIES_XENOCHIMERA, SPECIES_CUSTOM)	//So that we avoid needless bloat for xenochim
	excludes = list(/datum/trait/positive/wall_climber_pro, /datum/trait/positive/wall_climber)

/datum/trait/positive/wall_climber_pro
	name = "Climber, Professional"
	desc = "You can climb certain walls without tools! You are a professional rock climber at this, letting you climb almost twice as fast! You can also climb lattices and ladders a fair bit faster than everyone else!"
	tutorial = "You must approach a wall and right click it and select the \
	'climb wall' verb to climb it. Your movement delay is just 1.25 with this trait.\n \
	Your climb time is expected to be 9 seconds. Tools may reduce this. \n\n \
	This likewise allows descending walls, provided you're facing an empty space and standing on \
	a climbable wall. To climbe like so, use the verb 'Climb Down Wall' in IC tab!"
	cost = 2
	custom_only = FALSE
	var_changes = list("climbing_delay" = 1.25, "climb_mult" = 0.5)
	varchange_type = TRAIT_VARCHANGE_LESS_BETTER
	excludes = list(/datum/trait/positive/wall_climber,/datum/trait/positive/wall_climber_natural)

// This feels jank, but it's the cleanest way I could do TRAIT_VARCHANGE_LESS_BETTER while having a boolean var change
// Alternate would've been banned_species = list(SPECIES_TAJARAN, SPECIES_VASSILISIAN)
// Opted for this as it's "future proof"
/datum/trait/positive/wall_climber_pro/apply(var/datum/species/S,var/mob/living/carbon/human/H)
	..()
	S.can_climb = TRUE

/datum/trait/positive/good_swimmer
	name = "Pro Swimmer"
	desc = "You were top of your group in swimming class! This is of questionable usefulness on most planets, but hey, maybe you'll get to visit a nice beach world someday?"
	tutorial = "You move faster in water, and can move up and down z-levels faster than other swimmers!"
	cost = 1
	custom_only = FALSE
	var_changes = list("water_movement" = -2, "swim_mult" = 0.5)
	varchange_type = TRAIT_VARCHANGE_LESS_BETTER
	excludes = list(/datum/trait/negative/bad_swimmer)
	banned_species = list(SPECIES_AKULA)	// They already swim better than this

/datum/trait/positive/table_passer
	name = "Table Passer"
	desc = "You move over or under tables with ease of a Teshari."
	cost = 2

	// Traitgenes Replacement for /datum/trait/positive/superpower_midget, made into a genetrait
	is_genetrait = TRUE
	hidden = FALSE
	activation_message="Your skin feels rubbery."

	has_preferences = list("pass_table" = list(TRAIT_PREF_TYPE_BOOLEAN, "On spawn", TRAIT_NO_VAREDIT_TARGET, TRUE))

/datum/trait/positive/table_passer/apply(var/datum/species/S,var/mob/living/carbon/human/H, var/list/trait_prefs)
	..()
	if(trait_prefs?["pass_table"] || !trait_prefs)
		H.pass_flags |= PASSTABLE
	add_verb(H,/mob/living/proc/toggle_pass_table)

// Traitgenes All genetraits need an unapply proc if they do anything special
/datum/trait/positive/table_passer/unapply(datum/species/S, mob/living/carbon/human/H)
	. = ..()
	if (H.pass_flags & PASSTABLE)
		H.pass_flags ^= PASSTABLE
	if(!(/mob/living/proc/toggle_pass_table in S.inherent_verbs)) // Teshari shouldn't lose agility
		remove_verb(H,/mob/living/proc/toggle_pass_table)

/datum/trait/positive/photosynth
	name = "Photosynthesis"
	desc = "Your body is able to produce nutrition from being in light."
	cost = 3
	can_take = ORGANICS|SYNTHETICS //Synths actually use nutrition, just with a fancy covering.
	added_component_path = /datum/component/photosynth

/datum/trait/positive/rad_resistance
	name = "Radiation Resistance"
	desc = "You are generally more resistant to radiation, and it dissipates faster from your body."
	cost = 1
	var_changes = list("radiation_mod" = 0.65, "rad_removal_mod" = 3.5, "rad_levels" = RESISTANT_RADIATION_RESISTANCE)

/datum/trait/positive/rad_resistance_extreme
	name = "Radiation Resistance, Major"
	desc = "You are much more resistant to radiation, and it dissipates much faster from your body."
	cost = 2
	var_changes = list("radiation_mod" = 0.5, "rad_removal_mod" = 5, "rad_levels" = MAJOR_RESISTANT_RADIATION_RESISTANCE)

/datum/trait/positive/rad_immune
	name = "Radiation Immunity"
	desc = "For whatever reason, be it a more dense build or some quirk of your genetic code, your body is completely immune to radiation."
	cost = 3
	var_changes = list("radiation_mod" = 0.0, "rad_removal_mod" = 10, "rad_levels" = IMMUNITY_RADIATION_RESISTANCE)

	// Traitgenes
	is_genetrait = TRUE
	hidden = FALSE
	activation_message="Your body feels mundane."

/datum/trait/positive/vibration_sense
	name = "Vibration Sense"
	desc = "Allows you to sense subtle vibrations nearby, even if the source cannot be seen."
	cost = 2
	var_changes = list("has_vibration_sense" = TRUE)

	// Traitgenes edit begin - Made into a gene trait
	is_genetrait = TRUE
	hidden = FALSE

	activation_message="Your ears ring, and hear everything..."
	// Traitgenes edit end

/datum/trait/positive/vibration_sense/apply(datum/species/S, mob/living/carbon/human/H, trait_prefs)
	. = ..()
	H.motiontracker_subscribe()

/datum/trait/positive/vibration_sense/unapply(datum/species/S, mob/living/carbon/human/H, trait_prefs)
	. = ..()
	H.motiontracker_unsubscribe()

/datum/trait/positive/stable_genetics
	name = "Stable Genetics"
	desc = "Your genetics are extraordinarily stable, with your DNA being immune to any changes, including slimes!"
	cost = 2
	custom_only = TRUE
	var_changes = list("flags" = NO_DNA)

/datum/trait/positive/weaver/xenochimera
	sort = TRAIT_SORT_SPECIES
	allowed_species = list(SPECIES_XENOCHIMERA)
	name = "Xenochimera: Weaver"
	desc = "You've evolved your body to produce silk that you can fashion into articles of clothing and other objects."
	cost = 0
	category = 0
	custom_only = FALSE

/datum/trait/positive/hardfeet/xenochimera
	sort = TRAIT_SORT_SPECIES
	allowed_species = list(SPECIES_XENOCHIMERA)
	name = "Xenochimera: Hard Feet"
	desc = "Your body has adapted to make your feet immune to glass shards, whether by developing hooves, chitin, or just horrible callous."
	cost = 0
	category = 0
	custom_only = FALSE

/datum/trait/positive/melee_attack_fangs/xenochimera
	sort = TRAIT_SORT_SPECIES
	allowed_species = list(SPECIES_XENOCHIMERA)
	name = "Xenochimera: Sharp Melee & Numbing Fangs"
	desc = "Your hunting instincts manifest in earnest! You have grown numbing fangs alongside your naturally grown hunting weapons."
	cost = 0
	category = 0
	custom_only = FALSE
	var_changes = list("unarmed_types" = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws/chimera, /datum/unarmed_attack/bite/sharp, /datum/unarmed_attack/bite/sharp/numbing)) // Fixes the parent forgetting to add 'chimera-specific claws

/datum/trait/positive/snowwalker/xenochimera
	sort = TRAIT_SORT_SPECIES
	allowed_species = list(SPECIES_XENOCHIMERA)
	name = "Xenochimera: Snow Walker"
	desc = "You've adapted to traversing snowy terrain. Snow does not slow you down!"
	cost = 0
	category = 0
	custom_only = FALSE

/datum/trait/positive/aquatic/xenochimera
	sort = TRAIT_SORT_SPECIES
	allowed_species = list(SPECIES_XENOCHIMERA)
	name = "Xenochimera: Aquatic"
	desc = "You can breathe under water and can traverse water more efficiently. Additionally, you can eat others in the water."
	cost = 0
	category = 0
	excludes = list(/datum/trait/positive/winged_flight/xenochimera)
	custom_only = FALSE

/datum/trait/positive/winged_flight/xenochimera
	sort = TRAIT_SORT_SPECIES
	allowed_species = list(SPECIES_XENOCHIMERA)
	name = "Xenochhimera: Winged Flight"
	desc = "Allows you to fly by using your wings. Don't forget to bring them!"
	cost = 0
	excludes = list(/datum/trait/positive/aquatic/xenochimera)
	custom_only = FALSE

/datum/trait/positive/cocoon_tf/xenochimera
	sort = TRAIT_SORT_SPECIES
	allowed_species = list(SPECIES_XENOCHIMERA)
	custom_only = FALSE
	name = "Xenochimera: Cocoon Spinner"
	desc = "Allows you to build a cocoon around yourself, using it to transform your body if you desire."
	cost = 0
	category = 0

/datum/trait/positive/virus_immune
	name = "Virus Immune"
	desc = "You are immune to viruses."
	cost = 1

	can_take = ORGANICS
	var_changes = list("virus_immune" = TRUE)
