// crc_gen: MIPI DSI CRC-16 over the long-packet payload (poly 0x1021, seed 0xFFFF).
module crc_gen(input 								dsi_clk,
               input [(dsi.FRAME_LENGTH*24)-1:0] 	payload,
               input								fifo_done,
               output reg [15:0]					crc,
               output reg							crc_done
              );
  int i;  // payload bit index
  reg [15:0] crc_poly;
  initial begin
    crc=16'hFFFF;  // DSI CRC-16 seed (all ones)
    crc_poly = 16'h8408;  // MIPI DSI CRC-16 x^16 + x^12 + x^5 + 1 (0x1021), bit-reversed for LSB-first shifting (Annex B)
    crc_done=0;
  end

  always@(posedge dsi_clk) 
    begin
      forever begin
        @(posedge dsi_clk);
        if(fifo_done==1)
          break;
      end
      // DSI 9.6: seed 0xFFFF per packet, feed the WC payload bytes in transmit order, LS bit first
      crc = 16'hFFFF;
      for (i = 0; i < dsi.dsi_reg.dsi_lng[16:1]*8 && i < $bits(payload); i++) begin
        if(crc[0]^payload[i])
          crc=(crc>>1)^crc_poly;
        else
          crc=crc>>1;
      end
      @(posedge dsi_clk);
      crc_done=1;
      @(posedge dsi_clk);
      crc_done=0;
   end
endmodule
