#SingleInstance,Force
CoordMode, Pixel, Window
CoordMode, Mouse, Window

; ======================================================[ SETTINGS / GLOBALS ]===
;
; - tried to catch a fish, nothing attached
NO_FISH_ATTACHED_X 			:= 1155
NO_FISH_ATTACHED_Y 			:= 209
BAUBLE_DURATION 			:= 15 ;- minutes

; - character sheet, primary weapon slot (fishing pole icon)
CHAR_SHEET_PRIM_WEAPON_X := 240
CHAR_SHEET_PRIM_WEAPON_Y := 849 

; - click grid settings
; CG_START_X			:= 700
; CG_START_Y			:= 300
; CG_WIDTH 			:= 15
; CG_HEIGHT 			:= 5
; CG_OFFSET_X 		:= 50
; CG_OFFSET_Y 		:= 50

; - caught a fish and loot box is open
LOOT_X 		:= 70
LOOT_Y 		:= 200


; - Keybinds
CAST_LINE_KEY  				:= "!^f" 	; alt+ctrl+f
EQUIP_FISHING_POLE_KEY		:= "!f"   	; alt+f
APPLY_BAUBLE_KEY  			:= "^f"	  	; ctrl+f
OPEN_CHARACTER_SHEET_KEY    := "^c"   	; ctrl+c

; - Buable Flag
BAUBLE_EVENT_TRIGGERED      := false
BAUBLE_TIMER_COOLDOWN       := 16 ;- mins
BAUBLE_APPLICATION_DONE     := false

; - Bauble Bounding Boxes
FIND_LURE_BOUNDING_BOX_X 	:= 0
FIND_LURE_BOUNDING_BOX_DX   := 0
FIND_LURE_BOUNDING_BOX_Y 	:= 0
FIND_LURE_BOUNDING_BOX_DY   := 0

BAUBLE_BOX_X_OFFSET 		:= 100
BAUBLE_BOX_Y_OFFSET 		:= 100

; - COLOR MATCHING
COLOR_SEARCH_PIXEL_OFFSET	:= 10
FISHING_LURE_MATCH_COLOR	:= 0x0E142D
NO_FISH_ATTACHED_COLOR 		:= 0x00ffff
LOOT_COLOR 					:= 0x000000
FISH_ON_LURE_COLOR 			:= 0xFEFEFE

; - looking for fish timers
LOOK_FOR_LURE_DURATION 		  		:= 30 ;- seconds
LOOK_FOR_FISH_ON_LURE_DURATION 		:= 30 ;- seconds
LOOK_FOR_LURE_TIMER_RUNNING	    	:= false
LOOK_FOR_FISH_ON_LURE_TIMER_RUNNING := false

; - window info
APP_WINDOW_WIDTH 					:= 0
APP_WINDOW_HEIGHT 					:= 0
APP_WINDOW_NAME 					:= "World of Warcraft"

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
	global
	LOOK_FOR_FISH_ON_LURE_TIMER_RUNNING = false
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
LookForFishOnLure(x,y) {
	global

	StartLookForFishOnLureTimer()

	while LOOK_FOR_FISH_ON_LURE_TIMER_RUNNING {

		sx  := x-BAUBLE_BOX_X_OFFSET
		sy  := y-BAUBLE_BOX_Y_OFFSET
		dx  := x+BAUBLE_BOX_X_OFFSET
		dy  := y+BAUBLE_BOX_Y_OFFSET

		
		PixelSearch, fx, fy, sx, sy, dx, dy, FISH_ON_LURE_COLOR, COLOR_SEARCH_PIXEL_OFFSET, Fast
		; if ErrorLevel = 2
			; MsgBox, no found
		; if ErrorLevel = 1
			; MsgBox, no found
		
		if ( ErrorLevel = 0 ) {
			Sleep, 500
			CollectFoundFish()
			Sleep, 1000
			
			; - fish found, stop looking for it
			StopLookForFishOnLureTimer()
			
			; - let the bot breath (maybe not needed)
			Sleep, 1500	
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

	PixelSearch, x, y, sx, sy, dx, dy, FISHING_LURE_MATCH_COLOR, COLOR_SEARCH_PIXEL_OFFSET, Fast	

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
		
		; - try to find the lure
		m  := LocateLureByPixel() 
		if ( m ){			
			mx := m[1]
			my := m[2]			
			
			MouseMove, %mx%, %my%			
			StopLookForLureTimer()
			LookForFishOnLure(mx,my)						
			return
		}			

		Sleep, 2050
	}
}


;------------------------------------------------------------[ MainLoop ]---
; TODO: add timetout function
MainLoop() {
	global
	; start looping right clicks	
	while true {
		
		; if ( BAUBLE_EVENT_TRIGGERED ){			
			; - clear the flag, only run this once
			; BAUBLE_EVENT_TRIGGERED  := false		

			; - reapply a new bauble
			; ApplyBauble()	
			
		; } else {
			
			CastLine()


			LookForLure()			
			Sleep, 1000
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
Esc::ExitApp

; ctrl+1
^1::	
	;- find the app and activate it
	if WinExist(APP_WINDOW_NAME) {		
		; - get things ready
		PreFishSetup()		

		; - letsa goooo
		MainLoop()			
	}
return