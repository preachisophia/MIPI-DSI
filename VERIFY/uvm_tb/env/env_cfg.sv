class env_cfg extends uvm_sequence_item;

`uvm_object_utils(env_cfg)
dc_cfg	d_cfg;
ppi_cfg p_cfg;

bit has_sb;
bit has_ahb_agt;
bit has_dc_agt;
bit has_ppi_agt;

function new(string name="env_cfg");
super.new(name);
endfunction

endclass

