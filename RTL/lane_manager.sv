
// ORIGINAL implementation
// lane_manager: serialise short/long packets across 1-4 PPI data lanes per dsi_ctrl0[1:0].
module lane_manager(input 				dsi_clk,
                    input 		[63:0] 	short_packet,
                    input [dsi.FRAME_LENGTH*24+80-1:0] long_packet,
                    input				packet_done,
                    output	reg [7:0]	ppi_data_lane0,
                    output	reg [7:0]	ppi_data_lane1,
            		output	reg [7:0]	ppi_data_lane2,
                    output	reg [7:0]	ppi_data_lane3,
                    output	reg			lane_done
                   );
  reg [15:0] WC;  // long-packet Word Count (payload bytes)
  reg [63:0] short_q;                       // packet being serialised
  reg [dsi.FRAME_LENGTH*24+80-1:0] long_q;
  reg [63:0] short_p;                       // packet captured at packet_done, waiting to be sent
  reg [dsi.FRAME_LENGTH*24+80-1:0] long_p;
  int req_cnt = 0;                          // packets captured
  int sent_cnt = 0;                         // packets taken for serialising
  int nl;                                   // active lanes, dsi_ctrl0[1:0]+1
  int nb;                                   // bytes in the transmission
  // byte k of the transmission: short x3, long (WC+10 bytes), short
  function automatic [7:0] stream_byte(input int k);
    if (k < 24)               stream_byte = short_q[(k%8)*8 +: 8];
    else if (k < 24+WC+10)    stream_byte = long_q[(k-24)*8 +: 8];
    else if (k < 24+WC+10+8)  stream_byte = short_q[(k-24-WC-10)*8 +: 8];
    else                      stream_byte = 8'h00;
  endfunction
  // capture every packet_done pulse, even one that lands while the previous packet is still going out
  always @(posedge dsi_clk)
    if (packet_done) begin
      short_p <= short_packet;
      long_p  <= long_packet;
      req_cnt <= req_cnt + 1;
    end
  initial lane_done=0;
//   final begin
//     lane_done=1;
//   end
  always@(posedge dsi_clk)
    begin
      forever begin
        @(posedge dsi_clk);
        if(req_cnt != sent_cnt)
          break;
      end

     // take the captured packet: packetizer rebuilds short/long_packet on the next line while we are still serialising
     sent_cnt = sent_cnt + 1;
     short_q  = short_p;
     long_q   = long_p;
     WC=dsi.dsi_reg.dsi_lng[16:1];  // dsi_lng[16:1] = payload byte count (same field as the packet header)

      @(posedge dsi_clk);
//       $display("short_packet=%0h",short_packet);
//       $display("long_packet=%0h",long_packet);
//         if(dsi.dsi_reg.dsi_cmd[0]==0) begin
//           for(int i=0; i<(64)/8; i++) begin
//             ppi_data_lane0=short_packet[i*8+:8];
//             @(posedge dsi_clk);
//             $display("ppi_data_lane0=%0h",ppi_data_lane0);
//           end
//           for(int i=0; i<(64)/8; i++) begin
//             ppi_data_lane0=short_packet[i*8+:8];
//             @(posedge dsi_clk);
//           end
//           for(int i=0; i<(64)/8; i++) begin
//             ppi_data_lane0=short_packet[i*8+:8];
//             @(posedge dsi_clk);
//           end
//         end
//         if(dsi.dsi_reg.dsi_cmd[0]==1) begin
//           case (dsi.dsi_reg.dsi_ctrl0[1:0])
//             2'b00: begin
//                    for(int i=0; i<(8+8+32+WC+16+8+8)/8; i++) begin
//                      ppi_data_lane0=long_packet[i*8+:8];
//                      @(posedge dsi_clk);
//                    end
//                  end
//             2'b01: begin
//                    for(int i=0; i<(8+8+8+WC+8+8+8)/8; i=i+2) begin
//                      ppi_data_lane0=long_packet[i*8+:8];
//                      ppi_data_lane1=long_packet[(i+1)*8+:8];
//                      @(posedge dsi_clk);
//                    end
//                  end
//             2'b10: begin
//                    for(int i=0; i<(8+8+8+WC+8+8+8)/8; i=i+3) begin
//                      ppi_data_lane0=long_packet[i*8+:8];
//                      ppi_data_lane1=long_packet[(i+1)*8+:8];
//                      ppi_data_lane2=long_packet[(i+2)*8+:8];
//                      @(posedge dsi_clk);
//                    end
//                  end
//             2'b11: begin  
//                    for(int i=0; i<(8+8+8+WC+8+8+8)/8; i=i+4) begin
//                      ppi_data_lane0=long_packet[i*8+:8];
//                      ppi_data_lane1=long_packet[(i+1)*8+:8];
//                      ppi_data_lane2=long_packet[(i+2)*8+:8];
//                      ppi_data_lane2=long_packet[(i+3)*8+:8];
//                      @(posedge dsi_clk);
//                    end
//                  end
//           endcase
//       end
      
               
    // DSI 6 / 6.1.3: the transmission (3 short + long + short packet) is one byte stream sent
    // round-robin over N lanes; on the last beat, lanes with no byte left drop their enable
    nl = dsi.dsi_reg.dsi_ctrl0[1:0] + 1;
    nb = 3*8 + (WC+10) + 8;
    for (int i = 0; i < nb; i = i + nl) begin
      dsi.ppi_lane0_en = (i   < nb);           ppi_data_lane0 = stream_byte(i);
      dsi.ppi_lane1_en = (nl > 1 && i+1 < nb); if (nl > 1) ppi_data_lane1 = stream_byte(i+1);
      dsi.ppi_lane2_en = (nl > 2 && i+2 < nb); if (nl > 2) ppi_data_lane2 = stream_byte(i+2);
      dsi.ppi_lane3_en = (nl > 3 && i+3 < nb); if (nl > 3) ppi_data_lane3 = stream_byte(i+3);
      @(posedge dsi_clk);
    end
    dsi.ppi_lane0_en=0;
    dsi.ppi_lane1_en=0;
    dsi.ppi_lane2_en=0;
    dsi.ppi_lane3_en=0;
    @(posedge dsi_clk);
    lane_done=1;
    @(posedge dsi_clk);
    lane_done=0;
    
  end
endmodule
