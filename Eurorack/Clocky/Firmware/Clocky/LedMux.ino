// =============================================================
// Clocky Alt — LedMux.ino
// CD4017BE decade counter + common-anode RGB LED multiplexing
// Replaces PL9823 addressable LEDs
// =============================================================

// The CD4017 cycles through Q0–Q9. Each output drives an NPN
// transistor (2N3904) in emitter-follower configuration:
//   +5V at collector, emitter to LED common anode.
// When the 4017 output goes HIGH, the NPN conducts and the
// emitter presents ~4.3V (Vbase - 0.7V) to the LED anode.
// With a 3V LED Vf, ~1.3V remains across the series resistor.
//
// Only one Q output is HIGH at a time → only one LED is powered.
// The R/G/B cathode sink NPNs (shared bus) select which color
// channels conduct for the currently active LED.
//
// At 10 LEDs and a 1kHz mux rate per LED, the timer fires at
// 10kHz (100µs period). Each LED gets 10% duty cycle.
// Series resistors sized for ~20–30mA instantaneous current.
//
// At 10 LEDs and a 1kHz mux rate per LED, the timer fires at 10kHz
// (100µs period). Each LED gets 100µs ON time per 1ms cycle = 10% duty.
// Perceived brightness is ~10% of DC, so we can use lower series
// resistors to compensate (see schematic notes).

// --- Timer2 setup for LED multiplexing ---
// Timer2 is 8-bit, we use CTC mode.
// At 16MHz with prescaler 64: tick = 4µs
// For 10kHz (100µs period): OCR2A = 100/4 - 1 = 24
// Actual frequency: 16MHz / 64 / 25 = 10kHz ✓

void setupLedMux() {
  // Configure LED mux pins as outputs
  pinMode(LED_MUX_CLK_PIN, OUTPUT);
  pinMode(LED_MUX_RST_PIN, OUTPUT);
  pinMode(LED_R_PIN, OUTPUT);
  pinMode(LED_G_PIN, OUTPUT);
  pinMode(LED_B_PIN, OUTPUT);

  // Reset CD4017 to Q0
  digitalWrite(LED_MUX_RST_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(LED_MUX_RST_PIN, LOW);
  current_led = 0;

  // All cathodes off initially
  digitalWrite(LED_R_PIN, LOW);
  digitalWrite(LED_G_PIN, LOW);
  digitalWrite(LED_B_PIN, LOW);

  // Configure Timer2 for CTC mode at 10kHz
  noInterrupts();
  TCCR2A = 0;
  TCCR2B = 0;
  TCNT2  = 0;

  // CTC mode (WGM21)
  TCCR2A = (1 << WGM21);
  // Prescaler 64 (CS22 + CS20)
  TCCR2B = (1 << CS22) | (1 << CS20);
  // Compare match value for 10kHz
  OCR2A = 24;
  // Enable Timer2 compare match A interrupt
  TIMSK2 = (1 << OCIE2A);

  interrupts();
}

// Timer2 Compare Match A interrupt — LED multiplexing
// This fires every 100µs (10kHz).
// Sequence: turn off cathodes → advance 4017 → set cathodes for new LED
ISR(TIMER2_COMPA_vect) {
  // 1. Turn OFF all cathode sinks (blanking — prevents ghosting)
  //    LED_R = D4 = PD4, LED_G = D5 = PD5, LED_B = D6 = PD6 (all PORTD)
  //    Using digitalWrite for clarity — ISR is only ~15µs total.

  digitalWrite(LED_R_PIN, LOW);
  digitalWrite(LED_G_PIN, LOW);
  digitalWrite(LED_B_PIN, LOW);

  // 2. Advance CD4017 to next output (rising edge on CLK)
  digitalWrite(LED_MUX_CLK_PIN, HIGH);
  // No delay needed — 4017 propagation is ~250ns at 5V
  digitalWrite(LED_MUX_CLK_PIN, LOW);

  // 3. Advance our tracking counter
  current_led++;
  if (current_led >= 10) {
    current_led = 0;
    // Reset 4017 to Q0 to stay in sync
    digitalWrite(LED_MUX_RST_PIN, HIGH);
    digitalWrite(LED_MUX_RST_PIN, LOW);
  }

  // 4. Set cathode sinks for the current LED's color.
  //    LED_R = D4 = PD4, LED_G = D5 = PD5, LED_B = D6 = PD6 (all PORTD).
  if (led_state[current_led].r) digitalWrite(LED_R_PIN, HIGH);
  if (led_state[current_led].g) digitalWrite(LED_G_PIN, HIGH);
  if (led_state[current_led].b) digitalWrite(LED_B_PIN, HIGH);
}

// --- Helper: set an LED's color (safe to call from main loop or ISR) ---
void setLed(byte index, LedColor color) {
  if (index >= 10) return;
  noInterrupts();
  led_state[index] = color;
  interrupts();
}

void setLedOff(byte index) {
  setLed(index, COLOR_OFF);
}

// Set all LEDs to the rainbow idle pattern
void showRainbow() {
  for (byte i = 0; i < 10; i++) {
    setLed(i, rainbow_colors[i]);
  }
}

// Turn all LEDs off
void allLedsOff() {
  for (byte i = 0; i < 10; i++) {
    setLedOff(i);
  }
}
