/proc/GameOver()
	if(!GLOB.hadevent)
		GLOB.hadevent = 1
		message_admins("The apocalypse has begun! (this holiday event can be disabled by toggling events off within 60 seconds)")
		spawn(600)
			if(!CONFIG_GET(flag/allow_random_events))	return
			Show2Group4Delay(ScreenText(null,"<center>" + span_red(span_extramassive("GAME OVER")) + "</center>"),null,150)
			for(var/i=1,i<=4,i++)
				spawn_dynamic_event()
				sleep(50)
