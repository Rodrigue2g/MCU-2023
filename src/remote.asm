; file: remote.asm        target: ATmega128L-4MHz-STK300
; Authors: Andrea Diez Leboffe, Rodrigue de Guerre
; Purpose: Remote controll signal processing

remote:
	cli								; diable interrupts to enable remote controll
	clr 		r28					; clear 'interrupt check value'
ir_detet:
	CLR2		b1,b0				; clear 2-byte register
	ldi			b2,14				; load bit-counter
	WP1			PINE,IR				; Wait if Pin=1 	
	WAIT_US		(T1/4)				; wait a quarter period
	
menu_loop:	
	P2C			PINE,IR				; move Pin to Carry (P2C)
	ROL2		b1,b0				; roll carry into 2-byte reg
	WAIT_US		(T1-4)				; wait bit period (- compensation)	
	DJNZ		b2,menu_loop		; Decrement and Jump if Not Zero
	
	com			b0					; complement b0
	ret