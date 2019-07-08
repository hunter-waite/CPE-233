; Hunter Waite
; 04/25/2019
; Software Assignment 4 Part 2
; Bubble Sort

.DSEG 
.ORG 0x01
.DB 3,5,5,120,6,2,9,8,233,1

.CSEG
.ORG 0x21

				MOV R0, 10 ; memory location helper and counter
				; origin is at 0x01 so the intitial loaded values should
				; be from memory locations 1 and 2
				MOV R1, 1 ; memory location 1
				MOV R2, 2 ; memory location 2

main_loop:		CMP  R0,  1 ; when the mem helper reaches one you know you are done with the sort
				BREQ finish
				LD   R3, (R1)
				LD   R4, (R2)
				CMP  R4,  R3
				BRCS swap_and_store
				ST   R3, (R1)
				ST   R4, (R2)
				BRN  increment
				
swap_and_store: ST R3, (R2)
				ST R4, (R1)
				BRN increment
				
increment:		CMP  R2, R0 ; when the second memory location is the same as the memory helper
							; you know you are at the end of a round
					     	; in increment because it needs to be checked after all operations are performed
				BREQ new_round
				ADD  R1, 1 ; incrememnts the memory locations to move along the array
				ADD  R2, 1
				BRN  main_loop
				
new_round:		SUB R0, 1 ; takes one away from the mem helper
				MOV R1, 1 ; moves the memory locations back to the beginning
				MOV R2, 2
				BRN main_loop
				
finish:			OUT R4, 0x01
				
