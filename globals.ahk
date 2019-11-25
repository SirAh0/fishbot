; ======================================================[ SETTINGS / GLOBALS ]===
;
STATE_BUTTON_ON  := 2
STATE_BUTTON_OFF := 1

RUN_LOOP := false
; - tried to catch a fish, nothing attached
; - TODO: figure out dynamic ratio of error message screen position
; - current assumption: 1440p
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

; - found fish at 
FOUND_LURE_X := 0
FOUND_LURE_Y := 0

; - Keybinds
CAST_LINE_KEY  	 := "!^f" 	; alt+ctrl+f
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

BAUBLE_BOX_X_OFFSET 		:= 200
BAUBLE_BOX_Y_OFFSET 		:= 200

; - COLOR MATCHING
COLOR_SEARCH_PIXEL_RED_OFFSET	:= 15
COLOR_SEARCH_PIXEL_WHITE_OFFSET	:= 15
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