/datum/technomancer/spell/force_missile
	name = "Force Missile"
	desc = "This fires a missile at your target.  It's cheap to use, however the projectile itself moves and impacts in such a way \
	that armor designed to protect from blunt force will mitigate this function as well."
	spell_power_desc = "Increases damage dealt."
	cost = 50
	obj_path = /obj/item/spell/projectile/force_missile
	category = OFFENSIVE_SPELLS

/obj/item/spell/projectile/force_missile
	name = "force missile"
	icon_state = "force_missile"
	desc = "Make it rain!"
	cast_methods = CAST_RANGED
	aspect = ASPECT_FORCE
	spell_projectile = /obj/item/projectile/force_missile
	energy_cost_per_shot = 300
	instability_per_shot = 2
	cooldown = 5
	fire_sound = 'sound/weapons/wave.ogg'

/obj/item/projectile/force_missile
	name = "force missile"
	icon_state = "force_missile"
	damage = 25
	damage_type = BRUTE
	check_armour = "melee"

	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
