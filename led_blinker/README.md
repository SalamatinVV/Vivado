# LED Blinker

This module blinks three LEDs in sequence. The blink rate is determined by the
`CLK_FREQ_HZ` and `BLINK_HZ` parameters. Each LED is lit one at a time, rotating
through the three outputs.

## Parameters
- `CLK_FREQ_HZ`: clock frequency driving the design
- `BLINK_HZ`: blink frequency for each LED

## Ports
- `clk`: input clock
- `reset_n`: active-low synchronous reset
- `led[2:0]`: LED outputs

