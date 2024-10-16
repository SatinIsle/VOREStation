
/client/verb/who_advanced()
	set name = "Advanced Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()

	if(holder)
		for(var/client/C in GLOB.clients)
			var/entry = "<tr><td>[C.key]"
			if(C.holder && C.holder.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"

			entry += "</td><td>"

			if(C.mob.real_name)
				switch(C.mob.stat)
					if(UNCONSCIOUS)
						entry += span_darkgray("<b>Unconscious</b>") // these are literally all spans so I can apply .inverted to them because black on dark grey isn't legible

					if(DEAD)
						if(isobserver(C.mob))
							var/mob/observer/dead/O = C.mob
							if(O.started_as_observer)
								entry += span_gray("Observing")
							else
								entry += span_black("<b>Died</b>")

					else
						entry += span_green("Playing")

				entry += " as [C.mob.real_name]"

			else if(isnewplayer(C.mob))
				entry += span_blue("<b>In lobby</b>")

			entry += "</td><td>"

			var/age
			if(isnum(C.player_age))
				age = C.player_age
			else
				age = 0

			if(age <= 1)
				age = span_red("<b>[age]</b>")
			else if(age < 10)
				age = span_orange("<b>[age]</b>")

			entry += "Age: [age]"
			entry += "</td><td>"

			if(is_special_character(C.mob))
				if(C.mob?.mind?.special_role)
					entry += span_red(span_bold("[C.mob.mind.special_role]"))
				else
					entry += span_red(span_bold("Antagonist"))

			entry += "</td><td>"

			if(C.is_afk())
				var/seconds = C.last_activity_seconds()
				entry += " (AFK - "
				entry += "[round(seconds / 60)] minutes, "
				entry += "[seconds % 60] seconds)"

			entry += "</td><td>"
			entry += " (<A HREF='?_src_=holder;[HrefToken()];adminmoreinfo=\ref[C.mob]'>?</A>)"
			entry += "</td></tr>"

			Lines += entry
	else
		for(var/client/C in GLOB.clients)
			var/entry = "\t"
			if(C.holder && C.holder.fakekey)
				entry += "[C.holder.fakekey]"
			else
				entry += "[C.key]"
			var/mob/observer/dead/O = C.mob
			if(isobserver(O))
				entry += " - " + span_gray("Observing") + "<br>"
			else if(istype(O,/mob/new_player))
				entry += " - " + span_blue("In Lobby") + "<br>"
			else
				entry += " - "+ span_green("Playing") + "<br>"

			Lines += entry

	msg += "<table>"
	for(var/line in sortList(Lines))
		msg += "[line]"
	msg += "</table>"
	msg += "<b>Total Players: [length(Lines)]</b>"
	msg = span_filter_notice("" + msg + "")
	to_chat(src, msg)
