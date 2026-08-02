# Tiny-SoC

A small SoC built from scratch in Verilog — a set of common peripherals (UART, SPI, I2C) wired to a shared APB bus, along with their testbenches and simulation waveforms.

## Overview

Tiny-SoC integrates standard communication peripherals behind an APB (Advanced Peripheral Bus) wrapper, so each peripheral is addressed and controlled through a common register interface rather than being driven ad hoc. Each peripheral is developed and verified standalone first, then wrapped for APB access.

## Architecture

```
                ┌─────────────────────────────┐
                │        APB Wrapper          │
   APB bus ───▶ │  (addr decode / reg access)  │
                └───────────┬─────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
   ┌──────────┐       ┌──────────┐        ┌──────────┐
   │   UART   │       │   SPI    │        │   I2C    │
   │ (16x OS, │       │ (master/ │        │          │
   │  FIFO)   │       │  slave)  │        │          │
   └──────────┘       └──────────┘        └──────────┘
```

## Peripherals

| Peripheral | Description | Status |
|---|---|---|
| **UART** | RX with 16x oversampling for baud recovery, plus FIFO buffering | DONE |
| **SPI** | Master + slave, Mode 0 (CPOL=0, CPHA=0) | DONE |
| **I2C** | — | DONE |
| **APB Wrapper** | Common register-access layer for all peripherals above | In progress |



## Simulation

Each peripheral has its own testbench under its respective folder. Waveforms are captured per-module (see individual module READMEs for details and bug notes).

## Status

Actively under development — peripherals are being verified individually before final APB integration.
