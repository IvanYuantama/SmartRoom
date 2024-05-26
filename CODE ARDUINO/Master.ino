void setup() {
  
}

void loop() {
  
}

//Interrupt in Pin INT0 or PD2
ISR(INT0_vect){
    PORTD ^= (1 << 7);
}
