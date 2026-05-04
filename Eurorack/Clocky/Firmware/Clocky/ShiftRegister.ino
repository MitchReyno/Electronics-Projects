// =============================================================
// Clocky Alt — ShiftRegister.ino
// CD74HC165E 8-bit parallel-in serial-out shift register
// Replaces PCF8574P I2C expander for reading toggle switches
// =============================================================

// Read all 8 switch states from the HC165 in one shot.
// Returns a byte where bit 0 = D0 (first parallel input),
// bit 7 = D7 (last parallel input).
//
// Timing: at 16MHz, digitalRead/Write take ~4µs each.
// Total read time ~70µs for 8 bits — much faster than I2C.

byte readSwitches() {
  byte result = 0;

  // 1. Pulse SH/LD low to latch the parallel inputs
  digitalWrite(SR_SH_LD_PIN, LOW);
  delayMicroseconds(5);  // HC165 needs ~20ns, this is generous
  digitalWrite(SR_SH_LD_PIN, HIGH);
  delayMicroseconds(5);

  // 2. Clock out 8 bits, MSB first (D7 comes out first on QH)
  for (int i = 7; i >= 0; i--) {
    result |= (digitalRead(SR_QH_PIN) << i);
    digitalWrite(SR_CLK_PIN, HIGH);
    delayMicroseconds(5);
    digitalWrite(SR_CLK_PIN, LOW);
    delayMicroseconds(5);
  }

  return result;
}

// Update the toggle_divide[] array from the shift register reading.
// Applies the toggle_index[] remapping (physical → logical, reversed).
// Switch closed (to GND) = 0 = multiply mode
// Switch open (pulled high) = 1 = divide mode
void updateToggles() {
  byte switches = readSwitches();
  for (int i = 0; i < 8; i++) {
    byte value = (switches >> i) & 0x01;
    toggle_divide[toggle_index[i]] = value;
  }
}

// ISR-safe flag setter for the optional interrupt-on-change circuit.
// If you wire a switch change detection circuit to SR_INT_PIN (D2),
// this ISR sets a flag that the main loop checks.
void switchChangeISR() {
  read_toggles = 1;
}
