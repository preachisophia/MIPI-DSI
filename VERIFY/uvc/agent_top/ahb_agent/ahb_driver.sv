class ahb_driver extends uvm_driver#(ahb_xtn);

`uvm_component_utils(ahb_driver)
virtual ahb_if.ahb_drv_mp vif;
ahb_cfg	      a_cfg;

localparam bit [1:0] IDLE   = 2'b00;
localparam bit [1:0] NONSEQ = 2'b10;

function new(string name="ahb_driver", uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(ahb_cfg)::get(this,"","ahb_cfg",a_cfg))
`uvm_fatal("AHB_DRIVER","AHB_CFG GETTING FAILED")
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
 vif = a_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
bus_idle();
@(vif.ahb_drv_cb);
while(!vif.ahb_drv_cb.hresetn)
  @(vif.ahb_drv_cb);
forever
begin
	seq_item_port.get_next_item(req);
	send_to_dut(req);
	seq_item_port.item_done();
end
endtask

task bus_idle();
    vif.ahb_drv_cb.haddr  <= 32'h0;
    vif.ahb_drv_cb.hwrite <= 1'b0;
    vif.ahb_drv_cb.hsize  <= 3'b010;   //WORD
    vif.ahb_drv_cb.hburst <= 3'b000;   //SINGLE
    vif.ahb_drv_cb.htrans <= IDLE;
    vif.ahb_drv_cb.hwdata <= 32'h0;
    vif.ahb_drv_cb.hprot  <= 4'b0011;  //non-cacheable, non-bufferable, privileged data access
endtask

// One SINGLE transfer: address phase, then data phase. HWDATA is driven only in
// the data phase and HRDATA is sampled when the data phase completes (HREADY high).
task send_to_dut(ahb_xtn a_h);
   //ADDRESS PHASE
   @(vif.ahb_drv_cb);
   vif.ahb_drv_cb.haddr  <= a_h.addr;
   vif.ahb_drv_cb.hwrite <= a_h.write;
   vif.ahb_drv_cb.hsize  <= 3'b010;
   vif.ahb_drv_cb.hburst <= 3'b000;
   vif.ahb_drv_cb.htrans <= NONSEQ;
   do @(vif.ahb_drv_cb); while(!vif.ahb_drv_cb.hready);

   //DATA PHASE
   vif.ahb_drv_cb.htrans <= IDLE;
   vif.ahb_drv_cb.hwrite <= 1'b0;
   if(a_h.write)
     vif.ahb_drv_cb.hwdata <= a_h.data;
   do @(vif.ahb_drv_cb); while(!vif.ahb_drv_cb.hready);

   if(!a_h.write)
     a_h.data = vif.ahb_drv_cb.hrdata;
   a_h.resp = vif.ahb_drv_cb.hresp;
   `uvm_info("AHB_DRV",a_h.convert2string(),UVM_HIGH)
endtask

endclass
