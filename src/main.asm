; file: main.asm        target: ATmega128L-4MHz-STK300
; Authors: Andrea Diez Leboffe, Rodrigue de Guerre
; Purpose: Main entry point of the program

; ==== Top-level includes ===
.include "m128def.inc"
.include "definitions.asm"
.include "macros.asm"

; ==== Interrupt vector table ====

.org 0x0000
	rjmp reset

.org INT7addr
	rjmp remote_INT	

; ==== Device reset ====
reset:
	LDSP		RAMEND 					        ; load stack pointer SP
   	OUTI		EIMSK,(1<<7)			        ; enable INT7
	OUTI		EICRB,(0<<ISC71)+(1<<ISC70)     ; Interupt on any edge (rising or falling)  
	OUTI		DDRD,0x0f				        ; make motor port output
    sei								            ; set global interrupt
	rcall		LCD_init				        ; initialize LCD
	rcall		wire1_init			            ; initialize 1-wire(R) interface
	rjmp		main					        ; jump to main

; ====== Programm Constants ======
.equ		T1			=	1778				; bit period T1 = 1778 usec
.equ		T_MOT 		=	1000				; waiting period in micro-seconds
.equ		port_mot	=	PORTD				; port to which motor is connected
.equ		menuGuide	=	0b11011101
.equ		increaseVol	=	0b11101111
.equ		decreaseVol	=	0b11101110
.equ		AV_confirm	=	0b11000111

; ==== Interruptions routines ==== 

remote_INT:
	ldi 		r28,2							; load arbitrary value to r28 to enable interrupts check in other modules
	reti

; ==== Modules Imports ====	
.include "drivers/lcd.asm"				; include LCD driver routines
.include "drivers/wire1.asm"			; include Dallas 1-wire(R) routines
.include "lib/printf.asm"			    ; include formatted printing routines	

.include "menu.asm"
.include "run.asm"
.include "remote.asm"
.include "temp.asm"


; ===== Main Entry Point =====
main:
    cli									; interrupts are already disabled locally in the modules but this allows to clearly identify it 
	clr         r28						; And adds 'symmetry' with the below sei
	rcall       menu
	rcall       LCD_clear
    sei									
	jmp         run
