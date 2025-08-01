//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/hsboxspawn = 1
var/list
		hrefs = list(
					"hsbsuit" = "Suit Up (Space Travel Gear)",
					"hsbmetal" = "Spawn 50 Metal",
					"hsbglass" = "Spawn 50 Glass",
					"hsbairlock" = "Spawn Airlock",
					"hsbregulator" = "Spawn Air Regulator",
					"hsbfilter" = "Spawn Air Filter",
					"hsbcanister" = "Spawn Canister",
					"hsbfueltank" = "Spawn Welding Fuel Tank",
					"hsbwater	tank" = "Spawn Water Tank",
					"hsbtoolbox" = "Spawn Toolbox",
					"hsbmedkit" = "Spawn Medical Kit")

mob
	var/datum/hSB/sandbox = null
	proc
		CanBuild()
			if(GLOB.master_mode == "sandbox")
				sandbox = new/datum/hSB
				sandbox.owner = src.ckey
				if(check_rights_for(src.client, R_HOLDER))
					sandbox.admin = 1
				add_verb(src, /mob/proc/sandbox_panel)
		sandbox_panel()
			if(sandbox)
				sandbox.update()

/datum/hSB
	var/owner = null
	var/admin = 0
	proc
		update()
			var/hsbpanel = "<center><b>h_Sandbox Panel</b></center><hr>"
			if(admin)
				hsbpanel += span_bold("Administration Tools:") + "<br>"
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbtobj\">Toggle Object Spawning</a><br><br>"
			hsbpanel += span_bold("Regular Tools:") + "<br>"
			for(var/T in hrefs)
				hsbpanel += "- <a href=\"?\ref[src];hsb=[T]\">[hrefs[T]]</a><br>"
			if(hsboxspawn)
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbobj\">Spawn Object</a><br><br>"

			var/datum/browser/popup = new(usr, "hsbpanel", "HSB Panel")
			popup.set_content(hsbpanel)
			popup.open()
	Topic(href, href_list)
		if(!(src.owner == usr.ckey)) return
		if(!usr) return //I guess this is possible if they log out or die with the panel open? It happened.
		if(href_list["hsb"])
			switch(href_list["hsb"])
				if("hsbtobj")
					if(!admin) return
					if(hsboxspawn)
						to_world(span_world("Sandbox:  [usr.key] has disabled object spawning!"))
						hsboxspawn = 0
						return
					if(!hsboxspawn)
						to_world(span_world("Sandbox:  [usr.key] has enabled object spawning!"))
						hsboxspawn = 1
						return
				if("hsbsuit")
					var/mob/living/carbon/human/P = usr
					if(P.wear_suit)
						P.wear_suit.loc = P.loc
						P.wear_suit.reset_plane_and_layer()
						P.wear_suit = null
					P.wear_suit = new/obj/item/clothing/suit/space(P)
					P.wear_suit.hud_layerise()
					if(P.head)
						P.head.loc = P.loc
						P.head.reset_plane_and_layer()
						P.head = null
					P.head = new/obj/item/clothing/head/helmet/space(P)
					P.head.hud_layerise()
					if(P.wear_mask)
						P.wear_mask.loc = P.loc
						P.wear_mask.reset_plane_and_layer()
						P.wear_mask = null
					P.wear_mask = new/obj/item/clothing/mask/gas(P)
					P.wear_mask.hud_layerise()
					if(P.back)
						P.back.loc = P.loc
						P.back.reset_plane_and_layer()
						P.back = null
					P.back = new/obj/item/tank/jetpack(P)
					P.back.hud_layerise()
					P.internal = P.back
				if("hsbmetal")
					var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/metal
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbglass")
					var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/glass
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbairlock")
					var/obj/machinery/door/hsb = new/obj/machinery/door/airlock

					//TODO: DEFERRED make this better, with an HTML window or something instead of 15 popups
					hsb.req_access = list()
					var/accesses = get_all_accesses()
					for(var/A in accesses)
						if(tgui_alert(usr, "Will this airlock require [get_access_desc(A)] access?", "Sandbox:", list("Yes", "No")) == "Yes")
							LAZYADD(hsb.req_access, A)

					hsb.loc = usr.loc
					to_chat(usr, span_bold("Sandbox:  Created an airlock."))
				if("hsbcanister")
					var/list/hsbcanisters = subtypesof(/obj/machinery/portable_atmospherics/canister)
					var/hsbcanister = tgui_input_list(usr, "Choose a canister to spawn:", "Sandbox", hsbcanisters)
					if(hsbcanister)
						new hsbcanister(usr.loc)
				if("hsbfueltank")
					//var/obj/hsb = new/obj/weldfueltank
					//hsb.loc = usr.loc
				if("hsbwatertank")
					//var/obj/hsb = new/obj/watertank
					//hsb.loc = usr.loc
				if("hsbtoolbox")
					var/obj/item/storage/hsb = new/obj/item/storage/toolbox/mechanical
					for(var/obj/item/radio/T in hsb)
						qdel(T)
					new/obj/item/tool/crowbar (hsb)
					hsb.loc = usr.loc
				if("hsbmedkit")
					var/obj/item/storage/firstaid/hsb = new/obj/item/storage/firstaid/regular
					hsb.loc = usr.loc
				if("hsbobj")
					if(!hsboxspawn) return

					var/list/selectable = list()
					for(var/O in typesof(/obj/item/))
					//Note, these istypes don't work
						if(istype(O, /obj/item/gun))
							continue
						if(istype(O, /obj/item/assembly))
							continue
						if(istype(O, /obj/item/camera))
							continue
						if(istype(O, /obj/item/dummy))
							continue
						if(istype(O, /obj/item/melee/energy/sword))
							continue
						if(istype(O, /obj/structure))
							continue
						selectable += O

					var/hsbitem = tgui_input_list(usr, "Choose an object to spawn:", "Sandbox", selectable)
					if(hsbitem)
						new hsbitem(usr.loc)
