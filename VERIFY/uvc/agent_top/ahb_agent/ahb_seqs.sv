
/**
 * AHB register sequences used by the tests.
 *
 * The same sequences run on either AHB master, chosen at compile time:
 *   default (make AHB=vip) : Synopsys AHB VIP master (svt_ahb_master_transaction)
 *   MIPI_OWN_AHB (AHB=own) : the testbench's own ahb_agent (ahb_xtn)
 * Only write_reg()/read_reg() in the base class know which master is in use.
 *
 * Sequencer: env.ahb_sqr
 */

`ifndef GUARD_AHB_MASTER_DIRECTED_SEQUENCE_SV
`define GUARD_AHB_MASTER_DIRECTED_SEQUENCE_SV

`ifdef MIPI_OWN_AHB
class ahb_seqs extends uvm_sequence#(ahb_xtn);
`else
class ahb_seqs extends svt_ahb_master_transaction_base_sequence;
`endif

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_seqs)

  /** Class Constructor */
  function new(string name="ahb_seqs");
    super.new(name);
  endfunction

virtual task body();
endtask

  // single 32-bit write
  task write_reg(bit [31:0] reg_addr, bit [31:0] reg_data);
`ifdef MIPI_OWN_AHB
    ahb_xtn a_h;
    `uvm_do_with(a_h,
        {
          a_h.write == 1'b1;
          a_h.addr  == reg_addr;
          a_h.data  == reg_data;
        })
`else
    svt_ahb_master_transaction svt_xtn;
    svt_xtn=svt_ahb_master_transaction::type_id::create("svt_xtn");
    `uvm_do_with(svt_xtn,
        {
          svt_xtn.xact_type    == svt_ahb_transaction::WRITE;
          svt_xtn.addr         == reg_addr;
          svt_xtn.burst_type   == svt_ahb_transaction::SINGLE;
          svt_xtn.burst_size   == svt_ahb_transaction::BURST_SIZE_32BIT;
          data.size() == 1;
          data[0] == reg_data;
        })
`endif
  endtask

  // single 32-bit read
  task read_reg(bit [31:0] reg_addr, output logic [31:0] reg_data);
`ifdef MIPI_OWN_AHB
    ahb_xtn a_h;
    `uvm_do_with(a_h,
        {
          a_h.write == 1'b0;
          a_h.addr  == reg_addr;
        })
    reg_data = a_h.data;
`else
    svt_ahb_master_transaction svt_xtn;
    svt_xtn=svt_ahb_master_transaction::type_id::create("svt_xtn");
    `uvm_do_with(svt_xtn,
        {
          svt_xtn.xact_type    == svt_ahb_transaction::READ;
          svt_xtn.addr         == reg_addr;
          svt_xtn.burst_type   == svt_ahb_transaction::SINGLE;
          svt_xtn.burst_size   == svt_ahb_transaction::BURST_SIZE_32BIT;
          data.size() == 1;
        })
    svt_xtn.wait_end();  //the VIP returns from uvm_do when the transfer is issued; wait for the read data
    reg_data = svt_xtn.data[0];
`endif
  endtask

  // write a register, read it back and compare
  task write_read_check(bit [31:0] reg_addr, bit [31:0] reg_data);
    logic [31:0] rd_data;
    write_reg(reg_addr, reg_data);
    read_reg (reg_addr, rd_data);
    if(rd_data !== reg_data)
      `uvm_error("AHB_REG",$sformatf("Register %08h: wrote %08h, read back %08h",reg_addr,reg_data,rd_data))
    else
      `uvm_info("AHB_REG",$sformatf("Register %08h: wrote and read back %08h",reg_addr,rd_data),UVM_LOW)
  endtask

  // DSI set-up: payload, dsi_cmd, dsi_lng, dsi_ctrl0 (lanes), dsi_ctrl1
  //   dsi_cmd[8:1] = data identifier (0x3E, 24-bit packed pixel stream)
  //   dsi_lng[16:1] = word count in bytes, maximum 21845 RGB-888 pixels
  //   dsi_ctrl0[1:0] = active lanes - 1 (2'b00 = 1 lane ... 2'b11 = 4 lanes)
  task dsi_setup(bit [31:0] lng, bit [31:0] ctrl0);
    write_reg(32'h4000_0000, 32'h0);    //buffer register
    write_reg(32'h4000_0004, 32'h7c);   //dsi_cmd
    write_reg(32'h4000_0008, lng);      //dsi_lng - word count
    write_reg(32'h4000_000c, ctrl0);    //dsi_ctrl0 - no. of lanes
    write_reg(32'h4000_0010, 32'h2);    //dsi_ctrl1
  endtask

endclass

class ahb_dsireg_seqs extends ahb_seqs;

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_dsireg_seqs)

  /** Class Constructor */
  function new(string name="ahb_dsireg_seqs");
    super.new(name);
  endfunction

  virtual task body();
    dsi_setup(32'h3c, 32'h3);
  endtask: body

endclass

//$$$$$$$$$$$$$$$$$$$$$$$ AHB_SEQS_LANE-0(1 lane alone enable) $$$$$$$$$$$$$$$$$$$$$$$$$$
class ahb_seqs_lane_0 extends ahb_seqs;

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_seqs_lane_0)

  /** Class Constructor */
  function new(string name="ahb_seqs_lane_0");
    super.new(name);
  endfunction

  virtual task body();
    dsi_setup(32'h3c, 32'h0);
  endtask: body

endclass

//$$$$$$$$$$$$$$$$$$$$$$$ AHB_SEQS_LANE-1(2 lanes enable) $$$$$$$$$$$$$$$$$$$$$$$$$$
class ahb_seqs_lane_1 extends ahb_seqs;

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_seqs_lane_1)

  /** Class Constructor */
  function new(string name="ahb_seqs_lane_1");
    super.new(name);
  endfunction

  virtual task body();
    dsi_setup(32'h3c, 32'h1);
  endtask: body

endclass

//$$$$$$$$$$$$$$$$$$$$$$$ AHB_SEQS_LANE-2(3 lanes enable) $$$$$$$$$$$$$$$$$$$$$$$$$$
class ahb_seqs_lane_2 extends ahb_seqs;

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_seqs_lane_2)

  /** Class Constructor */
  function new(string name="ahb_seqs_lane_2");
    super.new(name);
  endfunction

  virtual task body();
    dsi_setup(32'h3c, 32'h2);
  endtask: body

endclass

//$$$$$$$$$$$$$$$$$$$$$$$ AHB_SEQS_LANE-3(4 lanes enable) $$$$$$$$$$$$$$$$$$$$$$$$$$
class ahb_seqs_lane_3 extends ahb_seqs;

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_seqs_lane_3)

  // dsi_lng[16:1] = WC (payload bytes per line); default 0x3c = 10 RGB888 pixels (NORMAL)
  bit [31:0] lng_val = 32'h3c;

  /** Class Constructor */
  function new(string name="ahb_seqs_lane_3");
    super.new(name);
  endfunction

  function void set_pixels_per_line(int pixels);
    lng_val = (pixels*3) << 1;
  endfunction

  virtual task body();
    dsi_setup(lng_val, 32'h3);
  endtask: body

endclass

//$$$$$$$$$$$$$$$$$$$$$$$ AHB_PLAYLODREG_SEQS $$$$$$$$$$$$$$$$$$$$$$$$$$
class ahb_payloadreg_seqs extends ahb_seqs;

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_payloadreg_seqs)

  /** Class Constructor */
  function new(string name="ahb_payloadreg_seqs");
    super.new(name);
  endfunction

  virtual task body();
    write_read_check(32'h4000_0000, 32'h0);    //buffer register
  endtask: body

endclass

//$$$$$$$$$$$$$$$$$$$$$$$ AHB_DSICMDREG_SEQS $$$$$$$$$$$$$$$$$$$$$$$$$$
class ahb_dsicmdreg_seqs extends ahb_seqs;

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_dsicmdreg_seqs)

  /** Class Constructor */
  function new(string name="ahb_dsicmdreg_seqs");
    super.new(name);
  endfunction

  virtual task body();
    write_read_check(32'h4000_0004, 32'h7c);
  endtask: body

endclass

//$$$$$$$$$$$$$$$$$$$$$$$ AHB_DSILNGREG_SEQS $$$$$$$$$$$$$$$$$$$$$$$$$$
class ahb_dsilngreg_seqs extends ahb_seqs;

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_dsilngreg_seqs)

  /** Class Constructor */
  function new(string name="ahb_dsilngreg_seqs");
    super.new(name);
  endfunction

  virtual task body();
    write_read_check(32'h4000_0008, 32'h3c);
  endtask: body

endclass

//$$$$$$$$$$$$$$$$$$$$$$$ AHB_DSICTRL0REG_SEQS $$$$$$$$$$$$$$$$$$$$$$$$$$
class ahb_dsictrl0reg_seqs extends ahb_seqs;

  /** UVM Object Utility macro */
  `uvm_object_utils(ahb_dsictrl0reg_seqs)

  /** Class Constructor */
  function new(string name="ahb_dsictrl0reg_seqs");
    super.new(name);
  endfunction

  virtual task body();
    write_read_check(32'h4000_000c, 32'h3);
  endtask: body

endclass

`endif // GUARD_AHB_MASTER_DIRECTED_SEQUENCE_SV
