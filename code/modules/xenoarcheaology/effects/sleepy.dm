/// Verified to work with the Artifact Harvester
/datum/artifact_effect/sleepy
	name = "Drowsiness"
	effect_color = "#a36fa1"

/datum/artifact_effect/sleepy/New()
	..()
	effect_type = EFFECT_SLEEPY

/datum/artifact_effect/sleepy/DoEffectTouch(var/mob/toucher)
	if(toucher)
		var/weakness = GetAnomalySusceptibility(toucher)
		if(ishuman(toucher) && prob(weakness * 100))
			var/mob/living/carbon/human/H = toucher
			to_chat(H, span_blue("[pick("You feel like taking a nap.","You feel a yawn coming on.","You feel a little tired.")]"))
			H.drowsyness = min(H.drowsyness + rand(5,25) * weakness, 50 * weakness)
			H.eye_blurry = min(H.eye_blurry + rand(1,3) * weakness, 50 * weakness)
			return 1
		else if(isrobot(toucher))
			to_chat(toucher, span_red("SYSTEM ALERT: CPU cycles slowing down."))
			return 1

/datum/artifact_effect/sleepy/DoEffectAura()
	var/atom/holder = get_master_holder()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/carbon/human/H in range(src.effectrange,T))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(prob(10))
					to_chat(H, span_blue("[pick("You feel like taking a nap.","You feel a yawn coming on.","You feel a little tired.")]"))
				H.drowsyness = min(H.drowsyness + 1 * weakness, 25 * weakness)
				H.eye_blurry = min(H.eye_blurry + 1 * weakness, 25 * weakness)
		for (var/mob/living/silicon/robot/R in range(src.effectrange,holder))
			to_chat(R, span_red("SYSTEM ALERT: CPU cycles slowing down."))
		return 1

/datum/artifact_effect/sleepy/DoEffectPulse()
	var/atom/holder = get_master_holder()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/carbon/human/H in range(src.effectrange, T))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				to_chat(H, span_blue("[pick("You feel like taking a nap.","You feel a yawn coming on.","You feel a little tired.")]"))
				H.drowsyness = min(H.drowsyness + rand(5,15) * weakness, 50 * weakness)
				H.eye_blurry = min(H.eye_blurry + rand(5,15) * weakness, 50 * weakness)
		for (var/mob/living/silicon/robot/R in range(src.effectrange,holder))
			to_chat(R, span_red("SYSTEM ALERT: CPU cycles slowing down."))
		return 1
