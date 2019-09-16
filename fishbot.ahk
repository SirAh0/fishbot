;----------------------------------------------------------[ SETTINGS ]---
;
; - tried to catch a fish, nothing attached
NO_FISH_ATTACHED_X 			:= 1155
NO_FISH_ATTACHED_Y 			:= 209
NO_FISH_ATTACHED_COLOR 		:= 0x00ffff
BAUBLE_DURATION 			:= 15 ;- minutes

; - click grid settings
START_FISH_X 				:= 550
START_FISH_Y 				:= 100
CLICK_GRID_WIDTH 			:= 15
CLICK_GRID_HEIGHT 			:= 6
CLICK_GRID_OFFSET_X 		:= 50
CLICK_GRID_OFFSET_Y 		:= 50

; - caught a fish and loot box is open
LOOT_X 		:= 1155
LOOT_Y 		:= 209
LOOT_COLOR 	:= 0x000000

; - Keybinds
CAST_LINE_KEY  := "f"



; -----------------------------------------------------------[ KEY EVENTS ]---
Esc::ExitApp

^1::
	MainLoop()
return



; ------------------------------------------------------------[ MainLoop ]---
;
MainLoop() {

	; TODO apply bauble and start timer for next application;
	;

	; start looping right clicks	
	while true {
		CastLine()
		Sleep, 1500	
		RunClickGrid()
		Sleep, 1000		
		
		; don't ever stop trying!
	}

	; TODO: re-apply bauble event timer
	;
}

; ------------------------------------------------------------[ CastLine ]---
;
CastLine() {
	global
	Send %CAST_LINE_KEY%
}

;-----------------------------------------------------------[ ApplyBauble ]---
;	TODO
ApplyBauble(){

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

	Loop, %CLICK_GRID_WIDTH% {
		x := (A_Index*CLICK_GRID_OFFSET_X)+START_FISH_X
		Loop, %CLICK_GRID_HEIGHT% {	
			y := (A_Index*CLICK_GRID_OFFSET_Y)+START_FISH_Y
			MouseMove, x, y			
			Send +{Click, right}
			; Click, right	
			Sleep, 200

			; see if this attempt found no fish (yellow error text)
			if ( TestForColor( 	NO_FISH_ATTACHED_X, NO_FISH_ATTACHED_Y,NO_FISH_ATTACHED_COLOR) ) 
				return

			; see if this attempt found a fish (loot window)
			if ( TestForColor( LOOT_X, LOOT_Y, LOOT_COLOR ) ) 
				return				
		}
	}
}