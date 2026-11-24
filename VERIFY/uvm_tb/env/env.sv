class env extends uvm_env;

`uvm_component_utils(env)
dc_agent	dc_agth;
ppi_agent	ppi_agth;
svt_ahb_system_env   ahb_agth;//AHB VIP AGENT
svt_ahb_system_configuration ahb_cfg;//AHB VIP CONFIG

env_cfg		e_cfg;
sb		sb_h;

function new(string name="env",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_cfg=svt_ahb_system_configuration::type_id::create("ahb_cfg");//OBJECT creation

    ahb_cfg.num_masters = 1;
    ahb_cfg.num_slaves = 0;

    /** Create port configurations */
    ahb_cfg.create_sub_cfgs(1,0);

    ahb_cfg.master_cfg[0].transaction_coverage_enable = 1;

    ahb_cfg.master_cfg[0].is_active = 1;

    ahb_cfg.master_cfg[0].data_width = 32;
uvm_config_db#(svt_ahb_system_configuration)::set(this,"*","cfg",ahb_cfg);


if(!uvm_config_db#(env_cfg)::get(this,"","env_cfg",e_cfg))
`uvm_fatal("PPI_AGENT","ENV_CFG GETTING FAILD")
if(e_cfg.has_ahb_agt)
ahb_agth=svt_ahb_system_env::type_id::create("ahb_agth",this);
if(e_cfg.has_dc_agt)
dc_agth=dc_agent::type_id::create("dc_agth",this);
if(e_cfg.has_ppi_agt)
ppi_agth=ppi_agent::type_id::create("ppi_agth",this);

sb_h=sb::type_id::create("sb_h",this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
dc_agth.dc_monh.dc_port.connect(sb_h.dc_fifo.analysis_export);
ppi_agth.ppi_monh.ppi_port.connect(sb_h.ppi_fifo.analysis_export);
endfunction

endclass

