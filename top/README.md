# Top-Level SoC

## Overview

The `top` directory contains the top-level integration of the Tiny SoC. It instantiates and connects all on-chip peripherals through the APB interconnect, providing a unified hardware system.

---

## Responsibilities

- Instantiate all peripheral wrappers
- Connect APB master and decoder
- Route system clock and reset
- Manage address decoding
- Interface with external I/O
- Serve as the top-level module for simulation and synthesis

---

## Modules

| Module | Description |
|---------|-------------|
| `soc_top.v` | Top-level Tiny SoC module integrating all peripherals |

---

## Integrated Peripherals

- UART
- SPI
- I2C
- AES-128 Accelerator
- FIFO

---

## Bus Architecture

The Tiny SoC uses an **AMBA APB** interconnect to communicate with all peripherals.

```
               +----------------------+
               |      soc_top.v       |
               +----------+-----------+
                          |
                     APB Interconnect
                          |
      +---------+---------+---------+---------+
      |         |         |         |         |
    UART      SPI       I2C       AES       FIFO
```

---

## External Interfaces

### Inputs

- System Clock (`clk`)
- Active-High Reset (`rst`)

### Outputs

- Peripheral Interface Signals
- APB Control Signals

---

## Design Flow

1. Reset the system
2. APB master initiates a transaction
3. Address decoder selects the target peripheral
4. Peripheral wrapper receives the APB request
5. Peripheral executes the operation
6. Response is returned to the master

---

## Status

- ✅ Top-Level Architecture Defined
- 🚧 Peripheral Integration In Progress
- ⏳ System-Level Verification Pending
