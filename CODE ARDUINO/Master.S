#define __SFR_OFFSET 0x00
#include "avr/io.h"
.global main

; Main program for setup
main:
    CBI   DDRD, 2       ; Set PD2 (digital pin 2) as input (interrupt button)
    SBI   DDRB, 5       ; Set PB5 (digital pin 13) as output (Relay AC)
    SBI   DDRB, 4       ; Set PB4 (digital pin 12) as output (Relay Humidifier)
    SBI   DDRD, 7       ; Set PD7 (digital pin 7) as output
    SBI   PORTD, 7      ; Set PD7 high (turn on connected device/LED)

    ; Setup interrupt
    LDI R23, (1<<INT0)  ; Load INT0 bit position into R23
    OUT EIMSK, R23      ; Enable INT0 interrupt

    LDI R23, (1<<ISC01) ; Load ISC01 bit position into R23 (trigger on falling edge)
    STS EICRA, R23      ; Set ISC01 bit in EICRA (External Interrupt Control Register A)

    SEI                 ; Enable global interrupts

    ; Setup I2C (TWI)
    LDI   R21, 1<<TWPS0 ; Load prescaler value for TWI into R21
    STS   TWSR, R21     ; Set TWI status register with prescaler
    LDI   R21, 12       ; Load TWI bit rate value into R21
    STS   TWBR, R21     ; Set TWI bit rate register
    LDI   R21, (1<<TWEN); Enable TWI
    STS   TWCR, R21     ; Set TWI control register

    CLR   R18           ; Clear R18 (used later for temperature)
    CLR   R19           ; Clear R19 (used later for humidity)

loop:
    RCALL delaytimer2s  ; Delay 2 seconds

    ; I2C communication to read data
    RCALL I2C_start     ; Start I2C communication
    LDI   R27, 0b10010000; Load I2C address into R27
    RCALL I2C_write     ; Write address
    RCALL select_data   ; Select data to be sent
    RCALL I2C_write     ; Write selected data
    RCALL I2C_stop      ; Stop I2C communication

    ; Read data from DHT11 sensor on PB1
    SBI   DDRB, 1       ; Set PB1 (digital pin 9) as output
    CBI   PORTB, 1      ; Set PB1 low
    RCALL delay20ms     ; Delay 20 ms

    SBI   PORTB, 1      ; Set PB1 high
    CBI   DDRB, 1       ; Set PB1 as input

w1: SBIC  PINB, 1       ; Wait for PB1 to go low
    RJMP  w1
w2: SBIS  PINB, 1       ; Wait for PB1 to go high
    RJMP  w2
w3: SBIC  PINB, 1       ; Wait for PB1 to go low
    RJMP  w3

    RCALL DHT11_reading ; Read DHT11 sensor data
    MOV   R19, R18      ; Move humidity data to R19
    RCALL DHT11_reading ; Read next data (discard)
    RCALL DHT11_reading ; Read next data (temperature)
    
    ; R19 = humidity
    ; R18 = temperature
    CPI R18, 30         ; Compare temperature with 30
    BRSH relayACon      ; If temperature >= 30, jump to relayACon

    CPI R18, 0          ; Compare temperature with 0
    BRSH relayACoff     ; If temperature >= 0, jump to relayACoff

ltest:
    CPI R19, 40         ; Compare humidity with 40
    BRSH relayHUMIoff   ; If humidity >= 40, jump to relayHUMIoff
    
    CPI R19, 20         ; Compare humidity with 20
    BRSH relayHUMIon    ; If humidity >= 20, jump to relayHUMIon
    RJMP loop           ; Repeat loop

; Turn On Air Conditioner
relayACon:
    SBI PORTB, 5        ; Set PB5 high (turn on AC relay)
    RJMP ltest

; Turn Off Air Conditioner
relayACoff:
    CBI PORTB, 5        ; Set PB5 low (turn off AC relay)
    RJMP ltest

; Turn On Humidifier
relayHUMIon:
    SBI PORTB, 4        ; Set PB4 high (turn on Humidifier relay)
    RJMP loop

; Turn Off Humidifier
relayHUMIoff:
    CBI PORTB, 4        ; Set PB4 low (turn off Humidifier relay)
    RJMP loop

I2C_start:
    LDI   R21, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN); Load start condition and enable TWI into R21
    STS   TWCR, R21     ; Set TWI control register
wt1:
    LDS   R21, TWCR     ; Load TWI control register into R21
    SBRS  R21, TWINT    ; Skip if TWI interrupt flag is set
    RJMP  wt1           ; Wait for start condition to complete
    RET

I2C_write:
    STS   TWDR, R27     ; Load data to be sent into TWI data register
    LDI   R21, (1<<TWINT)|(1<<TWEN); Load TWI enable and interrupt flags into R21
    STS   TWCR, R21     ; Set TWI control register
wt2:
    LDS   R21, TWCR     ; Load TWI control register into R21
    SBRS  R21, TWINT    ; Skip if TWI interrupt flag is set
    RJMP  wt2           ; Wait for data transmission to complete
    RET

select_data:
    IN    R21, PORTD    ; Read PORTD into R21
    ANDI  R21, 0x80     ; Mask all but PD7
    CPI   R21, 0x80     ; Compare with 0x80 (PD7 high)
    BREQ  change        ; If PD7 is high, jump to change
    
    MOV   R27, R18      ; Move temperature data to R27
    RET
    
change:
    MOV R27, R19        ; Move humidity data to R27
    RET

I2C_stop:
    LDI   R21, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN); Load stop condition and enable TWI into R21
    STS   TWCR, R21     ; Set TWI control register
    RET

DHT11_reading:
    LDI   R17, 8        ; Load 8 bits counter into R17
    CLR   R18           ; Clear R18 to store the result
w4:
    SBIS  PINB, 1       ; Skip if PB1 is high
    RJMP  w4            ; Wait for PB1 to go low
    RCALL delaytimer0   ; Call delay
    SBIS  PINB, 1       ; Skip if PB1 is high
    RJMP  skp
    SEC                 ; Set carry flag
    ROL   R18           ; Rotate left through carry
    RJMP  w5
skp:
    LSL   R18           ; Shift left logical
w5:
    SBIC  PINB, 1       ; Skip if PB1 is low
    RJMP  w5            ; Wait for PB1 to go low
    DEC   R17           ; Decrement counter
    BRNE  w4            ; Repeat if not zero
    RET

; Delay 20 ms
delay20ms:
    LDI   R21, 255      ; Load counter value into R21
l1_20ms:
    LDI   R22, 210      ; Load inner loop counter into R22
l2_20ms:
    LDI   R23, 2        ; Load innermost loop counter into R23
l3_20ms:
    DEC   R23           ; Decrement innermost counter
    BRNE  l3_20ms       ; Repeat until zero
    DEC   R22           ; Decrement middle counter
    BRNE  l2_20ms       ; Repeat until zero
    DEC   R21           ; Decrement outer counter
    BRNE  l1_20ms       ; Repeat until zero
    RET

; Delay 2 seconds with Timer 1
delaytimer2s:
    .EQU value, 34285   ; Timer count value for 2 seconds
    LDI R20, hi8(value) ; Load high byte of count value
    STS TCNT1H, R20     ; Set Timer 1 counter high byte
    LDI R20, lo8(value) ; Load low byte of count value
    STS TCNT1L, R20     ; Set Timer 1 counter low byte
   


delaytimer0:
    CLR   R20              ; Clear R20, setting it to 0
    OUT   TCNT0, R20       ; Set Timer/Counter0 (TCNT0) to 0, clearing the counter
    LDI   R20, 100         ; Load 100 into R20
    OUT   OCR0A, R20       ; Set Output Compare Register A (OCR0A) to 100, defining the compare match value
    LDI   R20, 0b00001010  ; Load control bits into R20: prescaler = 8 (CS01 = 1) and CTC mode (WGM01 = 1)
    OUT   TCCR0B, R20      ; Set Timer/Counter Control Register B (TCCR0B) with the prescaler and mode

cTimer0:
    IN    R20, TIFR0       ; Read Timer/Counter0 Interrupt Flag Register (TIFR0) into R20
    SBRS  R20, OCF0A       ; Skip the next instruction if the Output Compare Flag A (OCF0A) is set
    RJMP  cTimer0          ; Repeat until OCF0A is set (waiting for the compare match)

    CLR   R20              ; Clear R20
    OUT   TCCR0B, R20      ; Clear TCCR0B, stopping the timer

    LDI   R20, (1<<OCF0A)  ; Load the OCF0A bit into R20
    OUT   TIFR0, R20       ; Clear the OCF0A flag by writing 1 to it
    RET                    ; Return from subroutine
