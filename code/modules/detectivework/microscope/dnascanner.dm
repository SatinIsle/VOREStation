//DNA machine
/obj/machinery/dnaforensics
	name = "DNA analyzer"
	desc = "A high tech machine that is designed to read DNA samples properly."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnaopen"
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/dna_analyzer

	var/obj/item/forensics/swab/bloodsamp = null
	var/scanning = 0
	var/scanner_progress = 0
	var/scanner_rate = 5
	var/last_process_worldtime = 0
	var/report_num = 0

/obj/machinery/dnaforensics/Initialize(mapload)
	. = ..()
	default_apply_parts()

/obj/machinery/dnaforensics/attackby(obj/item/W, mob/user)
	if(bloodsamp)
		to_chat(user, span_warning("There is a sample in the machine."))
		return

	if(scanning)
		to_chat(user, span_warning("[src] is busy scanning right now."))
		return

	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(user, W))
		return

	var/obj/item/forensics/swab/swab = W
	if(istype(swab) && swab.is_used())
		user.unEquip(W)
		bloodsamp = swab
		swab.forceMove(src)
		to_chat(user, span_notice("You insert [W] into [src]."))
		update_icon()
	else
		to_chat(user, span_warning("\The [src] only accepts used swabs."))
		return

/obj/machinery/dnaforensics/tgui_interact(mob/user, datum/tgui/ui)
	if(stat & (NOPOWER))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DNAForensics", "QuikScan DNA Analyzer") // 540, 326
		ui.open()

/obj/machinery/dnaforensics/tgui_data(mob/user)
	var/list/data = ..()
	data["scan_progress"] = round(scanner_progress)
	data["scanning"] = scanning
	data["bloodsamp"] = (bloodsamp ? bloodsamp.name : "")
	data["bloodsamp_desc"] = (bloodsamp ? (bloodsamp.desc ? bloodsamp.desc : "No information on record.") : "")
	return data

/obj/machinery/dnaforensics/tgui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	if(stat & (NOPOWER))
		return FALSE // don't update UIs attached to this object

	. = TRUE
	switch(action)
		if("scanItem")
			if(scanning)
				scanning = FALSE
				update_icon()
			else
				if(bloodsamp)
					scanner_progress = 0
					scanning = TRUE
					to_chat(ui.user, span_notice("Scan initiated."))
					update_icon()
				else
					to_chat(ui.user, span_warning("Insert an item to scan."))
			. = TRUE

		if("ejectItem")
			if(bloodsamp)
				bloodsamp.forceMove(loc)
				bloodsamp = null
				scanning = FALSE
				update_icon()

/obj/machinery/dnaforensics/process()
	if(scanning)
		if(!bloodsamp || bloodsamp.loc != src)
			bloodsamp = null
			scanning = 0
		else if(scanner_progress >= 100)
			complete_scan()
			return
		else
			//calculate time difference
			var/deltaT = (world.time - last_process_worldtime) * 0.1
			scanner_progress = min(100, scanner_progress + scanner_rate * deltaT)
	last_process_worldtime = world.time

/obj/machinery/dnaforensics/proc/complete_scan()
	visible_message(span_notice("[icon2html(src,viewers(src))] makes an insistent chime."), 2)
	update_icon()
	if(bloodsamp)
		var/obj/item/paper/P = new(src)
		P.name = "[src] report #[++report_num]: [bloodsamp.name]"
		P.stamped = list(/obj/item/stamp)
		P.cut_overlays()
		P.add_overlay("paper_stamped")
		//dna data itself
		var/data = "No scan information available."
		if(bloodsamp.dna != null)
			data = "Spectometric analysis on provided sample has determined the presence of [bloodsamp.dna.len] strings of DNA.<br><br>"
			for(var/blood in bloodsamp.dna)
				data += span_blue("Blood type: [bloodsamp.dna[blood]]<br>\nDNA: [blood]<br><br>")
		else
			data += "No DNA found.<br>"
		P.info = span_bold("[src] analysis report #[report_num]") + "<br>"
		P.info += span_bold("Scanned item:") + "<br>[bloodsamp.name]<br>[bloodsamp.desc]<br><br>" + data
		P.forceMove(loc)
		P.update_icon()
		scanning = FALSE
		update_icon()
	return

/obj/machinery/dnaforensics/attack_ai(mob/user)
	tgui_interact(user)

/obj/machinery/dnaforensics/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/dnaforensics/update_icon()
	..()
	if(!(stat & NOPOWER) && scanning)
		icon_state = "dnaworking"
	else if(bloodsamp)
		icon_state = "dnaclosed"
	else
		icon_state = "dnaopen"
