; file: run.asm        target: ATmega128L-4MHz-STK300
; Authors: Andrea Diez Leboffe, Rodrigue de Guerre
; Purpose: Temperature comparison and activation of the motor

run:
	cli
	clr			r28
temp:
	rcall		read_temp

_displayTemp:
    PRINTF  	LCD
    .db "Temp=", FFRAC2+FSIGN, a, 4, $42, "C ", LF			;, 0, 0
	.db CR, CR,"Limit=", FFRAC2+FSIGN, b, 4, $42, "C ",CR,0

_test_temp:
	cp 			a1,b1 						; compare high byte (MSByte)
	brlo 		PC+3
	cp 			a0,b0 						; compare low byte (LSByte)
	brsh 		mot_loop					
	clr 		r28	
	sei

_back_to_menu:
	WAIT_MS		1000
	cpi			r28,2
	brne		PC+5
	rcall 		remote
	cpi 		b0,menuGuide				; check if back to menu asked
	brne		PC+2						; reg b0 ok to use because overriden by new temp in call read_temp
	rjmp		main
    rjmp		run

mot_loop:
	sei	
	MOTOR		0b0100						; output motor patterns
	MOTOR		0b1110
	MOTOR		0b1010
	MOTOR		0b1011
	MOTOR		0b0001	
	MOTOR		0b0101
	cpi			r28,2
	breq		PC+2
	rjmp		mot_loop
	rjmp		main						; Could change for rjmp 'run' // rjmp 'main' enables you to change the limit temp
		
wait:	
	WAIT_US		T_MOT						; wait routine called in macro MOTOR (cf macros.asm)
	ret