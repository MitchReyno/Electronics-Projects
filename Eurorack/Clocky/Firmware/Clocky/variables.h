// =============================================================
// Clocky Alt — variables.h
// Shift register (HC165) + multiplexed RGB LED (CD4017) version
// =============================================================

#ifndef VARIABLES_H
#define VARIABLES_H

// --- Pin definitions ---
//
// Pin grouping by port:
//   Port D (D0–D7): serial, inputs, LED cathodes, 4017 CLK
//   Port B (D8–D13): 4017 RST, shift register, gate outputs G/H
//   Port C (A0–A5): gate outputs A–F

// Trigger & Reset inputs (active-low via 2N3904 inverters)
#define TRIG_PIN        2   // D2 — external trigger input (INT0)
#define RESET_PIN       3   // D3 — external reset input

// Gate/trigger outputs (active-low open-collector)
// outs[0]=OUT_A .. outs[7]=OUT_H
// A0–A5 = outputs A–F (PORTC bits 0–5), D12/D13 = outputs G/H (PORTB bits 4–5)
const byte outs[8] = {A0, A1, A2, A3, A4, A5, 12, 13};

// CD4017BE decade counter (LED anode multiplexing via NPN emitter-followers)
// Each 4017 Qn output drives a 2N3904 base; collector to +5V,
// emitter to LED common anode. Active-high: Q HIGH = LED powered.
#define LED_MUX_CLK_PIN 7   // D7 — Clock input to CD4017
#define LED_MUX_RST_PIN 8   // D8 — Reset input to CD4017

// RGB cathode sink transistors (2N3904 NPN, active-high base drive)
// All three are on PORTD (bits 4–6) — grouped for fast simultaneous blanking.
// NOTE: A6 and A7 are ANALOG-ONLY on ATmega328P — cannot be used as digital outputs.
#define LED_R_PIN       4   // D4 — Red cathode sink   (PD4)
#define LED_G_PIN       5   // D5 — Green cathode sink (PD5)
#define LED_B_PIN       6   // D6 — Blue cathode sink  (PD6)

// CD74HC165E shift register (switch reading)
#define SR_SH_LD_PIN    9   // D9  — SH/LD: pulse low to latch parallel inputs
#define SR_CLK_PIN      10  // D10 — CLK: clock to shift data out
#define SR_QH_PIN       11  // D11 — QH: serial data out
// No interrupt pin for switch change — all interrupt-capable pins are in use; poll instead.

// --- LED color definitions ---
// Each LED has an RGB triplet stored as {R, G, B} where 1=on, 0=off
// For the multiplexed scheme, each "color" is just which cathodes to sink.
// Index 0 = TRG indicator, 1 = RST indicator, 2–9 = steps A–H
// These are the DEFAULT idle colors (the rainbow pattern equivalent).

// Simple on/off per channel (no PWM color mixing for now)
struct LedColor {
  uint8_t r;  // 0 or 1
  uint8_t g;  // 0 or 1
  uint8_t b;  // 0 or 1
};

// Current display state for all 10 LEDs
// Updated by main loop / ISR, read by the mux timer ISR
volatile LedColor led_state[10] = {
  {0, 0, 0},  // LED0: TRG indicator (off at startup)
  {0, 0, 0},  // LED1: RST indicator
  {0, 0, 0},  // LED2: Step A
  {0, 0, 0},  // LED3: Step B
  {0, 0, 0},  // LED4: Step C
  {0, 0, 0},  // LED5: Step D
  {0, 0, 0},  // LED6: Step E
  {0, 0, 0},  // LED7: Step F
  {0, 0, 0},  // LED8: Step G
  {0, 0, 0},  // LED9: Step H
};

// Predefined colors (on/off only — no PWM)
const LedColor COLOR_OFF     = {0, 0, 0};
const LedColor COLOR_RED     = {1, 0, 0};
const LedColor COLOR_GREEN   = {0, 1, 0};
const LedColor COLOR_BLUE    = {0, 0, 1};
const LedColor COLOR_YELLOW  = {1, 1, 0};
const LedColor COLOR_CYAN    = {0, 1, 1};
const LedColor COLOR_MAGENTA = {1, 0, 1};
const LedColor COLOR_WHITE   = {1, 1, 1};

// Color used for divider mode output active
const LedColor COLOR_DIVIDE  = COLOR_BLUE;
// Color used for multiplier mode output active
const LedColor COLOR_MULT    = COLOR_GREEN;
// Color for trigger flash
const LedColor COLOR_TRIG    = COLOR_MAGENTA;
// Color for reset flash
const LedColor COLOR_RESET   = COLOR_RED;

// --- Rainbow idle colors (one per LED, static assignment) ---
// Approximation of the original PL9823 rainbow using on/off RGB
const LedColor rainbow_colors[10] = {
  {1, 0, 0},  // LED0 (TRG): red
  {1, 0, 0},  // LED1 (RST): red
  {1, 1, 0},  // LED2 (A): yellow
  {1, 1, 0},  // LED3 (B): yellow
  {0, 1, 0},  // LED4 (C): green
  {0, 1, 1},  // LED5 (D): cyan
  {0, 0, 1},  // LED6 (E): blue
  {0, 0, 1},  // LED7 (F): blue
  {1, 0, 1},  // LED8 (G): magenta
  {1, 1, 1},  // LED9 (H): white
};

// --- Clock / sequencer state ---
bool out_state[8] = {0, 0, 0, 0, 0, 0, 0, 0};

int clock_counter = 0;
byte reset_counter = 0;
unsigned long clock_length = 10000;

bool do_we_know_the_period_yet = 0;

unsigned long time_turned_on[8]    = {0, 0, 0, 0, 0, 0, 0, 0};
unsigned long trigger_time;
unsigned long trigger_on_time;
unsigned long previous_trigger_on_time;
unsigned long trigger_off_time;
unsigned long reset_on_time;
unsigned long reset_off_time;
unsigned long last_trigger_on_time = 0;

volatile bool read_toggles = 0;

bool reset_actual   = 0;
bool reset_previous = 0;
volatile bool show_leds = 0;

bool toggle_divide[8] = {1, 1, 1, 1, 1, 1, 1, 1};
// Mapping: physical switch index → logical output index (reversed)
byte toggle_index[8]  = {7, 6, 5, 4, 3, 2, 1, 0};

unsigned long period = 0;

int before = 0;
int after  = 0;

bool waiting_for_clock    = 1;
unsigned long time_to_rainbow = 0;

// LED multiplexing state
volatile byte current_led = 0;  // 0–9, which LED the 4017 is currently driving

#endif
