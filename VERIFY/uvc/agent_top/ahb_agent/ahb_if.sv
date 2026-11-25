interface ahb_if(input bit h_clk, input bit hresetn);

//MASTER OUTPUTS
logic [31:0] haddr;
logic        hwrite;
logic [2:0]  hsize;
logic [2:0]  hburst;
logic [1:0]  htrans;
logic [31:0] hwdata;
logic [3:0]  hprot;

//SLAVE OUTPUTS
logic [31:0] hrdata;
logic        hready;
logic [1:0]  hresp;

clocking ahb_drv_cb@(posedge h_clk);
default input #1 output #1;
output haddr,hwrite,hsize,hburst,htrans,hwdata,hprot;
input  hrdata,hready,hresp,hresetn;
endclocking

clocking ahb_mon_cb@(posedge h_clk);
default input #1 output #1;
input  haddr,hwrite,hsize,hburst,htrans,hwdata,hprot,hrdata,hready,hresp,hresetn;
endclocking

modport ahb_drv_mp(clocking ahb_drv_cb);
modport ahb_mon_mp(clocking ahb_mon_cb);

endinterface
