class dc_monitor extends uvm_monitor;

`uvm_component_utils(dc_monitor)
virtual dc_if.dc_mon_mp vif;
dc_cfg	      d_cfg;
dc_xtn	      d_xh,cov_xh;
uvm_analysis_port #(dc_xtn) dc_port;
uvm_analysis_port #(dc_xtn) dc_cov_port;

function new(string name="dc_monitor", uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
dc_port=new("dc_port",this);
dc_cov_port=new("dc_cov_port",this);
if(!uvm_config_db#(dc_cfg)::get(this,"","dc_cfg",d_cfg))
`uvm_fatal("DC_MONITOR","VIF GETTING FAILED")
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
 vif = d_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever
begin
	collect_data();
end
endtask

task collect_data();
        @(vif.dc_mon_cb);
        d_xh = dc_xtn::type_id::create("d_xh");

        d_xh.vsync      = vif.dc_mon_cb.vsync;
        d_xh.hsync      = vif.dc_mon_cb.hsync;
        d_xh.data_valid = vif.dc_mon_cb.data_valid;
        d_xh.pixel_data_quemon = vif.dc_mon_cb.pixel_data;

        dc_port.write(d_xh);

 	if(vif.dc_mon_cb.data_valid)
        `uvm_info("DC_MON",$sformatf("PIXEL=%0h",d_xh.pixel_data_quemon),UVM_HIGH)
endtask

endclass



