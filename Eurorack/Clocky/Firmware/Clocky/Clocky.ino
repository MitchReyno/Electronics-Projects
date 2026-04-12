// =============================================================
// Clocky Alt — Main Sketch
// Clock divider/multiplier module for Eurorack
//
// Hardware changes from original SoundForce Clocky:
//   - CD74HC165E replaces PCF8574P for switch reading
//   - CD4017BE + common-anode RGB LEDs replaces PL9823 chain
//   - No I2C bus needed (Wire library removed)
//   - No NeoPixel library needed
//
// Original design: SoundForce (soundforce.nl)
// Adaptation: shift register + mux LED version
// =============================================================

// Output ratios for channels A–H (same as original)
unsigned long ratios[8] = {
  1,   // A
  2,   // B
  4,   // C
  8,   // D
  16,  // E
  3,   // F
  5,   // G
  7    // H
};

#include <elapsedMillis.h>
#include "variables.h"

elapsedMillis time_to_switch;
elapsedMicros outs_micros[8];

void setup() {
  Serial.begin(9600);
  delay(500);

  // --- Output pins ---
  for (int i = 0; i < 8; i++) {
    pinMode(outs[i], OUTPUT);
  }

  // --- Input pins ---
  pinMode(TRIG_PIN, INPUT);
  pinMode(RESET_PIN, INPUT);

  // --- Shift register pins ---
  pinMode(SR_SH_LD_PIN, OUTPUT);
  pinMode(SR_CLK_PIN, OUTPUT);
  pinMode(SR_QH_PIN, INPUT);
  digitalWrite(SR_SH_LD_PIN, HIGH);  // Idle high (active low)
  digitalWrite(SR_CLK_PIN, LOW);     // Idle low

  // --- Switch reading: polled mode ---
  // D2 is used for LED_R cathode, so no interrupt-based switch detection.
  // Polling every 50ms in the main loop is perfectly adequate.

  // --- LED multiplexing setup (Timer2 + CD4017) ---
  setupLedMux();

  // --- Trigger interrupt (INT1 on D3) ---
  attachInterrupt(INT1, trigger_int, CHANGE);

  // --- Initial switch read ---
  updateToggles();

  // --- Show rainbow while waiting for first clock ---
  showRainbow();
}

void loop() {

  // --- Idle rainbow mode (waiting for first external clock) ---
  while (waiting_for_clock) {
    // The LED mux timer ISR handles display automatically.
    // We just cycle through rainbow colors slowly.
    // Unlike the original's NeoPixel rainbow animation, our on/off RGB
    // can't do smooth color wheel transitions. Instead we do a simple
    // rotating pattern: shift the rainbow_colors array every ~200ms.
    
    static unsigned long last_rainbow_shift = 0;
    if (millis() - last_rainbow_shift > 200) {
      last_rainbow_shift = millis();
      
      // Manual member copy — volatile structs can't use implicit copy
      LedColor first = {led_state[0].r, led_state[0].g, led_state[0].b};
      for (byte i = 0; i < 9; i++) {
        led_state[i].r = led_state[i + 1].r;
        led_state[i].g = led_state[i + 1].g;
        led_state[i].b = led_state[i + 1].b;
      }
      led_state[9].r = first.r;
      led_state[9].g = first.g;
      led_state[9].b = first.b;
    }

    if (!waiting_for_clock) break;
  }

  // --- Reset handling ---
  reset_actual = digitalRead(RESET_PIN);

  if (reset_actual && !reset_previous) {
    // Reset released
    setLed(1, COLOR_OFF);
  }

  if (!reset_actual && reset_previous) {
    // Reset triggered
    if (!do_we_know_the_period_yet) {
      if (reset_counter == 0) {
        reset_on_time = micros();
      }
      if (reset_counter == 1) {
        period = micros() - reset_on_time;
        do_we_know_the_period_yet = 1;
      }
    }
    clock_counter = 0;
    reset_counter++;
    setLed(1, COLOR_RESET);
  }

  reset_previous = reset_actual;

  // --- Output timing logic (unchanged from original) ---
  for (int i = 0; i < 8; i++) {

    // DIVIDER: turn off output after half-period
    if (toggle_divide[i]) {
      if (out_state[i]) {
        if (micros() - time_turned_on[i] > period / (2 * ratios[i])) {
          FastWrite(i, LOW);
          out_state[i] = 0;
          setLed(i + 2, COLOR_OFF);
        }
      }
    }

    // MULTIPLIER: generate sub-clocks between trigger pulses
    if (!toggle_divide[i]) {
      // Turn on at each subdivision
      if (!out_state[i]) {
        if (outs_micros[i] > period / ratios[i]) {
          outs_micros[i] = 0;
          FastWrite(i, HIGH);
          out_state[i] = 1;
          setLed(i + 2, COLOR_MULT);
        }
      }

      // Turn off at 50% duty cycle
      if (out_state[i]) {
        if (outs_micros[i] > period / (2 * ratios[i])) {
          FastWrite(i, LOW);
          out_state[i] = 0;
          setLed(i + 2, COLOR_OFF);
        }
      }
    }
  }

  // --- Switch reading ---
  // --- Switch reading (polled every 50ms) ---
  static unsigned long last_switch_poll = 0;
  if (millis() - last_switch_poll > 50) {
    last_switch_poll = millis();
    updateToggles();
  }
}
