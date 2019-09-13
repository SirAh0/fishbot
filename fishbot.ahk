Esc::ExitApp

^1::
	MainLoop()
return

MainLoop() {

	; start looping right clicks	
	while true {
		CastLine()
		Sleep, 1500	
		RunClickGrid()
		Sleep, 1000		
		
		; don't ever stop trying!
	}

	; re-apply bauble event timer
	;
}

CastLine() {
	Send f
}

; after every right click, possible capture
; if yellow error text appears, Break and CastLine
TestForColor() {
	; loop over the specific area whre the error message appears	
	PixelGetColor, color, %MouseX%, %MouseY%
	MsgBox The color at the current cursor position is %color%.	
}

RunClickGrid() {
	sx := 250	; start coords
	sy := 100
	w := 15		; grid width, height
	h := 6
    ox := 90	; offset mouse move
    oy := 90

	Loop, %w% {
		x := (A_Index*ox)+sx
		Loop, %h% {	
			y := (A_Index*oy)+sy
			MouseMove, x, y			
			Send +{Click, right}
			; Click, right	
			Sleep, 45
		}		
	}
}