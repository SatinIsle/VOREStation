//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32





/obj/machinery/computer/telecomms/traffic
	name = "Telecommunications Traffic Control"
	desc = "Used to upload code to telecommunication consoles for execution."
	icon_screen = "generic"

	var/screen = 0				// the screen number:
	var/list/servers = list()	// the servers located by the computer
	var/mob/editingcode
	var/mob/lasteditor
	var/list/viewingcode = list()
	var/obj/machinery/telecomms/server/SelectedServer
	circuit = /obj/item/circuitboard/comm_traffic
	req_access = list(access_tcomsat)

	var/network = "NULL"		// the network to probe
	var/temp = ""				// temporary feedback messages

	var/storedcode = ""			// code stored


/obj/machinery/computer/telecomms/traffic/proc/update_ide()

	// loop if there's someone manning the keyboard
	while(editingcode)
		if(!editingcode.client)
			editingcode = null
			break

		// For the typer, the input is enabled. Buffer the typed text
		if(editingcode)
			storedcode = "[winget(editingcode, "tcscode", "text")]"
		if(editingcode) // double if's to work around a runtime error
			winset(editingcode, "tcscode", "is-disabled=false")

		// If the player's not manning the keyboard anymore, adjust everything
		if( (!(editingcode in range(1, src)) && !issilicon(editingcode)) || (editingcode.machine != src && !issilicon(editingcode)))
			if(editingcode)
				winshow(editingcode, "Telecomms IDE", 0) // hide the window!
			editingcode = null
			break

		// For other people viewing the typer type code, the input is disabled and they can only view the code
		// (this is put in place so that there's not any magical shenanigans with 50 people inputting different code all at once)

		if(length(viewingcode))
			// This piece of code is very important - it escapes quotation marks so string aren't cut off by the input element
			var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
			showcode = replacetext(storedcode, "\"", "\\\"")

			for(var/mob/M in viewingcode)

				if( (M.machine == src && (M in view(1, src)) ) || issilicon(M))
					winset(M, "tcscode", "is-disabled=true")
					winset(M, "tcscode", "text=\"[showcode]\"")
				else
					viewingcode.Remove(M)
					winshow(M, "Telecomms IDE", 0) // hide the window!

		sleep(5)

	if(length(viewingcode) > 0)
		editingcode = pick(viewingcode)
		viewingcode.Remove(editingcode)
		update_ide()




/obj/machinery/computer/telecomms/traffic/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)
	var/dat = "<TITLE>Telecommunication Traffic Control</TITLE><center><b>Telecommunications Traffic Control</b></center>"

	switch(screen)


		// --- Main Menu ---

		if(0)
			dat += "<br>[temp]<br>"
			dat += "<br>Current Network: <a href='byond://?src=\ref[src];network=1'>[network]</a><br>"
			if(servers.len)
				dat += "<br>Detected Telecommunication Servers:<ul>"
				for(var/obj/machinery/telecomms/T in servers)
					dat += "<li><a href='byond://?src=\ref[src];viewserver=[T.id]'>\ref[T] [T.name]</a> ([T.id])</li>"
				dat += "</ul>"
				dat += "<br><a href='byond://?src=\ref[src];operation=release'>\[Flush Buffer\]</a>"

			else
				dat += "<br>No servers detected. Scan for servers: <a href='byond://?src=\ref[src];operation=scan'>\[Scan\]</a>"


		// --- Viewing Server ---

		if(1)
			dat += "<br>[temp]<br>"
			dat += "<center><a href='byond://?src=\ref[src];operation=mainmenu'>\[Main Menu\]</a>     <a href='byond://?src=\ref[src];operation=refresh'>\[Refresh\]</a></center>"
			dat += "<br>Current Network: [network]"
			dat += "<br>Selected Server: [SelectedServer.id]<br><br>"
			dat += "<br><a href='byond://?src=\ref[src];operation=editcode'>\[Edit Code\]</a>"
			dat += "<br>Signal Execution: "
			if(SelectedServer.autoruncode)
				dat += "<a href='byond://?src=\ref[src];operation=togglerun'>ALWAYS</a>"
			else
				dat += "<a href='byond://?src=\ref[src];operation=togglerun'>NEVER</a>"

	var/datum/browser/popup = new(user, "traffic_control", "Traffic Control", 575, 400)
	popup.set_content(dat)
	popup.open()

	temp = ""

/obj/machinery/computer/telecomms/traffic/Topic(href, href_list)
	if(..())
		return


	add_fingerprint(usr)
	usr.set_machine(src)
	if(!src.allowed(usr) && !emagged)
		to_chat(usr, span_warning("ACCESS DENIED."))
		return

	if(href_list["viewserver"])
		screen = 1
		for(var/obj/machinery/telecomms/T in servers)
			if(T.id == href_list["viewserver"])
				SelectedServer = T
				break

	if(href_list["operation"])
		switch(href_list["operation"])

			if("release")
				servers = list()
				screen = 0

			if("mainmenu")
				screen = 0

			if("scan")
				if(servers.len > 0)
					temp = span_red("- FAILED: CANNOT PROBE WHEN BUFFER FULL -")

				else
					for(var/obj/machinery/telecomms/server/T in range(25, src))
						if(T.network == network)
							servers.Add(T)

					if(!servers.len)
						temp = span_red("- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -")
					else
						temp = span_blue("- [servers.len] SERVERS PROBED & BUFFERED -")

					screen = 0

			if("editcode")
				if(editingcode == usr) return
				if(usr in viewingcode) return

				if(!editingcode)
					lasteditor = usr
					editingcode = usr
					winshow(editingcode, "Telecomms IDE", 1) // show the IDE
					winset(editingcode, "tcscode", "is-disabled=false")
					winset(editingcode, "tcscode", "text=\"\"")
					var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
					showcode = replacetext(storedcode, "\"", "\\\"")
					winset(editingcode, "tcscode", "text=\"[showcode]\"")
					spawn()
						update_ide()

				else
					viewingcode.Add(usr)
					winshow(usr, "Telecomms IDE", 1) // show the IDE
					winset(usr, "tcscode", "is-disabled=true")
					winset(editingcode, "tcscode", "text=\"\"")
					var/showcode = replacetext(storedcode, "\"", "\\\"")
					winset(usr, "tcscode", "text=\"[showcode]\"")

			if("togglerun")
				SelectedServer.autoruncode = !(SelectedServer.autoruncode)

	if(href_list["network"])

		var/newnet = tgui_input_text(usr, "Which network do you want to view?", "Comm Monitor", network, 15)
		newnet = sanitize(newnet,15)

		if(newnet && ((usr in range(1, src)) || issilicon(usr)))
			if(length(newnet) > 15)
				temp = span_red("- FAILED: NETWORK TAG STRING TOO LENGHTLY -")

			else

				network = newnet
				screen = 0
				servers = list()
				temp = span_blue("- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -")

	updateUsrDialog(usr)
	return

/obj/machinery/computer/telecomms/traffic/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		playsound(src, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		to_chat(user, span_notice("You you disable the security protocols"))
		updateUsrDialog(user)
		return 1
