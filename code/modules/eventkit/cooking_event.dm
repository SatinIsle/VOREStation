//This is stuff specifically to be used for a cook-off type event

/obj/structure/cooking_equipment
	name = "Ultra Nukie Synthesiser"
	desc = "A janked together piece of equipment designed to make ultra nukies."

	icon = 'icons/obj/cooking_event.dmi'
	icon_state = "equipment_empty"

	var/product =
	var/list/ingredients = list(/obj/item/cooking_ingredient/formula,
								/obj/item/cooking_ingredient/mewriatic_acid,
								/obj/item/cooking_ingredient/radioactive_sludge)

	var/current_step = 0
	var/max_step = 0
	var/wait_time = 3 MINUTES
	var/on = TRUE
	var/cooking = FALSE

/obj/structure/cooking_equipment/Initialize()
	choose_order()
	max_step = ingredients.len
	..()

/obj/structure/cooking_equipment/proc/choose_order()
	if(!ingredients.len)
		return
	shuffle_inplace(ingredients)

/obj/structure/cooking_equipment/proc/cook()


/obj/structure/cooking_equipment/update_icon()


/obj/structure/cooking_equipment/attackby(obj/item/W as obj, mob/user as mob)


/obj/item/cooking_ingredient
	name = "Nukie Secret Formula"
	desc = "A horrible blend of some of the galaxies most unhealthy ingredients and a lot of coffee."

	icon = 'icons/obj/cooking_event.dmi'
	icon_state = "formula"

/obj/item/cooking_ingredient/formula

/obj/item/cooking_ingredient/mewriatic_acid
	name = "Mewriatic Acid"
	desc = "A hyperconcentrated bottle of some sort of acid."

	icon = 'icons/obj/cooking_event.dmi'
	icon_state = "acid"

/obj/item/cooking_ingredient/radioactive_sludge
	name = "Fizzy Radioactive Stuff"
	desc = "Some thick sludge substance that glows uncomfortably..."

	icon = 'icons/obj/cooking_event.dmi'
	icon_state = "sludge"
