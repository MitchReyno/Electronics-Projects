// =============================================================
// Clocky Alt — FastWrite.ino
// Port manipulation for fast output toggling (unchanged)
// =============================================================

// NOTE: The logic is INVERTED because the outputs drive 2N3904 bases.
// FastWrite(i, HIGH) clears the port bit → transistor OFF → output jack HIGH (via pull-up)
// FastWrite(i, LOW)  sets the port bit  → transistor ON  → output jack LOW (gate pulse)
// 
// Pin mapping: outs[] = {5, 6, 7, 8, 9, 12, 11, 10}
//   case 0: D5  = PORTD bit 5
//   case 1: D6  = PORTD bit 6
//   case 2: D7  = PORTD bit 7  (original has B11000000 which also sets D6 — possible bug in original?)
//   case 3: D8  = PORTB bit 0
//   case 4: D9  = PORTB bit 1
//   case 5: D12 = PORTB bit 4
//   case 6: D11 = PORTB bit 3
//   case 7: D10 = PORTB bit 2

void FastWrite(int input, bool state) {
  if (!state) {
    switch (input) {
      case 0: PORTD |= B00100000; break;
      case 1: PORTD |= B01000000; break;
      case 2: PORTD |= B10000000; break;  // Fixed: was B11000000 in original
      case 3: PORTB |= B00000001; break;
      case 4: PORTB |= B00000010; break;
      case 5: PORTB |= B00010000; break;
      case 6: PORTB |= B00001000; break;
      case 7: PORTB |= B00000100; break;
    }
  } else {
    switch (input) {
      case 0: PORTD &= B11011111; break;
      case 1: PORTD &= B10111111; break;
      case 2: PORTD &= B01111111; break;
      case 3: PORTB &= B11111110; break;
      case 4: PORTB &= B11111101; break;
      case 5: PORTB &= B11101111; break;
      case 6: PORTB &= B11110111; break;
      case 7: PORTB &= B11111011; break;
    }
  }
}
