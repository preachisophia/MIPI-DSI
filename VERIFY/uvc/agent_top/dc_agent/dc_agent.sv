class dc_agent extends uvm_agent;

`uvm_component_utils(dc_agent)
dc_seqr	   dc_sqrh;
dc_driver  dc_drvh;
dc_monitor dc_monh;

env_cfg	   e_cfg;
dc_cfg     d_cfg;

function new(string name="dc_agent", uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(env_cfg)::get(this,"","env_cfg",e_cfg))
`uvm_fatal("DC_AGENT","ENV_CFG IS GETTING FAILED")
d_cfg=e_cfg.d_cfg;

uvm_config_db#(dc_cfg)::set(this,"*","dc_cfg",e_cfg.d_cfg);

dc_monh=dc_monitor::type_id::create("dc_monh",this);
if(d_cfg.is_active==UVM_ACTIVE)
begin
dc_sqrh=dc_seqr::type_id::create("dc_sqrh",this);
dc_drvh=dc_driver::type_id::create("dc_drvh",this);
end
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
if(d_cfg.is_active==UVM_ACTIVE)
dc_drvh.seq_item_port.connect(dc_sqrh.seq_item_export);
endfunction
endclass
