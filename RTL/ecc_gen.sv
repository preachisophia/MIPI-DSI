// ecc_gen: 8-bit ECC generator for the DSI packet (XOR accumulate over payload).
module ecc_gen(input dsi_clk,
               input [(dsi.FRAME_LENGTH*24)-1:0] payload,
               input			fifo_done,
               output reg [7:0] ecc,
               output reg		ecc_done
               );
  // DSI 9.3 Table 22: P5..P0 parity over header bits D0..D23, P7/P6 = 0
  function automatic [7:0] dsi_ecc(input [23:0] d);
    dsi_ecc[0] = d[0]^d[1]^d[2]^d[4]^d[5]^d[7]^d[10]^d[11]^d[13]^d[16]^d[20]^d[21]^d[22]^d[23];
    dsi_ecc[1] = d[0]^d[1]^d[3]^d[4]^d[6]^d[8]^d[10]^d[12]^d[14]^d[17]^d[20]^d[21]^d[22]^d[23];
    dsi_ecc[2] = d[0]^d[2]^d[3]^d[5]^d[6]^d[9]^d[11]^d[12]^d[15]^d[18]^d[20]^d[21]^d[22];
    dsi_ecc[3] = d[1]^d[2]^d[3]^d[7]^d[8]^d[9]^d[13]^d[14]^d[15]^d[19]^d[20]^d[21]^d[23];
    dsi_ecc[4] = d[4]^d[5]^d[6]^d[7]^d[8]^d[9]^d[16]^d[17]^d[18]^d[19]^d[20]^d[22]^d[23];
    dsi_ecc[5] = d[10]^d[11]^d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[21]^d[22]^d[23];
    dsi_ecc[7:6] = 2'b00;
  endfunction
  initial begin
    ecc=0;
    ecc_done=0;
  end

  always@(posedge dsi_clk) 
    begin
      forever begin
        @(posedge dsi_clk);
        if(fifo_done==1)
          break;
      end

        // DSI 9.3: ECC covers the 24 header bits D[23:0] = {WC[15:0], DI[7:0]}, not the payload
        ecc = dsi_ecc({dsi.dsi_reg.dsi_lng[16:1], dsi.dsi_reg.dsi_cmd[8:1]});

      @(posedge dsi_clk);
      ecc_done=1;
      @(posedge dsi_clk);
      ecc_done=0;
    end
endmodule

