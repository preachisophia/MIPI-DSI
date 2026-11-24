# MIPI-DSI

A MIPI DSI transmitter written in SystemVerilog, together with a UVM testbench that verifies it under Synopsys VCS.

The transmitter takes RGB888 pixels from a display controller (DC) interface, packs each line into a DSI long packet with header ECC and payload CRC, and sends it over 1 to 4 PPI data lanes. Configuration is done through an AHB register interface.

## Repository layout

```
RTL/                     transmitter
  design.sv              top level dsi #(FRAME_LENGTH, FRAME_DEPTH) and AHB register slave
  dsi_reg_block.sv       register model
  dsi_clk_gen.sv         dsi_clk generation (3x pclk)
  line_fifo.sv           buffers one line of pixels
  ecc_gen.sv             header ECC (DSI 9.3)
  crc_gen.sv             payload CRC-16, poly 0x1021, seed 0xFFFF (DSI 9.6)
  packetizer.sv          builds short and long packets
  lane_manager.sv        spreads the byte stream over 1-4 PPI lanes
VERIFY/
  bench/top.sv           testbench top, DUT instance, clocks and reset
  uvc/agent_top/         dc_agent (pixel source), ppi_agent (lane monitor), ahb_agent (sequences for the Synopsys AHB VIP)
  uvm_tb/                env, scoreboard and tests
  bin/                   Makefile and tool setup
```

## Data path

```
 DC (pixel_data, data_valid, hsync, vsync)
        |
    line_fifo --> ecc_gen / crc_gen --> packetizer --> lane_manager --> PPI lanes 0-3
                                                            ^
 AHB --> register block (dsi_cmd, dsi_lng, dsi_ctrl0 ...) --+
```

Each line goes out as three short packets, one long packet and a closing short packet.
The long packet is `AA FF | DI WC(2) ECC | payload (WC bytes) | CRC(2) FF BB`.

## Register map (base 0x4000_0000)

| Offset | Register | Use |
|---|---|---|
| 0x00 | payload | buffer register |
| 0x04 | dsi_cmd | `[8:1]` data identifier (0x3E = 24-bit packed pixel stream) |
| 0x08 | dsi_lng | `[16:1]` word count in bytes (3 x pixels per line) |
| 0x0C | dsi_ctrl0 | `[1:0]` active lanes minus one |
| 0x10 - 0x20 | dsi_ctrl1 - dsi_ctrl5 | control |
| 0x24 / 0x28 / 0x2C | rx_cmd_data / rx_cmd / rd_cmd_wc | receive side |
| 0x30 | rd_cmd_err | status, read only |

## Testbench

- `dc_agent` drives frames of random or fixed pixels with configurable VSYNC/HSYNC widths and resolution (NORMAL 10x3, VGA, HD, Full HD).
- `ppi_agent` samples the four lanes; the scoreboard rebuilds packets from the lane bytes, checks the framing bytes, recovers the pixels and compares them with what the DC side sent. Pixels left uncompared at the end of a test are reported as errors.
- The registers are programmed through the Synopsys AHB VIP master, which also checks AHB protocol rules.
- Functional coverage: `dc_cg` and `ppi_cg` covergroups in the scoreboard. Assertion coverage through `-cm assert`.

## Requirements and setup

The testbench needs licensed Synopsys tools. Nothing from them is included in this repository.

| Tool | Version used | Makefile variable |
|---|---|---|
| VCS (with UVM 1.2) | R-2020.12-SP2 | `VCS_HOME` |
| Verdi (waveforms, GUI) | R-2020.12-SP2 | `VERDI_HOME` |
| VC VIP, AMBA AHB | V-2023.12 | `DESIGNWARE_HOME`, `VIP_VERSION` |
| Licence server | | `SNPSLMD_LICENSE_FILE` |

The AHB master is the Synopsys AMBA VIP, so the testbench does not compile without it. On the first `make compile` the Makefile runs `dw_vip_setup` from `$DESIGNWARE_HOME/bin` to generate the VIP model directory in `VERIFY/bin/vip/` (ignored by git).

The defaults point to `/tools/synopsys/...` and a licence server on port 27000 of the local host. If your install is elsewhere, set the variables in your environment or on the command line:

```
make compile VCS_HOME=/opt/synopsys/vcs/R-2020.12-SP2 \
             VERDI_HOME=/opt/synopsys/verdi/R-2020.12-SP2 \
             DESIGNWARE_HOME=/opt/synopsys/vip VIP_VERSION=V-2023.12 \
             SNPSLMD_LICENSE_FILE=27000@licserver
make info        # shows the paths that will be used
```

Other VCS and VIP versions should work but have not been tried.

## Running

```
cd VERIFY/bin
make compile                       # first run also generates the AHB VIP model dir (make vip)
make run UVM_TEST=lane_3_test SEED=1
make regress SEED=1                # all 27 tests, one log per test in logs/
make run UVM_TEST=lane_0_test GUI=1   # Verdi
make help                          # all targets and tests
```

The VGA, HD and Full HD tests move millions of pixels, so they run with per-pixel messages and the FSDB dump turned off. Use `VERBOSITY=UVM_MEDIUM DUMP=1` to turn them back on.

## Tests

| Group | Tests |
|---|---|
| Base | mipi_test |
| Lanes | lane_0_test ... lane_3_test (1 to 4 lanes) |
| Frames | dsi_frame5_test, frame_10_test |
| Sync | vsync_random_test, vsync_5_test, vsync_10_test |
| Pixels | pixel_random, white, black, red, green, blue, low, high |
| Resolution | resol_normal_test, resol_vga_test, resol_hd_test, resol_fullhd_test, resol_random_test |
| Registers | ahb_payloadreg_test, ahb_dsicmdreg_test, ahb_dsilngreg_test, ahb_ctrl0reg_test |

Current status (`make regress SEED=1`): 27 of 27 pass with no UVM errors. The Full HD test compares 4,147,200 pixels (1920 x 1080, 2 frames).
