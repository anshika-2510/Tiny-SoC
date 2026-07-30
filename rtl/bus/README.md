
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

