class dc_cfg extends uvm_object;

`uvm_object_utils(dc_cfg)
virtual dc_if vif;

uvm_active_passive_enum is_active;

function new(string name="dc_cfg");
super.new(name);
endfunction

endclass
