#define __SFR_OFFSET 0x00
#include "avr/io.h"
.global main

main:
    ; Initialize UART
    CLR R24                  ; Clear R24
    STS UCSR0A, R24          ; Set UCSR0A to 0 (disable double speed, multi-processor communication mode, etc.)
    STS UBRR0H, R24          ; Set baud rate high byte to 0
    LDI R24, 103             ; Load 103 into R24 for 9600 baud rate with 16 MHz clock
    STS UBRR0L, R24          ; Set baud rate low byte to 103
    LDI R24, 1<<RXEN0 | 1<<TXEN0 ; Enable receiver and transmitter
    STS UCSR0B, R24          ; Set UCSR0B with RXEN0 and TXEN0
    LDI R24, 1<<UCSZ00 | 1<<UCSZ01 ; Set character size to 8 bits
    STS UCSR0C, R24          ; Set UCSR0C with UCSZ00 and UCSZ01
    SEI                      ; Enable global interrupts

loop:
    RCALL delaytimer2s       ; Delay 2 seconds
    RCALL I2C_init           ; Initialize I2C
    RCALL I2C_listen         ; Wait for I2C communication
    RCALL I2C_read           ; Read data from I2C
    RCALL printval           ; Print the value to UART
    RJMP loop                ; Repeat loop

; Wait until UART data register is empty
LCD_buffer:
    LDS R27, UCSR0A          ; Load UCSR0A into R27
    SBRS R27, UDRE0          ; Skip if UDRE0 (data register empty) is set
    RJMP LCD_buffer          ; Wait until UDRE0 is set
    RET

; Convert most significant digit to ASCII
ASCII_MSD:
    MOV R23, R16             ; Move R16 to R23
    ANDI R16, 0xF0           ; Mask out the lower nibble
    SWAP R16                 ; Swap nibbles
    SUBI R16, -48            ; Convert to ASCII ('0')
    MOV R28, R16             ; Move result to R28
    SUBI R28, 58             ; Check if result is greater than '9'
    BRPL A_F_D1              ; If greater than '9', jump to A_F_D1
l1:
    RET                      ; Return
A_F_D1:
    SUBI R16, -7             ; Convert to ASCII ('A'-'F')
    RJMP l1

; Convert least significant digit to ASCII
ASCII_LSD:
    MOV R16, R23             ; Move R23 to R16
    ANDI R16, 0x0F           ; Mask out the upper nibble
    SUBI R16, -48            ; Convert to ASCII ('0')
    MOV R28, R16             ; Move result to R28
    SUBI R28, 58             ; Check if result is greater than '9'
    BRPL A_F_D0              ; If greater than '9', jump to A_F_D0
l2:
    RET                      ; Return
A_F_D0:
    SUBI R16, -7             ; Convert to ASCII ('A'-'F')
    RJMP l2

; Print the value via UART
printval:
    MOV R16, R27             ; Move I2C data (R27) to R16

    RCALL ASCII_MSD          ; Convert most significant digit to ASCII
    RCALL LCD_buffer         ; Wait for UART buffer to be ready
    STS UDR0, R16            ; Send most significant digit via UART
    
    RCALL ASCII_LSD          ; Convert least significant digit to ASCII
    RCALL LCD_buffer         ; Wait for UART buffer to be ready
    STS UDR0, R16            ; Send least significant digit via UART
    
    RCALL LCD_buffer         ; Wait for UART buffer to be ready
    LDI R16, 0x0A            ; Load newline character (line feed)
    STS UDR0, R16            ; Send newline via UART
    
    RCALL LCD_buffer         ; Wait for UART buffer to be ready
    LDI R16, 0x0D            ; Load carriage return character
    STS UDR0, R16            ; Send carriage return via UART
    RET

; Initialize I2C
I2C_init:
    LDI   R21, 0b10010000    ; Load I2C address (arbitrarily chosen as 0x90) into R21
    STS   TWAR, R21          ; Set TWI (I2C) address register
    LDI   R21, (1<<TWEN)     ; Load TWI enable bit into R21
    STS   TWCR, R21          ; Enable TWI
    LDI   R21, (1<<TWINT)|(1<<TWEN)|(1<<TWEA) ; Load TWI interrupt enable, TWI enable, and acknowledge bit
    STS   TWCR, R21          ; Set TWI control register
    RET

; Wait for I2C communication
I2C_listen:
    LDS   R21, TWCR          ; Load TWI control register into R21
    SBRS  R21, TWINT         ; Skip if TWI interrupt flag is set
    RJMP  I2C_listen         ; Wait until TWI interrupt flag is set
    RET

; Read data from I2C
I2C_read:
    LDI   R21, (1<<TWINT)|(1<<TWEA)|(1<<TWEN) ; Load TWI interrupt enable, acknowledge, and enable bits into R21
    STS   TWCR, R21          ; Set TWI control register
wt:
    LDS   R21, TWCR          ; Load TWI control register into R21
    SBRS  R21, TWINT         ; Skip if TWI interrupt flag is set
    RJMP  wt                 ; Wait until TWI interrupt flag is set
    LDS   R27, TWDR          ; Load received data from TWI data register into R27
    RET

; Delay 2 seconds using Timer 1
delaytimer2s:
    .EQU value, 34285        ; Timer count value for 2 seconds
    LDI R20, hi8(value)      ; Load high byte of count value into R20
    STS TCNT1H, R20          ; Set Timer/Counter1 high byte
    LDI R20, lo8(value)      ; Load low byte of count value into R20
    STS TCNT1L, R20          ; Set Timer/Counter1 low byte
    LDI R20, 0b00000000      ; Set Timer/Counter1 Control Register A to 0
    STS TCCR1A, R20          ; Set TCCR1A
    LDI R20, 0b00000101      ; Set Timer/Counter1 prescaler to 1024 (CS12 and CS10)
    STS TCCR1B, R20          ; Set TCCR1B
l3:
    IN R20, TIFR1            ; Load Timer/Counter1 Interrupt Flag Register into R20
    SBRS R20, TOV1           ; Skip if Timer Overflow Flag is set
    RJMP l3                  ; Wait until Timer Overflow Flag is set
    LDI R20, 1<<TOV1         ; Load Timer Overflow Flag bit into R20
    OUT TIFR1, R20           ; Clear Timer Overflow Flag by writing 1 to it
    LDI R20, 0b00000000      ; Clear prescaler bits
    STS TCCR1B, R20          ; Stop Timer/Counter1 by clearing prescaler bits
    RET
