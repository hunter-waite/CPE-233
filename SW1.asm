; Software assignment 1 part 1
; By: Hunter Waite
; 04/04/19
; Reads 3 inputs from port 3 and puts the result to port 4

.CSEG
.ORG 0x01
start:		IN  R1, 0x03
			IN  R2, 0x03
			IN  R3, 0x03
			ADD R1, R2
			ADD R1, R3
			OUT R1, 0x04
			BRN start
			
			