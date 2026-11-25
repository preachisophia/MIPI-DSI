class ahb_agent extends uvm_agent;

`uvm_component_utils(ahb_agent)
ahb_seqr	ahb_sqrh;
ahb_driver	ahb_drvh;
ahb_monitor	ahb_monh;

ahb_cfg		a_cfg;

function new(string name="ahb_agent", uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(ahb_cfg)::get(this,"","ahb_cfg",a_cfg))
`uvm_fatal("AHB_AGENT","AHB_CFG IS GETTING FAILED")

ahb_monh=ahb_monitor::type_id::create("ahb_monh",this);
if(a_cfg.is_active==UVM_ACTIVE)
begin
ahb_sqrh=ahb_seqr::type_id::create("ahb_sqrh",this);
ahb_drvh=ahb_driver::type_id::create("ahb_drvh",this);
end
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
if(a_cfg.is_active==UVM_ACTIVE)
ahb_drvh.seq_item_port.connect(ahb_sqrh.seq_item_export);
endfunction
endclass
