; Hunter Waite
; 05/27/2019

.EQU SWITCH_PORT        = 0x20
.EQU LEDS 	    	    = 0x40
.EQU SEG_PORT           = 0x81
.EQU INSIDE_FOR_COUNT	= 0xFF	  
.EQU MIDDLE_FOR_COUNT	= 0xFF	 
.EQU OUTSIDE_FOR_COUNT	= 0x50

.CSEG
.ORG 0x10
			SEI
			MOV  R5, 0x03
main_loop:  IN   R6, SWITCH_PORT
			EXOR R6, 0xFF
			OUT  R6, LEDS
			OUT  R5, SEG_PORT
			BRN  main_loop

loop_set:	MOV  R4, 0x01
			MOV  R7, 0x03
			OUT  R7, LEDS
			CALL pause
			MOV  R5, 0x03
			SEI
			BRN main_loop
	
isr:		SUB  R5, 0x01
			CMP  R5, 0x00
			BREQ loop_set 
			OUT  R5, SEG_PORT
			RETIE


; ---------------------------------------------------------------
; Subroutine: PAUSE
; Parameters: R4 - multiple of .5 seconds (must be greater than or equal to one)
; Returns: None
; Register Uses:
;	R0 - Variable For Count
; 	R1 - Outside For Count
;	R2 - Middle For Count
;	R3 - Inside For Count
; ---------------------------------------------------------------

pause:			
				MOV		R0, R4					; set variable for loop to parameter
variable_for:	SUB		R0, 0x01
				MOV 	R1, OUTSIDE_FOR_COUNT	; set outside for loop count
outside_for: 	SUB     R1, 0x01
				MOV     R2, MIDDLE_FOR_COUNT	; set middle for loop count
middle_for:		SUB     R2, 0x01
				MOV     R3, INSIDE_FOR_COUNT	; set inside for loop count
inside_for:		SUB     R3, 0x01
				BRNE    inside_for
				OR      R2, 0x00		; load flags for middle for counter
				BRNE    middle_for
				OR      R1, 0x00		; load flags for outsde for counter value
				BRNE    outside_for
				OR 		R0, 0x00		; load flags for number of loops
				BRNE	variable_for
				RET	

			
.CSEG
.ORG 0x3FF  ;interrupt vector
vector:     BRN isr
