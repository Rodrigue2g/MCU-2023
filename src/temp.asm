; file temp.asm   target ATmega128L-4MHz-STK300		
; Authors: Andrea Diez Leboffe, Rodrigue de Guerre
; Purpose: Dallas 1-wire(R) temperature sensor routine 
; ==> reads temperature from sensor and stores it in reg a0,a1
;
read_temp:
	rcall		wire1_reset					
	CA			wire1_write, skipROM		
	CA			wire1_write, convertT
	WAIT_MS		750							; wait time for the chip to be accessed while the temp is being converted

	rcall		lcd_home					
	rcall		wire1_reset	
	CA			wire1_write, skipROM		
	CA			wire1_write, readScratchpad
	rcall		wire1_read					; reads temp LSByte and stores result in a0   
	mov			c0, a0						 
	rcall		wire1_read					; reads temp MSByte
	mov			a1, a0						; MSByte in a1
	mov			a0, c0						; LSByte in a0
	ret