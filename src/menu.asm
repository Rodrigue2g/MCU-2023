; file: menu.asm        target: ATmega128L-4MHz-STK300
; Authors: Andrea Diez Leboffe, Rodrigue de Guerre
; Purpose: Selection of the limit temperature

 menu:
	rcall 		LCD_clear
	rcall		LCD_home	
	PRINTF 		LCD
	.db "Choix de TempLim",CR,0

	WAIT_MS 	2000
	ldi 		a2,0b10110000  		; set intinal TempLim value to 27�C	(a2=TempLim LSByte)
	ldi 		a3,0b00000001		; TempLim MSByte
	MOV2		b0,b1, a2,a3
	rcall 		LCD_clear
	rcall		LCD_home	
	PRINTF 		LCD
	.db "TempLim=",FFRAC2+FSIGN,b,4,$42,"C ",CR,0
_get_ir_value:
	rcall 		remote				; ir_detect
	WAIT_MS		100					; Wait 100ms for calibration purposes (enables the user to inc/dec value by 0.5�C)

_confirm:
	cpi 		b0,AV_confirm		; check if temp is validated (button 'AV' is pressed)
	breq 		_temp_chosen 		; ret 
_clear_CFlag:
	in			w,SREG
	andi		w,0b11111110
	out			SREG,w
_inc:
	cpi 		b0,increaseVol 		; check if button '+' is pressed
	brne 		_dec		
	ldi			r16,0b00001000
	add			a2,r16				; add '0.5'
	brcc		_display_temp
	cpi			a3,0b00000011		; high temp lim is set to 48�C
	brsh		PC+3
	ldi			r16,0b00000000
	adc			a3,r16
	rjmp 		_display_temp
	ldi			a2,0b11110000		; Set max value to 48 or 48.5 ?   ; 0b11111000
	rjmp 		_display_temp
_dec:
	cpi			b0,decreaseVol		; check if button '-' is pressed
	brne		_display_temp
	cpi			a2,0b00000000		; check low byte limit ==> sould never go below '0b00001000'
	brne		PC+6				; branch to sub '0.5' to low byte
	cpi 		a3,0b00000000		; check high byte low limit
	breq 		_display_temp
	dec			a3					; dec high byte  <=>  subi a3,0b00000001
	ldi			a2,0b11111000		; set low byte to max value
	rjmp		_display_temp
	subi		a2,0b00001000		; dec low byte by '0.5'
	
_display_temp:
	MOV2		b0,b1, a2,a3
	rcall 		LCD_clear
	rcall		LCD_home		
	PRINTF		LCD		
	.db "TempLim=",FFRAC2+FSIGN,b,4,$42,"C ",CR,0
	rjmp 		_get_ir_value
_temp_chosen:
	MOV2		b0,b1, a2,a3
	rcall 		LCD_clear
	rcall		LCD_home
	PRINTF		LCD
	.db "ChosenTemp=",FFRAC2+FSIGN,b,4,$42,"C ",CR,0	; not enough space for 'chosen temp lim' ; consider a \n
	WAIT_MS     2000
	ret