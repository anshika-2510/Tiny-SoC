# UART

A fully modular UART peripheral for the Tiny SoC — separate TX, RX, and baud generator blocks, tied together through an APB wrapper for CPU access. 


 <img width="660" height="170" alt="UARTdataformat" src="https://github.com/user-attachments/assets/79b6ce6c-78e3-4581-8ed3-2fd54e41f6a4" />
## Why this UART

Most student UART implementations sample once near the middle of a bit and call it done. This one runs the receiver at 16x oversampling with proper majority-style midpoint detection, and the testbench actually tries to break it — glitch pulses on the line, back-to-back frames with no gap, mid-frame resets — rather than just sending one clean byte and checking the output.

## Features

- 8-bit data, 1 start bit, 1 stop bit
- Configurable baud rate via the baud generator's divider
- Independent TX and RX datapaths
- 16x oversampled RX with midpoint sampling
- `busy` / `ready` handshake flags on both TX and RX
- Synchronous reset throughout

## Module notes

**uart_tx.v** — shifts out start bit, 8 data bits, stop bit at the configured baud rate. `busy` stays high for the duration of the frame.

**uart_rx.v** — the receiver is the more involved piece. It oversamples each bit 16x and takes its decision at the bit's midpoint rather than trusting a single edge-triggered sample, which is what makes it tolerant to line noise. Went through a full review pass on this one to fix priority-chain bugs and incorrect sample-timing targets before it was solid.

**baud_generator.v** — divides `pclk` down to the target baud tick, shared by TX and RX.

**uart_wrapper.v** — memory-mapped APB access to TX/RX data and status, so the CPU side just does simple register reads/writes.

## Verification
In progress

