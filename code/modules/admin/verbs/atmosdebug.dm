/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Piping"
	set background = 1
	if(!check_rights_for(src, R_HOLDER))
		return

	feedback_add_details("admin_verb","CP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(tgui_alert(usr, "WARNING: This command should not be run on a live server. Do you want to continue?", "Check Piping", list("No", "Yes")) != "Yes")
		return

	to_chat(usr, "Checking for disconnected pipes...")
	//all plumbing - yes, some things might get stated twice, doesn't matter.
	for (var/obj/machinery/atmospherics/plumbing in GLOB.machines)
		if (plumbing.nodealert)
			to_chat(usr, span_filter_adminlog(span_warning("Unconnected [plumbing.name] located at [plumbing.x],[plumbing.y],[plumbing.z] ([get_area(plumbing.loc)])")))

	//Manifolds
	for (var/obj/machinery/atmospherics/pipe/manifold/pipe in GLOB.machines)
		if (!pipe.node1 || !pipe.node2 || !pipe.node3)
			to_chat(usr, span_filter_adminlog(span_warning("Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")))

	//Pipes
	for (var/obj/machinery/atmospherics/pipe/simple/pipe in GLOB.machines)
		if (!pipe.node1 || !pipe.node2)
			to_chat(usr, span_filter_adminlog(span_warning("Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")))

	to_chat(usr, "Checking for overlapping pipes...")
	next_turf:
		for(var/turf/T in world)
			for(var/dir in GLOB.cardinal)
				var/list/connect_types = list(1 = 0, 2 = 0, 3 = 0)
				for(var/obj/machinery/atmospherics/pipe in T)
					if(dir & pipe.initialize_directions)
						for(var/connect_type in pipe.connect_types)
							connect_types[connect_type] += 1
						if(connect_types[1] > 1 || connect_types[2] > 1 || connect_types[3] > 1)
							to_chat(usr, span_filter_adminlog(span_warning("Overlapping pipe ([pipe.name]) located at [T.x],[T.y],[T.z] ([get_area(T)])")))
							continue next_turf
	to_chat(usr, "Done")

/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!check_rights_for(src, R_HOLDER))
		return

	feedback_add_details("admin_verb","CPOW") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for (var/datum/powernet/PN in SSmachines.powernets)
		if (!PN.nodes || !PN.nodes.len)
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, span_filter_adminlog("Powernet with no nodes! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]"))

		if (!PN.cables || (PN.cables.len < 10))
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, span_filter_adminlog("Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]"))
