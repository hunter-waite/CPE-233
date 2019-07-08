; Hunter Waite
; Software Assignment 7
; Pauses for a multiple of .5s based on which LED is on
; Register Uses:
;	R6: Main loop count
;	R5: The output of the LEDS
;	R4: Used to pass to pause
.EQU INSIDE_FOR_COUNT	= 0xFF	  
.EQU MIDDLE_FOR_COUNT	= 0xFF	 
.EQU OUTSIDE_FOR_COUNT	= 0x50
.EQU MAIN_LOOP_COUNT	= 8
.EQU LED_PORT           = 0x40       
      
start:		MOV		R6, MAIN_LOOP_COUNT ; LED loop
			MOV		R5, 0				; LED output
			MOV 	R4, 1				; parameter for pause

main_loop:	SUB		R6, 0x01
			CALL	pause				; pauses for R4 * (0.5s)
			ADD		R4, 0x01			
			SEC							; sets carry flag for LEDS
			LSL		R5					; shifts carry into LSB
			OUT 	R5, LED_PORT		; outputs to the LEDS
			OR		R6, 0x00			; resets flags for branch
			BRNE	main_loop
			MOV 	R4, 0x08			; calls pause one more time for 8 seconds
			CALL	pause
			BRN 	start				; restarts
				
; ---------------------------------------------------------------
; Subroutine: PAUSE
; Parameters: R4 - multiple of .5 seconds (must be greater than one)
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
