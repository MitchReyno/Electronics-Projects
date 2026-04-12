// =============================================================
// Clocky Alt — interrupts.ino
// Trigger and reset interrupt handlers
// Adapted from original — replaces NeoPixel calls with setLed()
// =============================================================

void trigger_int() {
  trigger_time = micros();

  // First clock received — exit rainbow idle mode
  if (waiting_for_clock) {
    waiting_for_clock = 0;
  }

  // Clock rising edge (input is inverted by 2N3904, so digitalRead LOW = external HIGH)
  if (!digitalRead(TRIG_PIN)) {

    for (int i = 0; i < 8; i++) {
      // Divider mode
      if (toggle_divide[i]) {
        if (clock_counter % ratios[i] == 0) {
          FastWrite(i, HIGH);
          outs_micros[i] = 0;
          time_turned_on[i] = micros();
          out_state[i] = 1;
          // LED: step i+2 shows divide color
          led_state[i + 2] = COLOR_DIVIDE;
        }
      }

      // Multiplier mode
      if (!toggle_divide[i]) {
        FastWrite(i, HIGH);
        outs_micros[i] = 0;
        out_state[i] = 1;
        // LED: step i+2 shows multiply color
        led_state[i + 2] = COLOR_MULT;
      }
    }

    // TRG indicator LED on
    led_state[0] = COLOR_TRIG;

    clock_counter++;
    if (clock_counter == 64) {
      clock_counter = 0;
    }

    trigger_on_time = trigger_time;
    period = trigger_on_time - previous_trigger_on_time;
    previous_trigger_on_time = trigger_on_time;
  }

  // Clock falling edge
  if (digitalRead(TRIG_PIN)) {
    trigger_off_time = trigger_time;
    // TRG indicator LED off
    led_state[0] = COLOR_OFF;
    clock_length = trigger_off_time - trigger_on_time;
  }
}
