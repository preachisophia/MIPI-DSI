interface dc_if(input bit p_clk);

//INPUT
logic [23:0] pixel_data;
logic 	     data_valid;
logic 	     hsync;
logic        vsync;

clocking dc_drv_cb@(posedge p_clk);
default input #1 output #1;
output pixel_data,data_valid,hsync,vsync;
endclocking

clocking dc_mon_cb@(posedge p_clk);
default input #1 output #1;
input  pixel_data,data_valid,hsync,vsync;
endclocking

modport dc_drv_mp(clocking dc_drv_cb);
modport dc_mon_mp(clocking dc_mon_cb);

endinterface
 
