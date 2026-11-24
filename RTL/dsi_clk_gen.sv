
// dsi_clk_gen: derive dsi_clk from pclk using the divider in dsi_ctrl0[1:0].
module dsi_clk_gen(
  input      pclk,
  output reg dsi_clk
);

  real pclk_period;
  real dsi_clk_period;
  reg [2:0] dsi_div;  // dsi_clk cycles per pclk (fixed 3:1)
  time t1, t2;

  initial begin
    dsi_clk     = 0;
    pclk_period = 0;
  end

  initial begin
    @(posedge pclk); 
    t1 = $time;
    @(posedge pclk); 
    t2 = $time;
    pclk_period    = t2 - t1;
  end

  always @(posedge pclk) 
   begin
     disable dsi_toggle_blk; // kill any leftover dsi_clk toggles from the previous pclk window
     // fixed 3:1: one lane needs ~72 dsi_clk cycles per 30-pclk line, a 1:1 ratio drops lines
     dsi_div = 3;
     dsi_clk_period = pclk_period / dsi_div;
    if(pclk_period!=0) 
      begin
      fork:dsi_toggle_blk
        begin
          repeat(2*dsi_div)//toggle clk: edges scale with the divider
           begin
            #(dsi_clk_period / 2.0);
            dsi_clk = ~dsi_clk;
           end
        end
      join_none
      end
  end
endmodule
