# I2C Master Controller

Verilog implementation of an I2C master, built as part of my tiny SoC project. Handles standard I2C transactions (7-bit addressing, read/write, ACK/NACK) between the master and a slave device over SDA/SCL.

## What it does

- Generates START and STOP conditions
- Drives SDA/SCL for master-mode single-master communication
- Supports 7-bit slave addressing
- Read and write transactions
- ACK/NACK detection after each byte
- `busy` and `done` status flags for the wrapper/CPU to poll

## Files

| File | What's in it |
|---|---|
| `i2c_master.sv` | Core I2C master FSM + datapath |
| `i2c_wrapper.sv` | APB wrapper (register interface for CPU) |
| `tb_i2c.sv` | Testbench |

## How it works (short version)

The controller is an FSM that walks through: IDLE → START → ADDR → ACK → DATA (read or write) → ACK/NACK → STOP. SCL is generated internally from the system clock (divided down), SDA is tri-stated when not driving so the slave can pull it low for ACK.

## Status

- RTL: done
- APB wrapper: in progress
- Full SoC integration: not started yet

## Testing done so far

- Reset behavior
- Single-byte write transaction
- Single-byte read transaction
- ACK detection
- NACK detection (slave doesn't respond)

## TODO

- [ ] Multi-byte burst transactions
- [ ] Clock stretching support
- [ ] Finish APB wrapper + hook into SoC bus
- [ ] Add repeated START support
