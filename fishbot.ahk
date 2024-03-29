CoordMode, Pixel, Window
CoordMode, Mouse, Window

; ============================================================================
; ===============================================================[ EVENTS ]===
;
; TODO: wrap functionality into a class or something
;
StartBaubleTimer(){
	global
	BAUBLE_EVENT_TRIGGERED := false
	Duration := (1000*60*11)
	SetTimer, ApplyBaubleTimerEventCallback, %Duration%	
}

ApplyBaubleTimerEventCallback(){	
	global	
	BAUBLE_EVENT_TRIGGERED := true
}

LookForLureTimeoutEventCallback(){
	global
	LOOK_FOR_LURE_TIMER_RUNNING := false		
}

StartLookForLureTimer(){
	global	
	LOOK_FOR_LURE_TIMER_RUNNING := true
	TimeoutDuration := (1000*LOOK_FOR_LURE_DURATION)
	SetTimer, LookForLureTimeoutEventCallback, %TimeoutDuration%
}

StopLookForLureTimer(){
	global
	LOOK_FOR_LURE_TIMER_RUNNING := false
	SetTimer, LookForLureTimeoutEventCallback, Off
}

LookForFishOnLureTimeoutEventCallback(){
	StopLookForFishOnLureTimer()
}

StartLookForFishOnLureTimer(){
	global
	;- start timer if no lure is found start sequence over
	LOOK_FOR_FISH_ON_LURE_TIMER_RUNNING := true
	TimeoutDuration := (1000*LOOK_FOR_FISH_ON_LURE_DURATION)
	SetTimer, LookForFishOnLureTimeoutEventCallback, %TimeoutDuration%	
}

StopLookForFishOnLureTimer(){
	global
	LOOK_FOR_FISH_ON_LURE_TIMER_RUNNING := false
	SetTimer, LookForFishOnLureTimeoutEventCallback, Off
}
; ============================================================================



; ------------------------------------------------------------[ CastLine ]---
;
CastLine() {
	global		
	Send %CAST_LINE_KEY%
	Sleep, 3000 	;- give the animation time to finish	
}

EquipFishingPole(){
	global
	Send %EQUIP_FISHING_POLE_KEY%
	Sleep, 1000
}

CollectFoundFish() {
	global
	MouseMove, %FOUND_LURE_X%, %FOUND_LURE_Y%
	Send +{Click, right}	
}

;-----------------------------------------------------------[ ApplyBauble ]---
; TODO - make relative to window size
ApplyBauble(){
	global

	; - open character sheet
	Send %OPEN_CHARACTER_SHEET_KEY%
	Sleep, 200
	Send %APPLY_BAUBLE_KEY%
	Sleep, 200
	MouseMove, %CHAR_SHEET_PRIM_WEAPON_X%, %CHAR_SHEET_PRIM_WEAPON_Y%
	Sleep, 200
	Send {Click}
	Sleep, 200
	Send %OPEN_CHARACTER_SHEET_KEY%

	Sleep, 6000 ; - wait for application of bauble to complete	
}

; ---------------------------------------------------------[ TestForColor ]---
; Look at a pixel at x,y coordinate and test if it is the same Color
; TargetColor(RGB): 0x000000
;
TestForColor(x, y, TargetColor) {	
	PixelGetColor, color, %x%, %y%
	
	if ( color == TargetColor )
		return true
	else
		return false	
}

; ---------------------------------------------------------[ RunClickGrid ]---
; - DEPRICATED
RunClickGrid() {	
	global 

	Loop, %CG_WIDTH% {
		x := (A_Index*CG_OFFSET_X)+CG_START_X
		Loop, %CG_HEIGHT% {	
			y := (A_Index*CG_OFFSET_Y)+CG_START_Y
			MouseMove, x, y			
			Send +{Click, right}
			

			; see if this attempt found no fish (yellow error text)
			if ( TestForColor( NO_FISH_ATTACHED_X, NO_FISH_ATTACHED_Y,NO_FISH_ATTACHED_COLOR) ) 
				return

			; see if this attempt found a fish (loot window)
			if ( TestForColor( LOOT_X, LOOT_Y, LOOT_COLOR ) ) 
				return				

			; see if its time to reapply a bauble
			if ( BAUBLE_EVENT_TRIGGERED )
				return
			
			Sleep, 200				

		}
	}
}



; --------------------------------------------------------[ LookForFishOnLure ]
;- TODO: add timetout function
;	 wait for fish to bite
LookForFishOnLure() {
	global

	StartLookForFishOnLureTimer()

	while LOOK_FOR_FISH_ON_LURE_TIMER_RUNNING {

		if ( !RUN_LOOP ) return

		x   := FOUND_LURE_X
		y   := FOUND_LURE_Y

		sx  := x-BAUBLE_BOX_X_OFFSET
		sy  := y-BAUBLE_BOX_Y_OFFSET
		dx  := x+BAUBLE_BOX_X_OFFSET
		dy  := y+BAUBLE_BOX_Y_OFFSET

		
		PixelSearch, fx, fy, sx, sy, dx, dy, FISH_ON_LURE_COLOR, COLOR_SEARCH_PIXEL_WHITE_OFFSET, Fast
		
		;- didn't find anything, wait
		if ErrorLevel = 2
			Sleep, 250
		if ErrorLevel = 1
			Sleep, 250
		
		;- found fish, collect 
		if ( ErrorLevel = 0 ) {
			Sleep, 500
			CollectFoundFish()
			Sleep, 1000
			
			; - fish found, stop looking for it
			StopLookForFishOnLureTimer()
			return
		}		
	}
}


;----------------------------------------------------  [ LocateLureByPixel ]---
;
LocateLureByPixel() {
	global
	
	
	sx  := FIND_LURE_BOUNDING_BOX_X
	sy  := FIND_LURE_BOUNDING_BOX_Y
	dx  := FIND_LURE_BOUNDING_BOX_DX
	dy  := FIND_LURE_BOUNDING_BOX_DY

	PixelSearch, x, y, sx, sy, dx, dy, FISHING_LURE_MATCH_COLOR, COLOR_SEARCH_PIXEL_RED_OFFSET, Fast	

	if ErrorLevel = 2
		return 0
	if ErrorLevel = 1
	 	return 0
	if ErrorLevel = 0
		return [x,y]
}



;---------------------------------------------------------[ LookForLure ]---
;
LookForLure(){
	global

	;- start timer if no lure is found start sequence over
	StartLookForLureTimer()

	while LOOK_FOR_LURE_TIMER_RUNNING {			
		
		if ( !RUN_LOOP ) return

		; - try to find the lure
		m  := LocateLureByPixel() 
		if ( m ){			
			mx := m[1]
			my := m[2]			
			
			MouseMove, %mx%, %my%
			FOUND_LURE_X := mx
			FOUND_LURE_Y := my 



			StopLookForLureTimer()
			LookForFishOnLure()	
			; MsgBox, Stopped LookForFishOnLure					
			return
		}			

		Sleep, 1000
	}
}


;------------------------------------------------------------[ MainLoop ]---
; TODO: add timetout function
MainLoop() {
	global
	; start looping right clicks	
	while RUN_LOOP {
		
		; if ( BAUBLE_EVENT_TRIGGERED ){			
			; - clear the flag, only run this once
			; BAUBLE_EVENT_TRIGGERED  := false		

			; - reapply a new bauble
			; ApplyBauble()	
			
		; } else {
			; if ( WinExist(APP_WINDOW_NAME) ) {
				; WinActivate
				; - clear any old timers
				StopLookForFishOnLureTimer()
				StopLookForLureTimer()

				; - cast line
				if ( RUN_LOOP )
					CastLine()

				; - look for lure
				if ( RUN_LOOP ){
					LookForLure()			
					Sleep, 1000
				}
				

				;- move mouse back to top corner
				; MouseMove, 0, 0
			; }
		; }

		; don't ever stop trying!
	}
}



MsgBoxPixelAtMouse(){
	MouseGetPos, x, y
	PixelGetColor, Color, x, y
	MsgBox %Color%	
}

SetFishingBoundingBox(){
	global
	WinActivate
	
	WinGetPos, x, y, w, h, %APP_WINDOW_NAME%
	FIND_LURE_BOUNDING_BOX_X 	:= w * 0.25
	FIND_LURE_BOUNDING_BOX_DX	:= FIND_LURE_BOUNDING_BOX_X + (w * 0.50)
	FIND_LURE_BOUNDING_BOX_Y 	:= h * 0.20
	FIND_LURE_BOUNDING_BOX_DY	:= FIND_LURE_BOUNDING_BOX_Y + (h * 0.25)
}

TestFishingBoundingBox() {
	global
	MouseMove, %FIND_LURE_BOUNDING_BOX_X%, %FIND_LURE_BOUNDING_BOX_Y%
	Sleep, 1000
	MouseMove, %FIND_LURE_BOUNDING_BOX_DX%, %FIND_LURE_BOUNDING_BOX_Y%
	Sleep, 1000
	MouseMove, %FIND_LURE_BOUNDING_BOX_X%, %FIND_LURE_BOUNDING_BOX_DY%
	Sleep, 1000
	MouseMove, %FIND_LURE_BOUNDING_BOX_DX%, %FIND_LURE_BOUNDING_BOX_DY%
	Sleep, 1000	
}

PreFishSetup(){
	; - bounding box for lure search
	SetFishingBoundingBox()

	; TestFishingBoundingBox()	

	; - equip fishing pole
	EquipFishingPole()	

	; - apply bauble
	; - disabled for now until todo completed
	; ApplyBauble()	

	; - re-apply bauble timer
	; - disabled for now until todo completed
	; StartBaubleTimer()		
}

; -----------------------------------------------------------[ KEY EVENTS ]---
^Esc::ExitApp

StartFishing(){
	global	
	;- find the app and activate it
	; if WinExist(APP_WINDOW_NAME) {		
		; MsgBox, fishin
		RUN_LOOP := true
		; - get things ready
		PreFishSetup()		

		; - letsa goooo
		MainLoop()			
	; }
}

StopFishing(){
	global
	RUN_LOOP := false
	StopLookForLureTimer()
	StopLookForFishOnLureTimer()	
}

; ctrl+3
; ^3::	
	; StartFishing()
; return