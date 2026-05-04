// =============================================================
// Clocky Alt — FastWrite.ino
// Port manipulation for fast output toggling
// =============================================================

// NOTE: The logic is INVERTED because the outputs drive 2N3904 bases.
// FastWrite(i, HIGH) clears the port bit → transistor OFF → output jack HIGH (via pull-up) = gate ON
// FastWrite(i, LOW)  sets the port bit  → transistor ON  → output jack LOW                = gate OFF
//
// Pin mapping: outs[] = {A0, A1, A2, A3, A4, A5, 12, 13}
//   cases 0–5: A0–A5 = PORTC bits 0–5
//   case 6:    D12   = PORTB bit 4
//   case 7:    D13   = PORTB bit 5

void FastWrite(int input, bool state) {
  if (!state) {
    // LOW: set bit → NPN on → output jack LOW (gate OFF)
    switch (input) {
      case 0: PORTC |= (1 << 0); break;  // A0
      case 1: PORTC |= (1 << 1); break;  // A1
      case 2: PORTC |= (1 << 2); break;  // A2
      case 3: PORTC |= (1 << 3); break;  // A3
      case 4: PORTC |= (1 << 4); break;  // A4
      case 5: PORTC |= (1 << 5); break;  // A5
      case 6: PORTB |= (1 << 4); break;  // D12
      case 7: PORTB |= (1 << 5); break;  // D13
    }
  } else {
    // HIGH: clear bit → NPN off → output jack HIGH via pull-up (gate ON)
    switch (input) {
      case 0: PORTC &= ~(1 << 0); break;  // A0
      case 1: PORTC &= ~(1 << 1); break;  // A1
      case 2: PORTC &= ~(1 << 2); break;  // A2
      case 3: PORTC &= ~(1 << 3); break;  // A3
      case 4: PORTC &= ~(1 << 4); break;  // A4
      case 5: PORTC &= ~(1 << 5); break;  // A5
      case 6: PORTB &= ~(1 << 4); break;  // D12
      case 7: PORTB &= ~(1 << 5); break;  // D13
    }
  }
}
