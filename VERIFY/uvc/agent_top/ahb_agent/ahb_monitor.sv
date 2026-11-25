class ahb_monitor extends uvm_monitor;

`uvm_component_utils(ahb_monitor)
virtual ahb_if.ahb_mon_mp vif;
ahb_cfg	      a_cfg;
uvm_analysis_port #(ahb_xtn) ahb_port;

int unsigned xfer_cnt;

function new(string name="ahb_monitor", uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_port=new("ahb_port",this);
if(!uvm_config_db#(ahb_cfg)::get(this,"","ahb_cfg",a_cfg))
`uvm_fatal("AHB_MONITOR","AHB_CFG GETTING FAILED")
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
 vif = a_cfg.vif;
endfunction

// A transfer is accepted in the address phase (HTRANS NONSEQ/SEQ with HREADY high)
// and completes at the end of the following data phase (next cycle with HREADY high).
task run_phase(uvm_phase phase);
ahb_xtn a_h;
bit     pending;
super.run_phase(phase);
forever
begin
   @(vif.ahb_mon_cb);
   if(!vif.ahb_mon_cb.hresetn)
     pending = 0;
   else
   begin
     if(pending && vif.ahb_mon_cb.hready)
     begin
       pending = 0;
       a_h.resp = vif.ahb_mon_cb.hresp;
       if(a_h.write)
         a_h.data = vif.ahb_mon_cb.hwdata;
       else
         a_h.data = vif.ahb_mon_cb.hrdata;
       check_xfer(a_h);
       xfer_cnt++;
       ahb_port.write(a_h);
       `uvm_info("AHB_MON",a_h.convert2string(),UVM_MEDIUM)
     end
     if(vif.ahb_mon_cb.htrans[1] && vif.ahb_mon_cb.hready)
     begin
       a_h = ahb_xtn::type_id::create("a_h");
       a_h.addr  = vif.ahb_mon_cb.haddr;
       a_h.write = vif.ahb_mon_cb.hwrite;
       pending   = 1;
       if($isunknown({vif.ahb_mon_cb.haddr,vif.ahb_mon_cb.hwrite,vif.ahb_mon_cb.hsize}))
         `uvm_error("AHB_MON","HADDR/HWRITE/HSIZE contain X/Z in the address phase")
       if(vif.ahb_mon_cb.haddr[1:0] != 2'b00 && vif.ahb_mon_cb.hsize == 3'b010)
         `uvm_error("AHB_MON",$sformatf("Word transfer to unaligned address %08h",vif.ahb_mon_cb.haddr))
     end
   end
end
endtask

function void check_xfer(ahb_xtn a_h);
  if(a_h.resp != 2'b00)
    `uvm_error("AHB_MON",$sformatf("HRESP is not OKAY: %s",a_h.convert2string()))
  if($isunknown(a_h.data))
    `uvm_error("AHB_MON",$sformatf("%s must not be X/Z: %s",a_h.write ? "HWDATA" : "HRDATA",a_h.convert2string()))
endfunction

function void report_phase(uvm_phase phase);
super.report_phase(phase);
`uvm_info("AHB_MON",$sformatf("AHB transfers observed: %0d",xfer_cnt),UVM_LOW)
endfunction

endclass
