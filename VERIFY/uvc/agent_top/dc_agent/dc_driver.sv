class dc_driver extends uvm_driver#(dc_xtn);

`uvm_component_utils(dc_driver)
virtual dc_if.dc_drv_mp vif;
dc_cfg	      d_cfg;

function new(string name="dc_driver", uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(dc_cfg)::get(this,"","dc_cfg",d_cfg))
`uvm_fatal("DC_DRIVER","VIF GETTING FAILED")
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
 vif = d_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever
begin
	seq_item_port.get_next_item(req);
	send_to_dut(req);
	seq_item_port.item_done();	
end
endtask

task send_to_dut(dc_xtn dc_h);
    vif.dc_drv_cb.vsync<=1'b0;
    vif.dc_drv_cb.hsync<=1'b0;
    vif.dc_drv_cb.data_valid<=1'b0;
    vif.dc_drv_cb.pixel_data<=24'd0;
   for(int i=0;i<dc_h.no_of_frames;i++)
   begin
     @(vif.dc_drv_cb);
      vsync_task(dc_h);
      hsync_task(dc_h);
   end
endtask

task vsync_task(dc_xtn dc_h);
   repeat(dc_h.v_sync_cycles) 
   begin
     @(vif.dc_drv_cb);
     vif.dc_drv_cb.vsync<=1'b1;
   end
   repeat(dc_h.vbp)
   begin
     @(vif.dc_drv_cb);
     vif.dc_drv_cb.vsync<=1'b0;
   end
endtask

task hsync_task(dc_xtn dc_h);
int index=0;
for(int i=0; i<dc_h.no_of_lines; i++)
begin
   repeat(dc_h.h_sync_cycles)
   begin
     @(vif.dc_drv_cb);
     vif.dc_drv_cb.hsync<=1'b1;
   end
   repeat(dc_h.hbp)
   begin
     @(vif.dc_drv_cb);
     vif.dc_drv_cb.hsync<=1'b0;
   end
   for(int pix=0; pix<dc_h.no_of_pixels; pix++)
   begin
    @(vif.dc_drv_cb);
    vif.dc_drv_cb.data_valid<=1'b1;
    vif.dc_drv_cb.pixel_data<=dc_h.pixel_data[index];
	index++;
   end
   repeat(dc_h.hfp)
   begin
    @(vif.dc_drv_cb);
    vif.dc_drv_cb.data_valid<=1'b0;
    vif.dc_drv_cb.pixel_data<=24'd0;
   end
   repeat(dc_h.vfp)
   begin
    @(vif.dc_drv_cb);
    vif.dc_drv_cb.vsync<=1'b0;
   end
$display("*********************** DC DRIVER ****************************");
//           `uvm_info("DC_DRV",dc_h.sprint(), UVM_MEDIUM)//it does not have the proper data
dc_h.driver_print_line(i);

end
endtask

endclass


