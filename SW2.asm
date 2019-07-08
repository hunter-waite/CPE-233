; Software assignment 2 part 2
; By: Hunter Waite
; 04/09/19
; Reads the input from port 0x03
; if val is mult of 4 !val
; else if val odd val = (val + 17)/2
; else val = val-1
; outputs to port 0x04

.CSEG
.ORG 0x01
.EQU IN_PORT = 0x03
.EQU OUT_PORT = 0x04

main_loop:		IN   R0, IN_PORT
				MOV  R1, R0
				ROR  R1
				BRCS odd_func
				ROR  R1
				BRCC mult_four
				BRN  sub_one
				
odd_func:		ADD R0, 17
				CLC 
				LSR R0
				OUT R0, OUT_PORT
				BRN main_loop
				
mult_four:		EXOR R0, 0xFF
				OUT R0, OUT_PORT
				BRN main_loop
				
sub_one:		SUB R0, 1
				OUT R0, OUT_PORT
				BRN main_loop
				
				