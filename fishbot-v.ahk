; #NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
; SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  	; Ensures a consistent starting directory.
; 
; #SingleInstance,Force			;single script instance
; CoordMode, Pixel, Screen		;change CoordMode so that X/Y is relative to screen, and not window
; CoordMode, Mouse, Screen		;change CoordMode so that X/Y is relative to screen, and not window

;---------------------------------[ SETTINGS ]------------------------------

LURE_LOCATION_X		:= 0
LURE_LOCATION_Y		:= 0

;avoid searching the whole screen
;instead, cut a factor off each side and only scan the remaining center
;value should be 3 or greater
WIDTH_TRIM_FACTOR	:= 4
HEIGHT_TRIM_FACTOR	:= 3

;fishing timer bar is 30 seconds
FISHING_TIMER := 30

FISHING_LURE_MATCH_COLOR := 0x0E142D


OutputScreenSize(){
	global
	MsgBox, The screenwidth is: %A_ScreenWidth%.
	MsgBox, The screenheight is: %A_ScreenHeight%
	;MsgBox, X trim factor is: %WIDTH_TRIM_FACTOR%
	;MsgBox, %LOOT_X%
	;MsgBox, Y trim factor is %HEIGHT_TRIM_FACTOR%
}


;1920 / 3 = 640 * 2 = 1280
;1080 / 3 = 360 * 2 =  720

;1920 / 4 = 480 * 3 = 1440
;1080 / 4 = 270 * 3 =  810

;1920 / 5 = 384 * 4 = 1536
;1080 / 5 = 216 * 4 =  864

;1920 / 6 = 320 * 5 = 1600
;1080 / 6 = 180 * 5 =  900



LeftBounds(){
	global

	return (A_ScreenWidth) / WIDTH_TRIM_FACTOR
}
UpperBounds(){
	global
	return (A_ScreenHeight) / HEIGHT_TRIM_FACTOR
}
RightBounds(){
	global
	return (A_ScreenWidth) / WIDTH_TRIM_FACTOR * (WIDTH_TRIM_FACTOR - 1)
}
LowerBounds(){
	global
	return (A_ScreenHeight) / HEIGHT_TRIM_FACTOR * (HEIGHT_TRIM_FACTOR - 1)
}




LocateLure() {
	global
	
	;red/orange from the bobber in hex: 0xD4411F
	;another red/orange:                0xFF4819
	;									0xC43915
	;PixelSearch, ax, ay, 0, 0, A_ScreenWidth, A_ScreenHeight, 0xFF4819, 3, Fast RGB	
	
	;search inside an area thats 1/2 screen size, centered in screen
	;PixelSearch, ax, ay, A_ScreenWidth / WIDTH_TRIM_FACTOR, A_ScreenHeight / HEIGHT_TRIM_FACTOR, A_ScreenWidth, A_ScreenHeight, 0xFF4819, 2, Fast RGB
	;MsgBox, X trim factor is: %WIDTH_TRIM_FACTOR%

	;this outputs correctly
	;var1 := LeftBounds()
	;MsgBox, leftbound is: %var1%
	
	;this doesnt work
	;var1 := LeftBounds()
	;MsgBox, leftbound is: %LeftBounds% 
	
	PixelSearch, ax, ay, 600,300,1650,650, FISHING_LURE_MATCH_COLOR, 3, Fast

	if ErrorLevel = 2
		MsgBox, error2
	if ErrorLevel = 1
		MsgBox, error1, color not found
	if ErrorLevel = 0
		MouseMove, %ax%, %ay%
		; MsgBox, the color was found at %ax% %ay%
	return
}
;------------------------------------------------------------[ MainLoop ]---
;
MainLoop() {
	global
	;don't ever stop trying!
	while true {
		LocateLure()
		;OutputScreenSize()
		Sleep, 4000
	}
}

; -----------------------------------------------------------[ KEY EVENTS ]---
Esc::ExitApp

; ctrl+1
^1::	
	; MouseGetPos, x, y
	; PixelGetColor, Color, x, y
	; MsgBox %Color%

	;initial setup goes here	
	; - start fishing
	MainLoop()

	; PixelGetColor, color, 250, 250
	; PixelSearch, ax, ay, 0,0,500,500, BLUE, 3, Fast
	; if ErrorLevel
	    ; MsgBox, That color was not found in the specified region.
	; else
	    ; MsgBox, A color within 3 shades of variation was found at X%ax% Y%ay%.
	

return