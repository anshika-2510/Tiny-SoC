# SPI LOOPBACK-Master and Slave
<img width="971" height="374" alt="image" src="https://github.com/user-attachments/assets/1ff3391d-6f5a-4ae0-ac98-bc1d9bc7bd35" />


# SPI Master-Slave (Mode 0) — Simulation Waveform

Simulation of `spi_master` + `spi_slave` (SPI Mode 0, CPOL=0/CPHA=0) exchanging one byte in each direction.

**Test vectors:**
- `master_tx_data = 8'hA5` → received by slave as `slave_rx_data`
- `slave_tx_data  = 8'h3C` → received by master as `master_rx_data`

## Waveform

![SPI waveform](waveform.png)

| Signal | Value | Notes |
|---|---|---|
| `master_tx_data` | `A5` | Byte master sends |
| `master_rx_data` | `3C` | Byte master receives — matches `slave_tx_data` ✅ |
| `slave_tx_data`  | `3C` | Byte slave sends |
| `slave_rx_data`  | `A5` | Byte slave receives — matches `master_tx_data` ✅ |

## Bug fixed in this run

An earlier version of `spi_master` deasserted `cs` in the **same clock edge** as the final (8th) bit sample. Since the slave's RX-sampling block is gated on `!cs`, that created a same-edge race in simulation: the slave's last `posedge sclk` sample could see `cs` already high and silently skip the last bit.

**Symptom:** `slave_rx_data` read `0x52` instead of `0xA5` — a shift register missing exactly one sample looks like the correct value shifted right by one bit with a `0` shifted in at the MSB, which is what `0x52` is relative to `0xA5`.

**Fix:** added a `COOL` state in the master FSM so `cs` is only deasserted one clock *after* the final sample completes, giving the slave's last `posedge sclk` a clean, unambiguous view of `cs == 0`.

```verilog
if (ct == 7)
begin
    rx_data <= {rx_shift[6:0], miso};
    done    <= 1;
    busy    <= 0;
    state   <= COOL;   
end
...
COOL: begin
    cs    <= 1;
    state <= IDLE;
end
```

After the fix, both `master_rx_data` and `slave_rx_data` land on the correct values, as shown above.
