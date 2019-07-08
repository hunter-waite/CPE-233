;---------------------------------------------------------------------
;- Hunter Waite
;- 06/05/19
;- CPE 233 Final Project: Snake-esque game
;- Uses a basic mambrane keyboard and vga monitor attached to the output
;- of a BASYS 3 board to play the game
;-
;- To play press any of the WASD keys to begin moving, don't run
;- into your white tail and collect all the blue coins
;- Your score is displayed on the SSEGs and it is how many coins you
;- collect
;- To reset the game press the escape button
;---------------------------------------------------------------------

.CSEG
.ORG 0x01

; variables used for VGA I/O
.EQU VGA_HADD  = 0x90
.EQU VGA_LADD  = 0x91
.EQU VGA_COLOR = 0x92
.EQU VGA_IN    = 0x93
; variables used for keyboard, swtiches ...
.EQU PS2_KEY_CODE = 0x44
.EQU SWITCHES_ID  = 0x20
.EQU BUTTONS_ID   = 0xFF
.EQU SSEG = 0x81
.EQU LEDS = 0x40
; Random number generator ID (8-bit)
.EQU RANDOM_ID    = 0x69
.EQU loop_count   = 0xAA
; Colors used
.EQU BG_COLOR       	 = 0             ; Background:  black
.EQU WHITE_COLOR   		 = 0xFF			 ; Essentially the snake color: WHITE
; Pause loop values
.EQU INSIDE_FOR_COUNT	 = 0xFF	  
.EQU MIDDLE_FOR_COUNT	 = 0xFF	 
.EQU OUTSIDE_FOR_COUNT	 = 0x10
; Speed of the player
.EQU SPEED_VAR			 = 185			 ; Lower is faster

;---------------------------------------------------------------------
init:	 ; for count variables that get changed
		 MOV R28, SPEED_VAR				; coutdown to next variable shift
		 MOV R29, INSIDE_FOR_COUNT
		 MOV R30, MIDDLE_FOR_COUNT
		 MOV R31, OUTSIDE_FOR_COUNT
		 
		 ; snake variables
		 MOV	R16, 0x28 				; snake x start position			
		 MOV	R17, 0x1E				; snake y start position
		 MOV	R18, 1					; snake x direction
		 MOV	R19, 1					; snake y direction
		 MOV 	R14, 0					; player score
		 
		 ; keycode initialization stuff
		 MOV	R1,  0					; used to hold keyboard keycode
		 MOV	R0,  0					; used to hold interpt cnt
		 MOV	R25, 0					; used to wait during the start of game
		 
		 ; Changes the move variables to move in a direction upon start          
		 MOV     R18, 2
		 MOV     R19, 1
			
		 ; draws the background
         CALL   draw_background         ; draw using default color
		
		 ; variables used for spawning dots
		 MOV R12, 0
		 CALL spawn_dot
		 
		 ; snake head initialization
         MOV    R7, R17                ; center Y coordinate
         MOV    R8, R16                ; center X coordinate
         MOV    R6, WHITE_COLOR         ; color red
         CALL   draw_dot                ; draw red square
		 
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Waits for an interrupt for the game to start		 
			SEI	 
wait:		CMP R25, 1
		    BRNE wait

; main loop that performs the movement as well as the speeding up
main:    	SEI
			SUB  R28, 1
			CMP  R28, 0		; checks for the speed up time
			BREQ subtract
cont:		CALL move_head
			MOV  R20,1
			CALL pause
			CMP  R12, 0
			BREQ call_spawn
			BRN  main  

call_spawn: CALL spawn_dot
			BRN  main

; does the subtraction of values from the loops with checks for overflow
subtract:   MOV  R28, SPEED_VAR
			CMP  R31, 0
			BREQ mid
			SUB  R31, 1
			BRN  cont
mid:	    CMP  R30, 0
			BREQ inside
			SUB  R30, 1
			BRN  cont
inside:		CMP  R29, 0
			BREQ cont
			SUB  R29, 1
			BRN  cont

; draws the game over stuff then waits for a restart interrupt
game_over:	CLI
			CALL draw_game_over_background
end:		SEI
			BRN end
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;- Subroutine: spawn_dot
;-
;- Spawns a dot at a random location using the psuedo-number genreator
;-
;- The random number generator uses an 8 bit value so it is refreshed
;- until a suitible number is found
;--------------------------------------------------------------------
spawn_dot:   	MOV    R12, 1
less_than_60:	IN     R7, RANDOM_ID
				ST     R7, 10
				SUB    R7, 59
				BRCC   less_than_60
				LD	   R7, 10
less_than_80:	IN     R8, RANDOM_ID    
				ST	   R8, 11
				SUB	   R8, 79
				BRCC   less_than_80
				LD     R8, 11
				MOV    R6, 3
				CALL   draw_dot_coin
				CMP	   R13, 0xFF
				BREQ   spawn_dot
				RET
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;- Subroutine: move_head
;-
;- Moves the ball based on the direction it is currently going and 
;- whether or not it has just hit the wall
;-
;- Parameters: (uses intialized ball parameters as well as all draw dot parameters
;-  R15 =  chosen direction
;-	R18 =  x direction boolean
;-  R19 =  y direction boolean
;--------------------------------------------------------------------
move_head:
		;DOT REDRAW
		; draws over the dot to the same color as the background
		MOV    R7, R17                
        MOV    R8, R16               
        MOV    R6, BG_COLOR
		;CALL   draw_dot
		
		;BORDER CHECKS
		; checks the left border
		CMP	   R16, 255
		BREQ   left
		; checks the right border
		CMP	   R16, 80
		BREQ   right
		;checks the top border
		CMP	   R17, 255
		BREQ   top
		;checks the bottom border
		CMP	   R17, 60
		BREQ   bottom
		; checks the left border
		CMP	   R15, 0
		BREQ   w
		; checks the right border
		CMP	   R15, 1
		BREQ   a
		;checks the top border
		CMP	   R15, 2
		BREQ   s
		;checks the bottom border
		CMP	   R15, 3
		BREQ   d
		;if none of the borders are triggered moves on
		BRN    cmp_1
		
		;BORDER FUNCTION
right:  ; if it hits the right border turn sideways boolean "off"
		MOV R18, 0
		BRN cmp_1
left:   ; if it hits the left border turn sideways boolean "on" 
		MOV R18,  1
		BRN cmp_1
top:    ; if it hits the top border turn veritical boolean "on"
		MOV R19,  1
		BRN cmp_1
bottom: ; if it hits the bottom border turn the vertical boolean "off"
		MOV R19, 0
		BRN cmp_1
		
		;KEYBOARD FUNCTIONS
w:		; moves it upward
		MOV R19, 0
		MOV R18, 2
		BRN cmp_1
a:		;moves it left
		MOV R18, 0
		MOV R19, 2
		BRN cmp_1
s:		;moves it down
		MOV R19, 1
		MOV R18, 2
		BRN cmp_1
d:		;moves it right
		MOV R18, 1
		MOV R19, 2
		BRN cmp_1
		
		;COMPARE AND MOVE FUNCTION
cmp_1:  ; checks to see if the sideways boolean is turned "on"
		MOV    R15, 5
		CMP	   R18, 1
		BREQ   add_mov_x ; move to the right if "on"
		CMP	   R18, 0
		BREQ   sub_mov_x ; move to the left if "off"
		BRN	   cmp_2
						
add_mov_x: ; moves sideways right
		ADD    R16, 1
		BRN	   cmp_2
sub_mov_x: ; moves sideways left
		SUB    R16, 1

cmp_2:	; checks to see if the vertical boolean is turned "on"
		CMP	   R19, 1
		BREQ   add_mov_y ; move down if "on"
		CMP	   R19, 0
		BREQ   sub_mov_y ; move up if "off"
		BRN	   draw
		
add_mov_y: ; moves down the screen
		ADD	   R17, 1
		BRN    draw
sub_mov_y: ; moves up the screen
		SUB    R17, 1

		; DRAW NEW DOT 
draw:	; draws the new dot after all the functions have been run
		MOV    R7, R17                
        MOV    R8, R16               
        MOV    R6, WHITE_COLOR
		CALL   draw_dot
		
return:
		RET
;--------------------------------------------------------------------
;-  Subroutine: draw_horizontal_line
;-
;-  Draws a horizontal line from (r8,r7) to (r9,r7) using color in r6
;-
;-  Parameters:
;-   r8  = starting x-coordinate
;-   r7  = y-coordinate
;-   r9  = ending x-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r8,r9
;--------------------------------------------------------------------
draw_horizontal_line:
        ADD    r9,0x01          ; go from r8 to r15 inclusive

draw_horiz1:
        CALL   draw_dot         
        ADD    r8,0x01
        CMP    r8,r9
        BRNE   draw_horiz1
        RET
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;-  Subroutine: draw_horizontal_line_go
;-
;-  Draws a horizontal line from (r8,r7) to (r9,r7) using color in r6
;-
;-  This is specific for the game over as it uses a different kind of
;-  dot check that prevents some issues with redrawing
;-
;-  Parameters:
;-   r8  = starting x-coordinate
;-   r7  = y-coordinate
;-   r9  = ending x-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r8,r9
;--------------------------------------------------------------------
draw_horizontal_line_go:
        ADD    r9,0x01          ; go from r8 to r15 inclusive

draw_horiz1z:
        CALL   draw_dot_no_chk         
        ADD    r8,0x01
        CMP    r8,r9
        BRNE   draw_horiz1z
        RET
;--------------------------------------------------------------------

;---------------------------------------------------------------------
;-  Subroutine: draw_vertical_line
;-
;-  Draws a vertical line from (r8,r7) to (r8,r9) using color in r6
;-
;-  Parameters:
;-   r8  = x-coordinate
;-   r7  = starting y-coordinate
;-   r9  = ending y-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r7,r9
;--------------------------------------------------------------------
draw_vertical_line:
         ADD    r9,0x01

draw_vert1:          
         CALL   draw_dot_no_chk
         ADD    r7,0x01
         CMP    r7,R9
         BRNE   draw_vert1
         RET
;--------------------------------------------------------------------

;---------------------------------------------------------------------
;-  Subroutine: draw_game_over_background
;-
;-  Writes the word "LOSS" in red across the screen 
;- 
;-  Tweaked registers: r10,r7,r8,r9
;----------------------------------------------------------------------
draw_game_over_background: 
		MOV R6,0xE0
		MOV R8, 8
		MOV R7, 6
		MOV R9, 45
		CALL draw_vertical_line
		MOV R8, 9
		MOV R7, 6
		MOV R9, 45
		CALL draw_vertical_line
		MOV R8, 10
		MOV R7, 44
		MOV R9, 22
		CALL draw_horizontal_line_go
		MOV R8, 10
		MOV R7, 45
		MOV R9, 22
		CALL draw_horizontal_line_go
		
		MOV R8, 25
		MOV R7, 7
		MOV R9, 46
		CALL draw_vertical_line
		MOV R8, 26
		MOV R7, 7
		MOV R9, 46
		CALL draw_vertical_line
		MOV R8, 27
		MOV R7, 46
		MOV R9, 35
		CALL draw_horizontal_line_go
		MOV R8, 27
		MOV R7, 45
		MOV R9, 35
		CALL draw_horizontal_line_go
		MOV R8, 36
		MOV R7, 7
		MOV R9, 46
		CALL draw_vertical_line
		MOV R8, 37
		MOV R7, 7
		MOV R9, 46
		CALL draw_vertical_line
		MOV R8, 27
		MOV R7, 8
		MOV R9, 35
		CALL draw_horizontal_line_go
		MOV R8, 27
		MOV R7, 7
		MOV R9, 35
		CALL draw_horizontal_line_go
		
		MOV R8, 41
		MOV R7, 8
		MOV R9, 51
		CALL draw_horizontal_line_go
		MOV R8, 41
		MOV R7, 7
		MOV R9, 51
		CALL draw_horizontal_line_go
		MOV R8, 41
		MOV R7, 8
		MOV R9, 24
		CALL draw_vertical_line
		MOV R8, 42
		MOV R7, 8
		MOV R9, 24
		CALL draw_vertical_line
		MOV R8, 41
		MOV R7, 23
		MOV R9, 51
		CALL draw_horizontal_line_go
		MOV R8, 41
		MOV R7, 24
		MOV R9, 51
		CALL draw_horizontal_line_go
		MOV R8, 50
		MOV R7, 23
		MOV R9, 46
		CALL draw_vertical_line
		MOV R8, 51
		MOV R7, 23
		MOV R9, 46
		CALL draw_vertical_line
		MOV R8, 41
		MOV R7, 45
		MOV R9, 51
		CALL draw_horizontal_line_go
		MOV R8, 41
		MOV R7, 46
		MOV R9, 51
		CALL draw_horizontal_line_go
		
		MOV R8, 54
		MOV R7, 8
		MOV R9, 64
		CALL draw_horizontal_line_go
		MOV R8, 54
		MOV R7, 7
		MOV R9, 64
		CALL draw_horizontal_line_go
		MOV R8, 54
		MOV R7, 8
		MOV R9, 24
		CALL draw_vertical_line
		MOV R8, 55
		MOV R7, 8
		MOV R9, 24
		CALL draw_vertical_line
		MOV R8, 54
		MOV R7, 23
		MOV R9, 64
		CALL draw_horizontal_line_go
		MOV R8, 54
		MOV R7, 24
		MOV R9, 64
		CALL draw_horizontal_line_go
		MOV R8, 63
		MOV R7, 23
		MOV R9, 46
		CALL draw_vertical_line
		MOV R8, 64
		MOV R7, 23
		MOV R9, 46
		CALL draw_vertical_line
		MOV R8, 54
		MOV R7, 45
		MOV R9, 64
		CALL draw_horizontal_line_go
		MOV R8, 54
		MOV R7, 46
		MOV R9, 64
		CALL draw_horizontal_line_go
        RET
;---------------------------------------------------------------------

;---------------------------------------------------------------------
;-  Subroutine: draw_background
;-
;-  Fills the 80x60 grid with one color using successive calls to 
;-  draw_horizontal_line subroutine. 
;- 
;-  Tweaked registers: r10,r7,r8,r9
;----------------------------------------------------------------------
draw_background: 
         MOV   r6,BG_COLOR              ; use default color
         MOV   r10,0x00                 ; r10 keeps track of rows
start:   MOV   r7,r10                   ; load current row count 
         MOV   r8,0x00                  ; restart x coordinates
         MOV   r9,0x4F 					; set to total number of columns
 
         CALL  draw_horizontal_line_go
         ADD   r10,0x01                 ; increment row count
         CMP   r10,0x3C                 ; see if more rows to draw
         BRNE  start                    ; branch to draw more rows
         RET
;---------------------------------------------------------------------
    
;---------------------------------------------------------------------
;- Subrountine: draw_dot
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;-  It also checks to see if the player has run into itself or a coin
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  

;---------------------------------------------------------------------
draw_dot: 
		   OUT   R8,  VGA_LADD   ; write bot 8 address bits to register
           OUT   R7,  VGA_HADD   ; write top 5 address bits to register
		   IN    R13, VGA_IN   ; checks the next tile color
		   CMP	 R13, 0xFF	   ; checks the color for white
		   BREQ  game_over	   ; if its white that means you've run into yourself, game over
		   CMP	 R13, 0x03	   ; checks the color for blue
		   BREQ  change	       ; if its blue that means you've run into coin, set coin value to none
           OUT   R6,VGA_COLOR  ; write color data to frame buffer
           RET     
		   
change:    MOV R12, 0
		   OUT R6,VGA_COLOR  ; write color data to frame buffer
		   ADD R14, 1		 ; adds one to the player score
		   OUT R14, SSEG	 ; outputs it to the seven seg
           RET
; --------------------------------------------------------------------

;---------------------------------------------------------------------
;- Subrountine: draw_dot_no_chk
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  

;---------------------------------------------------------------------
draw_dot_no_chk: 
		   OUT   R8,  VGA_LADD   ; write bot 8 address bits to register
           OUT   R7,  VGA_HADD   ; write top 5 address bits to register
           OUT   R6,  VGA_COLOR  ; write color data to frame buffer
           RET           
; --------------------------------------------------------------------

;---------------------------------------------------------------------
;- Subrountine: draw_dot_coin
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  

;---------------------------------------------------------------------
draw_dot_coin: 
		   OUT   R8,  VGA_LADD   ; write bot 8 address bits to register
           OUT   R7,  VGA_HADD   ; write top 5 address bits to register
		   IN    R13, VGA_IN     ; checks the next tile color
		   CMP	 R13, 0xFF	     ; checks the color for white
		   BREQ  dd			     ; if its white that means spawned on snak
           OUT   R6,  VGA_COLOR  ; write color data to frame buffer
dd:        RET           

; ---------------------------------------------------------------
; Subroutine: PAUSE
; Parameters: R20 - multiple of .5 seconds (must be greater than one)
; Returns: None
; Register Uses:
;	R21 - Variable For Count
; 	R22 - Outside For Count
;	R23 - Middle For Count
;	R24 - Inside For Count
; ---------------------------------------------------------------
pause:			
				MOV		R21, R20					; set variable for loop to parameter
variable_for:	SUB		R21, 0x01
				MOV 	R22, R31					; set outside for loop count
outside_for: 	SUB     R22, 0x01
				MOV     R23, R30					; set middle for loop count
middle_for:		SUB     R23, 0x01
				MOV     R24, R29					; set inside for loop count
inside_for:		SUB     R24, 0x01
				BRNE    inside_for
				OR      R23, 0x00		; load flags for middle for counter
				BRNE    middle_for
				OR      R22, 0x00		; load flags for outsde for counter value
				BRNE    outside_for
				OR 		R21, 0x00		; load flags for number of loops
				BRNE	variable_for
				RET	


; --------------------------------------------------------------------
; Interrupts service routine; checks keycodes for the WASD and Escape Keys
; --------------------------------------------------------------------
My_ISR:		IN  R1, PS2_KEY_CODE
			CMP R1, 0x76
			BREQ reset
			CMP R1,  0x29
			MOV R25, 1
			BREQ return_from_here
			CMP R1,  29 ; W
			MOV R15, 0
			BREQ return_from_here
			CMP R1,  28 ; A
			MOV R15, 1
			BREQ return_from_here
			CMP R1,  27 ; S
			MOV R15, 2
			BREQ return_from_here
			CMP R1,  35 ; D
			MOV R15, 3
			BRN return_from_here
			
reset:		CALL init
			
return_from_here:			
			RETIE
; --------------------------------------------------------------------
; interrupt vector
; --------------------------------------------------------------------
.CSEG
.ORG 0x3FF
BRN My_ISR

