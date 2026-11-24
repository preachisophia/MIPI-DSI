class ppi_monitor extends uvm_monitor;

`uvm_component_utils(ppi_monitor)
virtual ppi_if.ppi_mon_mp vif;
ppi_cfg	       p_cfg;
ppi_xtn        p_xh;
uvm_analysis_port #(ppi_xtn) ppi_port;

function new(string name="ppi_monitor", uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ppi_port=new("ppi_port",this);
if(!uvm_config_db#(ppi_cfg)::get(this,"","ppi_cfg",p_cfg))
`uvm_fatal("PPI_DRIVER","VIF GETTING FAILD")
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
vif=p_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever
begin
	collect_data();
end
endtask

task collect_data();
p_xh=ppi_xtn::type_id::create("p_xh");

@(vif.ppi_mon_cb);
p_xh.ppi_data_lane0=vif.ppi_mon_cb.ppi_data_lane0;
p_xh.ppi_data_lane1=vif.ppi_mon_cb.ppi_data_lane1;
p_xh.ppi_data_lane2=vif.ppi_mon_cb.ppi_data_lane2;
p_xh.ppi_data_lane3=vif.ppi_mon_cb.ppi_data_lane3;
p_xh.ppi_lane0_en  =vif.ppi_mon_cb.ppi_lane0_en;
p_xh.ppi_lane1_en  =vif.ppi_mon_cb.ppi_lane1_en;
p_xh.ppi_lane2_en  =vif.ppi_mon_cb.ppi_lane2_en;
p_xh.ppi_lane3_en  =vif.ppi_mon_cb.ppi_lane3_en;
ppi_port.write(p_xh);
//$display("&&&&&&&&&&&&&&&&&&&&&&& PPI_MON &&&&&&&&&&&&&&&&&&&&&&&");
//`uvm_info("PPI_MON",p_xh.sprint(), UVM_MEDIUM)


endtask

endclass


