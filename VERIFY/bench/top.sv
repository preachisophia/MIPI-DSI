// AHB master is chosen at compile time:
//   default            : Synopsys AHB VIP (make AHB=vip)
//   +define+MIPI_OWN_AHB : testbench's own ahb_agent (make AHB=own)
`ifndef MIPI_OWN_AHB
`include "svt_ahb_if.svi"
`endif
`include "uvm_pkg.sv"
`ifndef MIPI_OWN_AHB
`include "svt_ahb.uvm.pkg"
`include "svt_ahb_port_defines.svi"
`endif

module top;

import uvm_pkg::*;
`ifndef MIPI_OWN_AHB
/** Import the SVT UVM Package */
import svt_uvm_pkg::*;
/** Import the AHB VIP */
import svt_ahb_uvm_pkg::*;
`endif

//MIPI PACKAGE
import mipi_pkg::*;

bit hrstn;

bit h_clk;
bit d_clk;

initial
begin
h_clk=0;
forever #5 h_clk  =~h_clk;//100MHz (10 time-unit period)
end

initial
begin
hrstn<=0;
@(negedge h_clk);
hrstn<=1;
end

`ifdef MIPI_OWN_AHB
/** Own AHB agent interface */
ahb_if a_if(h_clk, hrstn);
`else
/** VIP Interface instance representing the AHB system */
svt_ahb_if h_if();
assign h_if.hclk = h_clk;
/**Assign the reset pin from the reset interface to the reset pins from the VIP interface**/
assign h_if.hresetn =hrstn;

assign h_if.master_if[0].hgrant =1;
`endif

dc_if  d_if(h_clk);
ppi_if p_if();

//DUT INSTANTIATION
dsi #(1920,1080) DUT  // FRAME_LENGTH = widest line (FULL_HD) 
  	 (
`ifdef MIPI_OWN_AHB
          .haddr(a_if.haddr),
          .hwrite(a_if.hwrite),
          .hsize(a_if.hsize),
          .hburst(a_if.hburst),
          .htrans(a_if.htrans),
          .hwdata(a_if.hwdata),
          .hprot(a_if.hprot),
          .hresp(a_if.hresp),
          .hready(a_if.hready),
          .hrdata(a_if.hrdata),
`else
          .haddr(h_if.master_if[0].haddr),
  	  .hwrite(h_if.master_if[0].hwrite),
          .hsize(h_if.master_if[0].hsize),
          .hburst(h_if.master_if[0].hburst),
          .htrans(h_if.master_if[0].htrans),
          .hwdata(h_if.master_if[0].hwdata),
          .hprot(h_if.master_if[0].hprot),
          .hresp(h_if.hresp_bus),
  	  .hready(h_if.hready_bus),
	  .hrdata(h_if.hrdata_bus),
`endif

          .pixel_data(d_if.pixel_data),
  	  .data_valid(d_if.data_valid),
          .hsync(d_if.hsync),
  	  .vsync(d_if.vsync),

          .pclk(h_clk),
          .dsi_clk(p_if.d_clk),
          .dsi_rst(hrstn),

          .ppi_data_lane0(p_if.ppi_data_lane0),
          .ppi_data_lane1(p_if.ppi_data_lane1),
          .ppi_data_lane2(p_if.ppi_data_lane2),
          .ppi_data_lane3(p_if.ppi_data_lane3),
          .ppi_lane0_en(p_if.ppi_lane0_en),
          .ppi_lane1_en(p_if.ppi_lane1_en),
          .ppi_lane2_en(p_if.ppi_lane2_en),
          .ppi_lane3_en(p_if.ppi_lane3_en));
			
initial
begin
`ifdef MIPI_OWN_AHB
uvm_config_db#(virtual ahb_if)::set(null,"*","ahb_if",a_if);
`else
uvm_config_db#(virtual svt_ahb_if)::set(null,"*","vif",h_if);
`endif
uvm_config_db#(virtual dc_if)::set(null,"*","dc_if",d_if);
uvm_config_db#(virtual ppi_if)::set(null,"*","ppi_if",p_if);
run_test();
end

initial
begin
if($test$plusargs("ENABLE_DUMP"))
 begin
    `ifdef XCELIUM
       $shm_open("waves.shm", 1);
       $shm_probe("ASCTF");
    `else
       $fsdbDumpfile("./mydump.fsdb");
       $fsdbDumpvars; 
    `endif
 end
end


/*


property p_first_transfer_nonseq;
  @(posedge h_clk) disable iff (!hrstn)
  (h_if.master_if[0].htrans == 2'b00) |-> ##[1:$](h_if.master_if[0].htrans == 2'b10);
endproperty

AHB_A1:assert property(p_first_transfer_nonseq)
  else 
$error("AHB ERROR: First transfer must start with NONSEQ");

property p_busy_followed_by_seq;
  @(posedge h_clk) disable iff (!hrstn)
  (h_if.master_if[0].htrans == 2'b01) |=> (h_if.master_if[0].htrans == 2'b11);
endproperty

AHB_A2:assert property(p_busy_followed_by_seq)
  else 
$error("AHB ERROR: BUSY must be followed by SEQ");

property p_ahb_htrans_valid;
  @(posedge h_clk)  disable iff (!hrstn)
  (h_if.master_if[0].htrans inside {2'b10, 2'b11}) |-> !$isunknown(h_if.master_if[0].htrans);
endproperty

AHB_A3:assert property(p_ahb_htrans_valid)
  else 
$error("AHB ERROR: HTRANS contains X/Z");

property p_ahb_control_stable;
  @(posedge h_clk)  disable iff (!hrstn)
  (!h_if.hready_bus && (h_if.master_if[0].htrans inside {2'b10, 2'b11})) |=> $stable(h_if.master_if[0].haddr)  &&
      $stable(h_if.master_if[0].hwrite) &&
      $stable(h_if.master_if[0].hsize)  &&
      $stable(h_if.master_if[0].hburst) &&
      $stable(h_if.master_if[0].htrans);
endproperty

AHB_A4:assert property(p_ahb_control_stable)
  else 
$error("AHB ERROR: Address/control changed while HREADY=0");

property p_ahb_resp_stable;
  @(posedge h_clk) disable iff (!hrstn)
  (!h_if.hready_bus) |-> $stable(h_if.master_if[0].hresp_bus);
endproperty

AHB_A5:assert property(p_ahb_resp_stable)
  else 
$error("AHB ERROR: RESP stable while HREADY=0");

property p_ahb_wdata_stable;
  @(posedge h_clk) disable iff (!hrstn)
  (!h_if.hready_bus && h_if.master_if[0].hwrite && (h_if.master_if[0].htrans inside {2'b10, 2'b11}))
  |=> $stable(h_if.master_if[0].hwdata);
endproperty

AHB_A6:assert property(p_ahb_wdata_stable)
  else 
$error("AHB ERROR: HWDATA changed while HREADY=0");

property p_ahb_rdata_stable;
  @(posedge h_clk) disable iff (!hrstn)
  (!h_if.hready_bus && !h_if.master_if[0].hwrite && (h_if.master_if[0].htrans inside {2'b10, 2'b11}))
  |=> $stable(h_if.hrdata_bus);
endproperty

AHB_A7:assert property(p_ahb_rdata_stable)
  else
$error("AHB ERROR: HRDATA changed while HREADY=0");

property p_ahb_word_alignment;
  @(posedge h_clk) disable iff (!hrstn)
  ((h_if.master_if[0].htrans inside {2'b10, 2'b11}) &&  h_if.master_if[0].hsize == 3'b010)
  |-> (h_if.master_if[0].haddr[1:0] == 2'b00);
endproperty

AHB_A8:assert property(p_ahb_word_alignment)
  else 
$error("AHB ERROR: 32-bit transfer is not 4-byte aligned");

property p_ahb_address_valid;
  @(posedge h_clk) disable iff (!hrstn)
  (h_if.master_if[0].htrans inside {2'b10, 2'b11}) |-> !$isunknown(h_if.master_if[0].haddr);
endproperty

AHB_A9:assert property(p_ahb_address_valid)
  else 
$error("AHB ERROR: HADDR contains X/Z");

// Maximum 16 wait cycles in this example.
property p_ahb_ready_eventually;
  @(posedge h_clk) disable iff (!hrstn)
  ((h_if.master_if[0].htrans inside {2'b10, 2'b11}) && !h_if.hready_bus)
  |-> ##[1:16] h_if.hready_bus;
endproperty

AHB_A10:assert property(p_ahb_ready_eventually)
  else 
$error("AHB ERROR: HREADY remained LOW for too long");

property p_ahb_reset_idle;
  @(posedge h_clk)
  !hrstn |-> (h_if.master_if[0].htrans == 2'b00);
endproperty

AHB_A11:assert property(p_ahb_reset_idle)
  else 
$error("AHB ERROR: HTRANS is not IDLE during reset");

property p_dcpix_stable;
@(posedge h_clk) disable iff(hrstn)
d_if.data_valid |-> d_if.pixel_data!=0;
endproperty

DC_A1:assert property(p_dcpix_stable)
  else 
$error("DC ERROR: while DATA_VALID is assert PIXEL_DATA is 0");

property p_vsyncaftrhsync;
@(posedge h_clk) disable iff(hrstn)
d_if.vsync |=> ##[1:$]d_if.hsync;
endproperty

DC_A2:assert property(p_vsyncaftrhsync)
  else 
$error("DC ERROR: while VSYNC is assert after HSYNC is not asserted");


C1:cover property(p_first_transfer_nonseq);
C2:cover property(p_busy_followed_by_seq);
C3:cover property(p_ahb_htrans_valid);
C4:cover property(p_ahb_control_stable);
C5:cover property(p_ahb_resp_stable);
C6:cover property(p_ahb_wdata_stable);
C7:cover property(p_ahb_rdata_stable);
C8:cover property(p_ahb_word_alignment);
C9:cover property(p_ahb_address_valid);
C10:cover property(p_ahb_ready_eventually);
C11:cover property(p_ahb_reset_idle);
C12:cover property(p_dcpix_stable);
C13:cover property(p_vsyncaftrhsync);

*/
endmodule


