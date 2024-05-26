#define __SFR_OFFSET 0x00
#include "avr/io.h"
.global main

main:
    CLR R24
    STS UCSR0A, R24
    STS UBRR0H, R24
    LDI R24, 103
    STS UBRR0L, R24
    LDI R24, 1<<RXEN0 | 1<<TXEN0 
    STS UCSR0B, R24
    LDI R24, 1<<UCSZ00 | 1<<UCSZ01
    STS UCSR0C, R24
    SEI

loop:
    RCALL delaytimer2s
    RCALL I2C_init
    RCALL I2C_listen
    RCALL I2C_read
    RCALL printval
    RJMP  loop

LCD_buffer:
    LDS R27, UCSR0A
    SBRS R27, UDRE0
    RJMP LCD_buffer
    RET

ASCII_MSD:
    MOV R23, R16
    ANDI R16, 0xF0
    SWAP R16
    SUBI R16, -48
    MOV R28, R16
    SUBI R28, 58
    BRPL A_F_D1
    l1:
        RET 
A_F_D1:
    SUBI R16, -7
    RJMP l1

ASCII_LSD:
    MOV R16, R23
    ANDI R16, 0x0F
    SUBI R16, -48
    MOV R28, R16
    SUBI R28, 58
    BRPL A_F_D0
    l2:
        RET
A_F_D0:
    SUBI R16, -7
    RJMP l2

printval:
    MOV R16, R27

    RCALL ASCII_MSD
    RCALL LCD_buffer
    STS UDR0, R16
    
    RCALL ASCII_LSD
    RCALL LCD_buffer
    STS UDR0, R16
    
    RCALL LCD_buffer
    LDI R16, 0x0A
    STS UDR0, R16
    
    RCALL LCD_buffer
    LDI R16, 0x0D
    STS UDR0, R16
    RET

I2C_init:
    LDI   R21, 0b10010000
    STS   TWAR, R21
    LDI   R21, (1<<TWEN)
    STS   TWCR, R21
    LDI   R21, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)
    STS   TWCR, R21
    RET

I2C_listen:
    LDS   R21, TWCR
    SBRS  R21, TWINT
    RJMP  I2C_listen
    RET

I2C_read:
    LDI   R21, (1<<TWINT)|(1<<TWEA)|(1<<TWEN)
    STS   TWCR, R21
wt: LDS   R21, TWCR
    SBRS  R21, TWINT
    RJMP  wt
    LDS   R27, TWDR
    RET

delaytimer2s:
    .EQU value, 34285 
    LDI R20, hi8(value)
    STS TCNT1H, R20
    LDI R20, lo8(value)
    STS TCNT1L, R20 
    LDI R20, 0b00000000
    STS TCCR1A, R20
    LDI R20, 0b00000101
    STS TCCR1B, R20
    l3:
    IN R20, TIFR1 
    SBRS R20, TOV1 
    RJMP l3
    LDI R20, 1<<TOV1 
    OUT TIFR1, R20 
    LDI R20, 0b00000000
    STS TCCR1B, R20
    RET