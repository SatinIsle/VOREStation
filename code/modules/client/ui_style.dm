/proc/ui_style2icon(ui_style)
	if(ui_style in all_ui_styles)
		return all_ui_styles[ui_style]
	return all_ui_styles["White"]


/client/verb/change_ui()
	set name = "Change UI"
	set category = "Preferences.Game"
	set desc = "Configure your user interface"

	if(!ishuman(usr))
		if(!isrobot(usr))
			to_chat(src, span_warning("You must be a human or a robot to use this verb."))
			return

	var/current_style = prefs.read_preference(/datum/preference/choiced/ui_style)
	var/current_alpha = prefs.read_preference(/datum/preference/numeric/ui_style_alpha)
	var/current_color = prefs.read_preference(/datum/preference/color/ui_style_color)
	var/UI_style_new = tgui_input_list(src, "Select a style. White is recommended for customization", "UI Style Choice", all_ui_styles, current_style)
	if(!UI_style_new) return

	var/UI_style_alpha_new = tgui_input_number(src, "Select a new alpha (transparency) parameter for your UI, between 50 and 255", null, current_alpha, 255, 50)
	if(!UI_style_alpha_new || !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return

	var/UI_style_color_new = tgui_color_picker(src, "Choose your UI color. Dark colors are not recommended!", null, current_color)
	if(!UI_style_color_new) return

	//update UI
	usr.update_ui_style(UI_style_new, UI_style_alpha_new, UI_style_color_new)

	if(tgui_alert(src, "Like it? Save changes?","Save?",list("Yes", "No")) == "Yes")
		usr.write_preference_directly(/datum/preference/choiced/ui_style, UI_style_new)
		usr.write_preference_directly(/datum/preference/numeric/ui_style_alpha, UI_style_alpha_new)
		usr.write_preference_directly(/datum/preference/color/ui_style_color, UI_style_color_new)
		SScharacter_setup.queue_preferences_save(prefs)
		to_chat(src, "UI was saved")
		return

	usr.update_ui_style(current_style, current_alpha, current_color)
