/obj/item/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_books.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_books.dmi'
		)
	var/uses = 4.0
	w_class = ITEMSIZE_TINY
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	origin_tech = list(TECH_BLUESPACE = 4)

/obj/item/teleportation_scroll/attack_self(mob/user as mob)
	if((user.mind && !wizards.is_antagonist(user.mind)))
		to_chat(user, span_warning("You stare at the scroll but cannot make sense of the markings!"))
		return

	user.set_machine(src)
	var/dat = span_bold("Teleportation Scroll:") + "<BR>"
	dat += "Number of uses: [src.uses]<BR>"
	dat += "<HR>"
	dat += span_bold("Four uses use them wisely:") + "<BR>"
	dat += "<A href='byond://?src=\ref[src];spell_teleport=1'>Teleport</A><BR>"
	dat += "Kind regards,<br>Wizards Federation<br><br>P.S. Don't forget to bring your gear, you'll need it to cast most spells.<HR>"

	var/datum/browser/popup = new(user, "scroll", "Scroll")
	popup.set_content(dat)
	popup.open()

/obj/item/teleportation_scroll/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || src.loc != usr)
		return
	var/mob/living/carbon/human/H = usr
	if (!ishuman(H))
		return 1
	if ((usr == src.loc || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_machine(src)
		if (href_list["spell_teleport"])
			if (src.uses >= 1)
				teleportscroll(H)
	attack_self(H)
	return

/obj/item/teleportation_scroll/proc/teleportscroll(var/mob/user)
	var/A = tgui_input_list(user, "Area to jump to:", "Teleportation Scroll", GLOB.teleportlocs)
	if(!A)
		return
	var/area/thearea = GLOB.teleportlocs[A]

	if (user.stat || user.restrained())
		return
	if(!((user == loc || (in_range(src, user) && istype(src.loc, /turf)))))
		return

	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(5, 0, user.loc)
	smoke.attach(user)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L.len)
		to_chat(user, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
		return

	if(user && user.buckled)
		user.buckled.unbuckle_mob()

	var/list/tempL = L
	var/attempt = null
	var/success = 0
	while(tempL.len)
		attempt = pick(tempL)
		success = user.Move(attempt)
		if(!success)
			tempL.Remove(attempt)
		else
			break

	if(!success)
		user.loc = pick(L)

	smoke.start()
	src.uses -= 1
