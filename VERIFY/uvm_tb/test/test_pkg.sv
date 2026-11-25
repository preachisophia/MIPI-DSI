`ifndef MIPI_OWN_AHB
`include "svt_ahb.uvm.pkg"
`endif
package mipi_pkg;

import uvm_pkg::*;
`ifndef MIPI_OWN_AHB
import svt_uvm_pkg::*;
/** Import the AHB VIP */
import svt_ahb_uvm_pkg::*;
/** Import the AMBA COMMON Package for amba_pv_extension */
import svt_amba_common_uvm_pkg::*;
`endif

`include "uvm_macros.svh"

`include "dc_cfg.sv"
`include "ppi_cfg.sv"
`include "env_cfg.sv"

`ifdef MIPI_OWN_AHB
//OWN AHB AGENT (make AHB=own)
`include "ahb_xtn.sv"
`include "ahb_cfg.sv"
`include "ahb_seqr.sv"
`include "ahb_driver.sv"
`include "ahb_monitor.sv"
`include "ahb_agent.sv"
`endif
`include "ahb_seqs.sv"

`include "dc_xtn.sv"
`include "dc_seqr.sv"
`include "dc_seqs.sv"
`include "dc_driver.sv"
`include "dc_monitor.sv"
`include "dc_agent.sv"

`include "ppi_xtn.sv"
`include "ppi_seqr.sv"
`include "ppi_monitor.sv"
`include "ppi_agent.sv"

`include "sb.sv"
`include "env.sv"
`include "test.sv"

endpackage


