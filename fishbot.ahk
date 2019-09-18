;----------------------------------------------------------[ SETTINGS ]---
;
; - tried to catch a fish, nothing attached
NO_FISH_ATTACHED_X 			:= 1155
NO_FISH_ATTACHED_Y 			:= 209
NO_FISH_ATTACHED_COLOR 		:= 0x00ffff
BAUBLE_DURATION 			:= 15 ;- minutes

; - character sheet, primary weapon slot (fishing pole icon)
CHAR_SHEET_PRIM_WEAPON_X := 240
CHAR_SHEET_PRIM_WEAPON_Y := 849 

; - click grid settings
CG_START_X			:= 700
CG_START_Y			:= 300
CG_WIDTH 			:= 15
CG_HEIGHT 			:= 5
CG_OFFSET_X 		:= 50
CG_OFFSET_Y 		:= 50

; - caught a fish and loot box is open
LOOT_X 		:= 70
LOOT_Y 		:= 200
LOOT_COLOR 	:= 0x000000

; - Keybinds
CAST_LINE_KEY  				:= "!^f" 	; alt+ctrl+f
EQUIP_FISHING_POLE_KEY		:= "!f"   	; alt+f
APPLY_BAUBLE_KEY  			:= "^f"	  	; ctrl+f
OPEN_CHARACTER_SHEET_KEY    := "^c"   	; ctrl+c

; - Buable Flag
BAUBLE_EVENT_TRIGGERED      := false
BAUBLE_TIMER_COOLDOWN       := 16 ;- mins
BAUBLE_APPLICATION_DONE     := false

; ------------------------------------------------------------[ CastLine ]---
;
CastLine() {
	global	
	Send %CAST_LINE_KEY%
}

;-----------------------------------------------------------[ ApplyBauble ]---
;	
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

ApplyBaubleTimerEventCallback(){	
	global	
	BAUBLE_EVENT_TRIGGERED := true
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
;
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

;------------------------------------------------------------[ MainLoop ]---
;
MainLoop() {
	global
	; TODO apply bauble and start timer for next application;
	;

	; start looping right clicks	
	while true {
		
		if ( BAUBLE_EVENT_TRIGGERED ){			
			; - clear the flag, only run this once
			BAUBLE_EVENT_TRIGGERED  := false		

			; - reapply a new bauble
			ApplyBauble()	
			
		} else {
			
			CastLine()
			Sleep, 1500	
			RunClickGrid()
			Sleep, 1000		
		}

		; don't ever stop trying!
	}

	; TODO: re-apply bauble event timer
	;
}

; -----------------------------------------------------------[ KEY EVENTS ]---
Esc::ExitApp

; ctrl+1
^1::
	; MouseGetPos, x, y
	; MsgBox, %x%, %y%

	; - equip fishing pole
	Send %EQUIP_FISHING_POLE_KEY%
	Sleep, 1000

	; - apply first bauble
	ApplyBauble()

	; - set bauble refresh timer
	Duration := (1000*60*11)
	SetTimer, ApplyBaubleTimerEventCallback, %Duration%
	
	; - start fishing
	MainLoop()

return