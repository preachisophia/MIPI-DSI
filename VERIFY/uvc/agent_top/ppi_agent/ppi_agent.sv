class ppi_agent extends uvm_agent;

`uvm_component_utils(ppi_agent)
ppi_monitor 	   ppi_monh;

env_cfg		   e_cfg;
ppi_cfg            p_cfg;

function new(string name="ppi_agent", uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(env_cfg)::get(this,"","env_cfg",e_cfg))
`uvm_fatal("PPI_AGENT","ENV_CFG GETTING FAILD")
p_cfg=e_cfg.p_cfg;

uvm_config_db#(ppi_cfg)::set(this,"*","ppi_cfg",e_cfg.p_cfg);

if(p_cfg.is_active==UVM_PASSIVE)
ppi_monh=ppi_monitor::type_id::create("ppi_monh",this);
endfunction

endclass
