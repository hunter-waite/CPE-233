; Hunter Waite
; 05/12/19
; Software Assignment 6 RAT Wrapper test

;- Port Constants
.EQU SWITCH_LOWER_PORT = 0x20
.EQU SWITCH_UPPER_PORT = 0x21         
.EQU LED_PORT = 0x40             
.EQU BTN_PORT = 0xFF  
.EQU SEVEN_SEG_PORT = 0x81  
         
; Bit masks for inputs
.EQU B0_MASK = 0x01              
.EQU B1_MASK = 0x02             
.EQU B2_MASK = 0x04
.EQU B3_MASK = 0x08
.EQU B4_MASK = 0x10
			
			; values for the LED outputs
			MOV R3, 0xFF
			MOV R4, 0x00
			MOV R5, 0x01
			OUT R3, LED_PORT ; Turns on all the LEDS
			
main:		IN  R1,   SWITCH_LOWER_PORT ; Reads values from the upper and lower switches
			IN  R0,   SWITCH_UPPER_PORT
			BRN btn_loop
			
btn_loop:	IN   R2, BTN_PORT ; Reads the inputs from the button port
			TEST R2, B4_MASK  ; Left button pressed
			BRNE BTNL_pressed
			TEST R2, B3_MASK  ; Up button pressed
			BRNE BTNU_pressed
			TEST R2, B2_MASK  ; Right button pressed
			BRNE BTNR_pressed 
			TEST R2, B1_MASK  ; Down button pressed
			BRNE BTND_pressed
			TEST R2, B0_MASK  ; Center button pressed
			BRNE BTNC_pressed
			BRN btn_loop      ; If none of the buttons are pressed infinite loop
	
									
BTNL_pressed: ; R0 + R1
				ADD R0, R1
				BRN output_seg
				
BTNU_pressed: ; R0 & R1
				AND R0, R1
				BRN output_seg
				
BTNR_pressed: ; R0 - R1
				SUB R0, R1
				BRN output_seg
				
BTND_pressed: ; R0 | R1
				OR R0, R1
				BRN output_seg
				
BTNC_pressed: ; This is a reset signal for now in the hardware, does nothing
				BRN end

output_seg:		OUT  R0, SEVEN_SEG_PORT 
				BRCS c_flag_set ; checks if the carry is set
				OUT  R4, LED_PORT ; if it isn turn off LEDS
				BRN  end
		
c_flag_set:		; if carry set turn on LSB of LEDS
				OUT R5, LED_PORT
				BRN end							
																	
end: 			BRN main

						

