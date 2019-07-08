; Hunter Waite
; 05/05/19
; Software assignment 5 part 2

.EQU A = 0x05
.EQU B = 0x52
.EQU C = 0x64
.EQU D = 0x64
.EQU IN_PORT  = 0x0A
.EQU OUT_PORT = 0x0B

.CSEG
.ORG 0x01
			IN  R10, IN_PORT
			MOV R0,  A

loop_a:		ADD R20, 0x01
			SUB R0,  0x01
			
			MOV R1,  B
loop_b:		ADD R20, 0x01
			SUB R1,  0x01
				
			MOV R2,  C		
loop_c:		ADD R20, 0x01
			SUB R2,  0x01
			
			MOV R3,  D
loop_d		ADD R20, 0x01
			SUB R3,  0x01
			BRNE loop_d
			OR R2, 0x00
			BRNE loop_c
			OR R1, 0x00
			BRNE loop_b
			OR R0, 0x00
			BRNE loop_a

end:		OUT R10, OUT_PORT