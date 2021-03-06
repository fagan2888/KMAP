; initialization of variables and stuff for Premiere functions
; written by Kristen Maxwell, who would be running up that hill

;-----INIT variables for Premiere features 
	global tags := Object() 						; create object/array as global so any functions can access its contents
	global kmap_settings := Object() 				; global object to store settings read in from INI file
	kmap_settings := kmap_options_ini_read() 		; run the function to read the user options for premiere features from our INI file
	loop, 10 { 										
		key := "tag" . a_index
		tags[a_index] := kmap_settings[key]			; loop through and copy tag1 - tag10, from INI Settings --> the array tags[1] ... tags[10]
	} ; end loop
; define hotkeys for Premiere functions (if enabled, based on settings in INI)	
	kmap_makehotkeys(kmap_settings.enable_paste_insert, kmap_settings.paste_insert_hotkey, "kmap_paste_insert_hotkey_do")
	kmap_makehotkeys(kmap_settings.enable_fit_to_fill, kmap_settings.fit_to_fill_insert_hotkey, "kmap_fit_to_fill_insert_hotkey_do")
	kmap_makehotkeys(kmap_settings.enable_fit_to_fill, kmap_settings.fit_to_fill_overwrite_hotkey, "kmap_fit_to_fill_overwrite_hotkey_do")
	kmap_makehotkeys(kmap_settings.enable_multitag_subclip, kmap_settings.multitag_hotkey, "kmap_multitag_hotkey_do")
	kmap_makehotkeys(kmap_settings.multitag_use_alternate, kmap_settings.multitag_alternate_hotkey, "kmap_multitag_alt_hotkey_do")
	kmap_makehotkeys(kmap_settings.enable_review_head_tail, kmap_settings.review_head_tail_hotkey, "kmap_review_head_tail_hotkey_do")
	kmap_makehotkeys(kmap_settings.enable_ripple_cut, kmap_settings.ripple_cut_hotkey, "kmap_ripple_cut_hotkey_do")
	kmap_makenumberhotkeys(kmap_settings.enable_single_tag_subclip, kmap_settings.single_tag_hotkeys, "unused")
	


;-----/INIT variables for Premiere



;----- INIT for Play Head and Tail
		global review_length := kmap_settings.review_length ;  length of time (in seconds) to review around the edits, from INI. default = 5	
		global frame_rate := kmap_settings.frame_rate ; user's fps, set in INI. defaults to 30
		global review_seconds, review_frames_tens, review_frames_ones
		; i'm gonna be a lousy coder here and just assume that nobody wants to review more than 18 seconds around an edit, because I don't wanna
		; parse out multi-digit numbers into multiple keypresses. Yes, I'm lazy.
		review_length := km_Bound(review_length, 1, 18) ; limit review_length to between 1 and 18 seconds
		review_seconds := review_length //2 ; how many WHOLE seconds do we need to jump back from the edit point?
		review_subseconds := (review_length / 2) - review_seconds ; what FRACTION of a second do we need to jump back from the edit point?
		review_frames := Ceil(review_subseconds * frame_rate) ; convert fractional second to # of frames, rounding up 
		if (review_frames > 9){ ; if we have more than 1 digit 
			review_frames_tens := SubStr(review_frames, 1, 1) ; grab first digit of variable review_frames -- the tens place
			review_frames_ones := SubStr(review_frames, 2, 1) ; grab second digit of variable review_frames -- the ones place
		} else {
			review_frames_tens := 0 ; if we only have 1 digit, we'll pad it with a leading zero
			review_frames_ones := SubStr(review_frames, 2, 1) ; grab second digit of variable review_frames -- the ones place
		}
;----- /INIT for Play Head and Tail




; ------------INIT multi-tag subclip GUI -----------
	global gui_sticky := 0 ; default the gui to NOT remember values each time it is invoked  ----- >>does this need to be in the INI?
	
	
	; declare and init variables to store gui checkbox states
	global multitag := []							; create simple linear array to store value of checkboxes in multi-tag GUI	
	loop, 10 {
		multitag[a_index] := 0 						; initialize all GUI checkboxes to 0 (unckecked)
	} ; end loop

	global multitag_pa1, multitag_pa2, multitag_pa3, multitag_pa4, multitag_pa5, multitag_pa6, multitag_pa7
			, multitag_pa8, multitag_pa9, multitag_pa10
	kmap_shitbird(1) ; perform inverse-shitbird to copy array into pseudoarray.


	hotkey, IfWinActive, multitag_gui ; limit scope of subsequent hotke definitions to multi-tag subclip gui window

	; this loop creates hotkeys CTRL SHIFT 1...9, 0 (and the corresponding numpad keys, if set in the INI) 
	; to toggle the tag checkboxes in the multi-tag GUI
	loop, 10 { 
		index_zero := substr(a_index, 0, 1) ; get last digit, 1...9, 0
		hotkey, %index_zero% , defineguihotkeys ; all hotkeys defined here will run the same label, and be sorted out with an a_thishotkey check therein 
		if (kmap_settings.multitag_use_numpad) { ; if option enabled in INI
			hotkey, Numpad%index_zero%, defineguihotkeys ; NUMPAD0 - NUMPAD9 keys will add tags in the GUI
		} ; end if
	} ; end loop
	hotkey, a, execute_gui_all_hotkey ; set hotkey to perform "select all" action in gui
	hotkey, r, execute_gui_remember_hotkey ; set hotkey to perform "remember / sticky" action in gui
	hotkey, IfWinActive ; we're done defining hotkeys for the gui, return hotkey scope to unlimited

; -------------/INIT multi-tag subclip GUI------------
