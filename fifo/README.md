# FIFO
 
Parameterizable synchronous FIFO, built for buffering data between blocks in the Tiny SoC (e.g. UART TX/RX, or between APB peripherals and the core). Classic circular-buffer design with separate read/write pointers and full/empty flags derived from pointer comparison.
 
## Features
 
- Parameterizable data width (`B`) and depth (`2^W` words)
- Single clock domain (synchronous FIFO, not dual-clock/async)
- Circular buffer using read pointer / write pointer + MSB-style full/empty detection
- Simultaneous read + write in the same cycle supported
- Write is automatically blocked when full (`wr_en = wr & ~full_reg`)
## Parameters
 
| Parameter | Default | Description |
|---|---|---|
| `B` | 8 | word width in bits |
| `W` | 4 | address width → depth = `2^W` = 16 words |
 
## Interface
 
| Signal | Dir | Description |
|---|---|---|
| `clk`, `reset` | in | clock, reset |
| `wr` | in | write request |
| `rd` | in | read request |
| `w_data` | in | data to write |
| `r_data` | out | data at current read pointer (combinational read) |
| `full` | out | FIFO is full |
| `empty` | out | FIFO is empty |
 
## How it works
 
Read and write pointers each walk the circular buffer independently. On a write, `w_ptr` advances; on a read, `r_ptr` advances. `full` gets set when the write pointer catches up to the read pointer (buffer wrapped around), and `empty` gets set when the read pointer catches up to the write pointer. Simultaneous read+write just advances both pointers without touching the flags, since a same-cycle read+write keeps occupancy constant.
 
`r_data` is driven combinationally straight off `array_reg[r_ptr_reg]`, so read data is available the same cycle `r_ptr_reg` points to it — no extra read latency.
