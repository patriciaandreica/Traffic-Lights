; main.asm
;
; Created: 12/5/2021 5:02:23 PM
; Purpose: Traffic Light System with Pedestrian
; ---------------------------------------------------------

.org 0x0000 ; reset
     rjmp main
.org 0x20 ; external interrupt 0
     rjmp external_isr

.org INT_VECTORS_SIZE ; end of vector table

;-------------------;
; End Setup ;
;-------------------;

main:
     ldi r16, high(RAMEND)
     out SPH, r16
     ldi r16, low(RAMEND)
     out SPL, r16 ; Stack initialized

     ldi r22, 0b00111111 ; PB0-PB5 set to output (6 LEDS)
     out DDRB, r22

     ldi r22, 0b00001000 ; PIND.2 = Input (Button)
     out DDRD, r22
     sbi PORTD, PD2 ; pull-up on PIND.2

     ldi r20, (1<<INT0) ; enable interrupt 0
     out EIMSK, r20

     ldi r20, (1<<ISC01) ; falling edge triggered
     sts EICRA, r20

     sei ; enable interrupts

;-------------------;
; PB0 - Red 1 ;
; PB1 - Yellow 1 ;
; PB2 - Green 1 ;
;-------------------;
; PB3 - Red 2 ;
; PB4 - Yellow 2 ;
; PB5 - Green 2 ;
;-------------------;

;---------------------;
; Traffic Lights Loop ;
;---------------------;

main_cycle:
     sbi PORTB, PB5 ; Green 2 ON
     sbi PORTB, PB0 ; Red 1 ON
     call Delay10 ; Delay 10s
     cbi PORTB, PB5 ; Green 2 OFF
     sbi PORTB, PB4 ; Yellow 2 ON
     call Delay3 ; Delay 3s
     cbi PORTB, PB0 ; Red 1 OFF
     cbi PORTB, PB4 ; Yellow 2 OFF
     sbi PORTB, PB3 ; Red 2 ON
     sbi PORTB, PB2 ; Green 1 ON
     call Delay10 ; Delay 10s
     cbi PORTB, PB2 ; Green 1 OFF
     sbi PORTB, PB1 ; Yellow 1 ON
     call Delay3 ; Delay 3s
     cbi PORTB, PB3 ; Red 2 OFF
     cbi PORTB, PB1 ; Yellow 1 OFF
     rjmp main_cycle ; repeat main loop

;--------------------;
; End Main ;
;--------------------;

;---------------------------------------------------------------------------------

;-----------;
; Functions ;
;-----------;

external_isr:
     ldi r16,1 ; delay for 1s instead of 3s for next delay
     reti

;---------------------------------------------------------------------------------

timer1_delay3:
     ldi r20,high(49911) ; load TCNT1H:TCNT1L with initial count
     sts TCNT1H,r20
     ldi r20,low(49911)
     sts TCNT1L,r20 ; set counter to 1s at clk/1024

     clr r20
     sts TCCR1A,r20 ; set to normal mode

     ldi r20,(1<<CS12)|(1<<CS10) ; clock select
     sts TCCR1B,r20

tov1_wait: ;Monitor TOV1 flag in TIFR1
     sbis TIFR1,TOV1 ; watch for overflow flag - skip next when set
     rjmp tov1_wait
     clr r20
     sts TCCR1B,r20 ; stop timer
     sbi TIFR1,TOV1 ; clear the flag

     ret

;---------------------------------------------------------------------------------

Delay10:
     ldi r16,10     ; Delay control
Loop10s: 
     call timer1_delay3     ; 10 * 1s = 10s delay
     dec r16 
     brne Loop10s 
     ret 

;---------------------------------------------------------------------------------

Delay5:
     ldi r16,5     ; Delay control
Loop5s: 
     call timer1_delay3     ; 5 * 1s = 5s delay
     dec r16 
     brne Loop5s 
     ret 

;---------------------------------------------------------------------------------

Delay3:
     ldi r16,3     ; Delay control
Loop3s: 
     call timer1_delay3     ; 3 * 1s = 3s delay
     dec r16 
     brne Loop3s 
     ret 

;---------------------------------------------------------------------------------

;----------------------;
; Functions End ;
;----------------------;
