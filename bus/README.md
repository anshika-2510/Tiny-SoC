
# APB Master

Simple APB (AMBA Peripheral Bus) master, written for my tiny SoC's bus/peripheral interconnect. Sits between the CPU/controller side and the APB slaves (decoder + peripherals), driving the standard SETUP/ACCESS handshake.

## What it does

- Implements the 3-state APB FSM: IDLE → SETUP → ACCESS
- Drives `paddr`, `pwdata`, `pwrite`, `pselx`, `penb` per the APB protocol
- Waits on `pready` from the slave before completing a transfer
- Supports both read and write, controlled by the `wr` input
- Reports `slverr` back up as an `error` flag
- `busy` / `done` handshake signals for whatever's driving `start`

## Files

| File | What's in it |
|---|---|
| `apb_master.v` | APB master FSM |
| `apb_decoder.v` | Address decoder for selecting the right peripheral |

(part of the `bus/` folder in the SoC)

## Interface

| Signal | Dir | Description |
|---|---|---|
| `pclk`, `prst` | in | clock and sync reset |
| `start` | in | kick off a transaction |
| `wr` | in | 1 = write, 0 = read |
| `addr` | in | target address |
| `tx_data` | in | data to write |
| `rx_data` | out | data read back |
| `paddr`, `pwdata`, `pwrite`, `pselx`, `penb` | out | standard APB signals to slave |
| `pready`, `prdata`, `slverr` | in | standard APB signals from slave |
| `busy` | out | high while transaction in progress |
| `done` | out | pulses high for 1 cycle when transaction completes |
| `error` | out | set if slave returned `slverr` |

## How it works

- **IDLE**: waits for `start`. On `start`, moves to SETUP and asserts `busy`.
- **SETUP**: drives `pselx`, latches `paddr`/`pwdata`/`pwrite` for the transfer, `penb` stays low.
- **ACCESS**: asserts `penb`, waits for `pready`. Once the slave responds, latches `rx_data` (on reads), sets `error` if `slverr` was asserted, pulses `done`, and drops back to IDLE.

No wait states are inserted by the master itself — it just holds ACCESS until `pready` goes high, so it naturally supports slaves that need extra cycles.
# APB Decoder
 
Address decoder for the SoC's APB bus. Takes the address from `apb_master` and generates the individual peripheral select lines for I2C, UART, and SPI.
 
## What it does
 
- Combinational address decode based on `paddr`
- Drives one-hot peripheral selects: `pselx_i2c`, `pselx_uart`, `pselx_spi`
## Files
 
`apb_decoder.v` — part of the `bus/` folder, sits between `apb_master.v` and the peripherals.
 
## Address map
 
| Range | Peripheral |
|---|---|
| `0x00 - 0x0F` | I2C |
| `0x10 - 0x1F` | UART |
| `0x20 - 0x2F` | SPI |
 
## Interface
 
| Signal | Dir | Description |
|---|---|---|
| `paddr` | in | address from the master |
| `pselx` | in | select from the master |
| `pselx_i2c` | out | select for the I2C peripheral |
| `pselx_uart` | out | select for the UART peripheral |
| `pselx_spi` | out | select for the SPI peripheral |
 
## How it works
 
Pure combinational block — decodes `paddr` into one of the three ranges above and asserts the matching select line. All selects default low each cycle so only one is ever active.
 
## Note
 
`pselx` (from the master) is currently just an input and isn't gated into the output selects — the decoder fires based on `paddr` alone, regardless of whether the master has actually asserted select. Worth fixing so `pselx_i2c/uart/spi` only go high when `pselx` is also high, otherwise a stale/floating `paddr` could falsely select a peripheral outside a real transaction.
