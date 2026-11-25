# Regression outputs

Full regression of all 27 tests, run on 2026-11-25 with `make regress SEED=1` under VCS R-2020.12-SP2, once with each AHB master:

| Folder | Command | Result |
|---|---|---|
| `ahb_vip/` | `make regress SEED=1 AHB=vip` | 27 / 27 pass, 0 UVM_ERROR, 0 UVM_FATAL |
| `ahb_own/` | `make regress SEED=1 AHB=own` | 27 / 27 pass, 0 UVM_ERROR, 0 UVM_FATAL |

Each folder has:

- `summary.txt`: one line per test with the UVM_ERROR / UVM_FATAL counts and the number of pixels the scoreboard matched.
- `logs/<test>.log`: the simulation log of every test, plus `compile.log`.
- `logs/resol_*.log.gz`: the VGA, HD, Full HD and random-resolution logs, gzipped because they are large (Full HD is 118 MB uncompressed). Read them with `zless` or `gunzip -k`.

Pixels checked by the scoreboard (same for both masters):

| Test | Pixels |
|---|---|
| lane, pixel, vsync and resol_normal tests | 60 each (10 x 3, 2 frames) |
| dsi_frame5_test / frame_10_test | 150 / 300 |
| resol_vga_test, resol_random_test | 614,400 (640 x 480, 2 frames) |
| resol_hd_test | 1,843,200 (1280 x 720, 2 frames) |
| resol_fullhd_test | 4,147,200 (1920 x 1080, 2 frames) |

The four `ahb_*reg_test` logs show the register write and read-back, for example
`[AHB_REG] Register 40000008: wrote and read back 0000003c`.

Which master was used can be seen in the UVM topology printed at the top of each log: `ahb_agth` is `svt_ahb_system_env` in `ahb_vip/` and `ahb_agent` in `ahb_own/`.
